# HeuristicCompletion-History

[![Pharo P14](https://img.shields.io/badge/Pharo-P14-2c98f0.svg)](https://github.com/omarabedelkader/ChatPharo)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/omarabedelkader/HeuristicCompletion-History/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/omarabedelkader/HeuristicCompletion-History/pulls)
[![Status: Active](https://img.shields.io/badge/status-active-success.svg)](https://github.com/omarabedelkader/HeuristicCompletion-History)


```smalltalk
Metacello new
  baseline: 'ExtendedHeuristicCompletionHistory';
  repository: 'github://omarabedelkader/HeuristicCompletion-History:main/src';
  load: 'full'.   "or 'default' / 'Bench' / 'Sharing'"
```

```smalltalk
Metacello new
  baseline: 'ExtendedHeuristicCompletionHistory';
  repository: 'github://omarabedelkader/HeuristicCompletion-History:main/src';
  load.
```


## Running the History benchmarks

The benchmark replays the last 200 commits of the first-parent history (main line: a merged branch is one step)
of 30 Pharo projects and, for every call site a commit introduced, asks six completion configurations to complete
the expected token from prefixes of 2 to 8 characters:

| Configuration | Message completion | Variable (class name) completion |
|---|---|---|
| Baseline | all selectors | all globals |
| Semantic | default Complishon heuristics | default Complishon heuristics |
| History | session history first, then Semantic | Semantic, then session history |
| HistoryAfterSelf | self/super heuristics, then session history, then the rest of Semantic | as History |
| Dependency | Semantic, then direct package dependencies | Semantic, then direct package dependencies |
| Hybrid | History and Dependency | History and Dependency |

While a commit is benchmarked, the history strategies only see the history of the previous commits
(`CooHistorySnapshot`), so a commit never helps to predict its own call sites.

### Replaying the projects

`scripts/run-history-benchmarks.sh` downloads a fresh Pharo 14 image, installs this checkout (group `Bench`)
and runs every project in its own directory with its own copy of the image:

```bash
scripts/run-history-benchmarks.sh                       # the 30 projects
scripts/run-history-benchmarks.sh microdown roassal     # only some of them
PARALLEL=7 scripts/run-history-benchmarks.sh            # 7 projects at a time
```

Options (environment variables): `WORK_DIR` (default `./history-bench`), `REPO` (default this checkout),
`PARALLEL` (default 1), `RUN_TIMEOUT` in seconds per project (default 7200), `KEEP_IMAGES=1`.
The projects are cloned over SSH, so GitHub needs your SSH key.

For each project, `history-bench/results/<project>/` contains:

- `<project>-callsites.csv`: one line per benchmarked call site, with the commit, the method, the expected token,
  the kind of receiver and whether the token is in the history, in the package of the call site or in one of
  its direct dependencies;
- `<project>-ranks.csv`: one line per call site, configuration and prefix size, with the rank of the expected
  token in the first ten proposals (0 when absent) and the completion time in milliseconds;
- `<project>-results.ston`, plots (`.svg`, `.png`) and LaTeX tables of the per-project MRR and statistics.

`history-bench/results/summary.{svg,png,md,csv,tex}` compares the five configurations over all projects.

### The folder for the paper

At the end of a run, the script writes **one folder, `history-bench/paper-results/`**, with everything the paper
uses: `results-macros.tex` (a `\newcommand` for every number quoted in the text), `tables/*.tex`,
`data/*.dat` (pgfplots), `summary.json` and the summary picture. Copy this folder into the paper, or let the
script do it:

```bash
PAPER_DIR=../2027-msr-history-benchmarks scripts/run-history-benchmarks.sh   # run, then copy into the paper
PAPER_DIR=../2027-msr-history-benchmarks scripts/make-paper-results.sh       # only rebuild and copy the folder
```

`make-paper-results.sh` runs `scripts/analyze_history_benchmarks.py` (Python 3, standard library only), which
computes MRR@10 and Hit@k, per-prefix curves, the share of tokens found in the history / own package /
dependencies, MRR by origin of the token and by receiver kind, paired Wilcoxon tests per call site
(Holm-corrected over projects) with rank-biserial effect sizes, Spearman correlations between project
characteristics and gains, the effect of history size, and completion times.
