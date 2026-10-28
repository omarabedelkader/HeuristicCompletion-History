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

`scripts/run-history-benchmarks.sh` downloads a fresh Pharo 14 image, installs this checkout (group `Bench`),
runs every project experiment in its own copy of that image and writes one summary:

```bash
scripts/run-history-benchmarks.sh                    # all projects
scripts/run-history-benchmarks.sh microdown roassal  # only some of them
```

Results land in `history-bench/results/`: one folder per project, plus `summary.svg` / `summary.png`
(overall MRR of Semantic, History and Dependency for every project, with the table of numbers) and
`summary.md`, `summary.csv`, `summary.tex`. The projects are cloned over SSH, so GitHub needs your SSH key.
