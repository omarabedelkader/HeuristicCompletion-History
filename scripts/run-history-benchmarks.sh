#!/usr/bin/env bash
# Build a fresh Pharo 14 image, install this repository (group 'Bench'), run the History
# experiment of every project in its own copy of that image, then aggregate all the results
# into one summary picture and table.
#
# Usage:
#   scripts/run-history-benchmarks.sh                    # all projects
#   scripts/run-history-benchmarks.sh microdown roassal  # only these ones
#
# Environment variables:
#   WORK_DIR     where the image and results go       (default: ./history-bench)
#   REPO         Metacello repository of this project (default: this checkout, tonel://.../src)
#   RUN_TIMEOUT  seconds allowed per project          (default: 7200)
#   KEEP_IMAGES  1 keeps the per-project images       (default: 0)
#
# Output: $WORK_DIR/results/<project>/...  and  $WORK_DIR/results/summary.{svg,png,md,csv,tex}
# The configurations clone over SSH (git@github.com:...), so an SSH key known by GitHub is needed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$(mkdir -p "${WORK_DIR:-$PWD/history-bench}" && cd "${WORK_DIR:-$PWD/history-bench}" && pwd)"
REPO="${REPO:-tonel://$REPO_ROOT/src}"
RUN_TIMEOUT="${RUN_TIMEOUT:-7200}"
KEEP_IMAGES="${KEEP_IMAGES:-0}"
RESULTS="$WORK_DIR/results"
LOGS="$WORK_DIR/logs"

# Selectors of the CooHistoryExperimentConfiguration class-side constructors.
ALL_PROJECTS=(microdown roassal druid fame famix fastPython fastTypescript gitProjectHealth mooseCI tinyLogger)
if [ "$#" -gt 0 ]; then PROJECTS=("$@"); else PROJECTS=("${ALL_PROJECTS[@]}"); fi

mkdir -p "$RESULTS" "$LOGS"
cd "$WORK_DIR"

with_timeout() { perl -e 'alarm shift; exec @ARGV or die "exec: $!"' "$@"; }

pharo_st() { # image script.st [extra st options...]
  local image="$1" script="$2"; shift 2
  ./pharo "$image" st --quit "$@" "$script"
}

# 1. Fresh Pharo 14 image + VM -------------------------------------------------------------
if [ ! -f Pharo.image ]; then
  echo "==> Downloading Pharo 14 image and VM into $WORK_DIR"
  curl -fsSL https://get.pharo.org/64/140+vm | bash
fi

# 2. Install this repository ------------------------------------------------------------------
if [ ! -f bench-base.image ]; then
  echo "==> Installing $REPO (group Bench)"
  cat > "$LOGS/install.st" <<EOF
[ Metacello new
	baseline: 'ExtendedHeuristicCompletionHistory';
	repository: '$REPO';
	onConflict: [ :e | e useIncoming ];
	onUpgrade: [ :e | e useIncoming ];
	load: #( 'Bench' ) ]
		on: Warning
		do: [ :w | w resume: true ].
(Smalltalk globals includesKey: #CooHistoryExperimentSummary)
	ifFalse: [ Stdio stderr nextPutAll: 'Install failed'; lf. Smalltalk exitFailure ].
EOF
  cp Pharo.image bench-tmp.image
  cp Pharo.changes bench-tmp.changes
  if pharo_st bench-tmp.image "$LOGS/install.st" --save > "$LOGS/install.log" 2>&1 \
     && grep -q "finished to load" "$LOGS/install.log"; then
    mv bench-tmp.image bench-base.image
    mv bench-tmp.changes bench-base.changes
  else
    echo "Install failed, see $LOGS/install.log" >&2
    exit 1
  fi
fi

# 3. One experiment per project, each in a fresh copy of the base image -----------------------
failed=()
for project in "${PROJECTS[@]}"; do
  echo "==> Running $project (log: $LOGS/$project.log)"
  cp bench-base.image "run-$project.image"
  cp bench-base.changes "run-$project.changes"
  cat > "$LOGS/run-$project.st" <<EOF
[ CooHistoryExperimentRunner
	runConfigurationNamed: #$project
	outputDirectory: '$RESULTS/$project' ]
		on: Error
		do: [ :e |
			Stdio stderr nextPutAll: 'Experiment failed: ', e description; lf.
			Smalltalk exitFailure ].
EOF
  if ! with_timeout "$RUN_TIMEOUT" ./pharo "run-$project.image" st --quit "$LOGS/run-$project.st" \
       > "$LOGS/$project.log" 2>&1 \
     || ! ls "$RESULTS/$project/"*-results.ston >/dev/null 2>&1; then
    echo "    !! $project failed or timed out, see $LOGS/$project.log" >&2
    failed+=("$project")
  fi
  [ "$KEEP_IMAGES" = 1 ] || rm -f "run-$project.image" "run-$project.changes"
done

# 4. Summary ------------------------------------------------------------------------------------
echo "==> Writing summary"
cat > "$LOGS/summary.st" <<EOF
(CooHistoryExperimentSummary fromDirectory: '$RESULTS') exportTo: '$RESULTS'.
EOF
pharo_st bench-base.image "$LOGS/summary.st" > "$LOGS/summary.log" 2>&1

if command -v rsvg-convert >/dev/null; then
  rsvg-convert -b white "$RESULTS/summary.svg" -o "$RESULTS/summary.png"
elif command -v magick >/dev/null; then
  magick -background white "$RESULTS/summary.svg" "$RESULTS/summary.png"
else
  echo "No SVG converter found (brew install librsvg); only summary.svg was written." >&2
fi

echo
cat "$RESULTS/summary.md"
echo
echo "Picture: $RESULTS/summary.svg$( [ -f "$RESULTS/summary.png" ] && echo " (and summary.png)")"
if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed projects: ${failed[*]}" >&2
  exit 1
fi
