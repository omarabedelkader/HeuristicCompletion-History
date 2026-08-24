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

After the Metacello load, the consent dialog asks whether the user agrees to send code-completion history events for research. Telemetry is off by default. `Yes, I agree` installs `CooSession`, configures the recorder through `CooHistoryEventRecorder configureForLocalPXServer`, creates the PX event collector, points EventRecorder at the configured `CooHistoryEventRecorder serverUrl`, sets the delivery batch size to `1`, and immediately logs a recorder lifecycle event under the `complishon/complishon` collector path. Later history events are logged through the same EventRecorder stack as soon as they are recorded.

`No, don't collect data`, closing the dialog, cancelling it, or any UI error installs the null recorder and sends nothing. The same settings page can later enable or disable history telemetry, but no explicit Yes means no telemetry.

## Local development with a PX data collector

Start the ingestion server (`pharo-data-collector` project) in another Pharo image:

```smalltalk
PXServer start.
```

It listens on `http://localhost:8008` and exposes the `/events` ingest endpoint. Then configure and enable the history telemetry in this image:

```smalltalk
CooHistoryEventRecorder reset.
CooHistoryEventRecorder configureForLocalPXServer.
CooSession install.
CooHistoryEventRecorder install.
CooHistoryEventRecorder enableDelivery.
```

The server validates that each upload carries four non-empty metadata strings (`category`, `experienceId`, `participantUUID`, `taskOrSurveyId`) and persists every event under `var/data/<category>/<experienceId>/<participantUUID>/<taskOrSurveyId>/`. The recorder generates a stable anonymous `participantUUID` once per image and never derives it from personal information; set explicit values with `CooHistoryEventRecorder participantUUID:` and `CooHistoryEventRecorder taskOrSurveyId:` when running a real study.
