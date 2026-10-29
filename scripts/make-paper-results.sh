#!/usr/bin/env bash
# Build the single folder the paper reads: every table, plot data file, number macro and the
# summary picture, generated from the raw observations of a benchmark run.
#
# Usage:
#   scripts/make-paper-results.sh [RESULTS_DIR]       # default: ./history-bench/results
#
# Environment variables:
#   PAPER_DIR   if set, the folder is also copied to $PAPER_DIR/paper-results (replacing the old one)
#
# Output: <RESULTS_DIR>/../paper-results/
#   results-macros.tex   \newcommand for every number quoted in the paper
#   tables/*.tex         LaTeX tables
#   data/*.dat           pgfplots data
#   summary.json         every computed value
#   summary.{svg,png}    overall picture produced by the Pharo summary

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS="$(cd "${1:-$PWD/history-bench/results}" && pwd)"
OUT="$(dirname "$RESULTS")/paper-results"

rm -rf "$OUT"
python3 "$SCRIPT_DIR/analyze_history_benchmarks.py" "$RESULTS" "$OUT"
for picture in summary.svg summary.png; do
  [ -f "$RESULTS/$picture" ] && cp "$RESULTS/$picture" "$OUT/"
done

if [ -n "${PAPER_DIR:-}" ]; then
  rm -rf "$PAPER_DIR/paper-results"
  cp -R "$OUT" "$PAPER_DIR/paper-results"
  echo "Copied to $PAPER_DIR/paper-results"
fi
echo "Paper results: $OUT"
