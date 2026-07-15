# HeuristicCompletion-History

[![Pharo P14](https://img.shields.io/badge/Pharo-P14-2c98f0.svg)](https://github.com/omarabedelkader/ChatPharo)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/omarabedelkader/HeuristicCompletion-History/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/omarabedelkader/HeuristicCompletion-History/pulls)
[![Status: Active](https://img.shields.io/badge/status-active-success.svg)](https://github.com/omarabedelkader/HeuristicCompletion-History)


```smalltalk
Metacello new
  githubUser: 'omarabedelkader' project: 'HeuristicCompletion-History' commitish: 'main' path: 'src';
  baseline: 'ExtendedHeuristicCompletionHistory';
  load.
```

```smalltalk
Metacello new
  baseline: 'ExtendedHeuristicCompletionHistory';
  repository: 'github://omarabedelkader/HeuristicCompletion-History:main/src';
  load.
```

After the Metacello load, the privacy dialog asks `Yes`, `No`, or `View Privacy`. `Yes` installs `CooSession`, creates and authorizes `EMEventRecorderLogger`, points EventRecorder at the configured `CooHistoryEventRecorder serverUrl`, sets the delivery batch size to `1`, and immediately logs a recorder lifecycle event under the `complishon/complishon` collector path. Later history events are logged through the same ExperimentModel/EventRecorder stack as soon as they are recorded. `No` installs the null recorder and sends nothing.
