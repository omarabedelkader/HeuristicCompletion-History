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
#   PARALLEL     projects run at the same time        (default: 1)
#   PAPER_DIR    if set, paper-results/ is also copied into this paper folder
#
# Every project runs in $WORK_DIR/projects/<project>/ with its own image and pharo-local.
# Output: $WORK_DIR/results/<project>/...  and  $WORK_DIR/results/summary.{svg,png,md,csv,tex}
#         $WORK_DIR/paper-results/: the single folder the paper reads (see make-paper-results.sh)
# The configurations clone over SSH (git@github.com:...), so an SSH key known by GitHub is needed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$(mkdir -p "${WORK_DIR:-$PWD/history-bench}" && cd "${WORK_DIR:-$PWD/history-bench}" && pwd)"
REPO="${REPO:-tonel://$REPO_ROOT/src}"
RUN_TIMEOUT="${RUN_TIMEOUT:-7200}"
KEEP_IMAGES="${KEEP_IMAGES:-0}"
PARALLEL="${PARALLEL:-1}"
RESULTS="$WORK_DIR/results"
LOGS="$WORK_DIR/logs"

# Selectors of the CooHistoryExperimentConfiguration class-side constructors.
ALL_PROJECTS=(microdown roassal druid fame famix fastPython fastTypescript gitProjectHealth mooseCI tinyLogger
  bloc toplo polyMath dataFrame seaside pillar mooseIDE voyage chatPharo pharoLauncher)
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

# 3. One experiment per project, each in its own directory with a fresh copy of the base image --
run_project() { # project
  local project="$1" dir="$WORK_DIR/projects/$1"
  rm -rf "$dir" "$RESULTS/$project" "$LOGS/$project.failed"
  mkdir -p "$dir"
  cp bench-base.image "$dir/run.image"
  cp bench-base.changes "$dir/run.changes"
  cp pharo "$dir/pharo"
  ln -s "$WORK_DIR/pharo-vm" "$dir/pharo-vm"
  for sources in *.sources; do ln -s "$WORK_DIR/$sources" "$dir/$sources"; done
  cat > "$dir/run.st" <<EOF
[ CooHistoryExperimentRunner
	runConfigurationNamed: #$project
	outputDirectory: '$RESULTS/$project' ]
		on: Error
		do: [ :e |
			Stdio stderr nextPutAll: 'Experiment failed: ', e description; lf.
			(e signalerContext stack first: (e signalerContext stack size min: 25))
				do: [ :context | Stdio stderr nextPutAll: context printString; lf ].
			Smalltalk exitFailure ].
EOF
  echo "==> [$(date +%H:%M:%S)] start  $project (log: $LOGS/$project.log)"
  if (cd "$dir" && with_timeout "$RUN_TIMEOUT" ./pharo run.image st --quit run.st) > "$LOGS/$project.log" 2>&1 \
     && ls "$RESULTS/$project/"*-results.ston >/dev/null 2>&1; then
    echo "==> [$(date +%H:%M:%S)] done   $project"
  else
    echo "==> [$(date +%H:%M:%S)] FAILED $project (failed or timed out), see $LOGS/$project.log" >&2
    touch "$LOGS/$project.failed"
  fi
  [ "$KEEP_IMAGES" = 1 ] || rm -f "$dir/run.image" "$dir/run.changes"
}

failed=()
for project in "${PROJECTS[@]}"; do
  while [ "$(jobs -rp | wc -l)" -ge "$PARALLEL" ]; do sleep 5; done
  run_project "$project" &
done
wait
for project in "${PROJECTS[@]}"; do
  [ -f "$LOGS/$project.failed" ] && failed+=("$project")
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

# 5. The folder of tables, figures data and numbers used by the paper ---------------------------
echo "==> Writing paper-results"
"$SCRIPT_DIR/make-paper-results.sh" "$RESULTS"

echo
cat "$RESULTS/summary.md"
echo
echo "Picture: $RESULTS/summary.svg$( [ -f "$RESULTS/summary.png" ] && echo " (and summary.png)")"
if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed projects: ${failed[*]}" >&2
  exit 1
fi
