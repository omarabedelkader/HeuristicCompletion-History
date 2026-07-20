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

After the Metacello load, the privacy dialog asks `Yes`, `No`, or `View Privacy`. `Yes` installs `CooSession`, creates the PX event collector, points EventRecorder at the configured `CooHistoryEventRecorder serverUrl`, sets the delivery batch size to `1`, and immediately logs a recorder lifecycle event under the `complishon/complishon` collector path. Later history events are logged through the same EventRecorder stack as soon as they are recorded. `No` installs the null recorder and sends nothing.

## Simplest Server Logging

Load the server logging dependencies in the Pharo 14 client image:

```smalltalk
Metacello new
  baseline: 'DSSpyEventRecorder';
  repository: 'github://Pharo-XP-Tools/DebuggingSpy-EventRecorder:omar';
  load.

Metacello new
  baseline: 'ExperimentModel';
  repository: 'github://Pharo-XP-Tools/ExperimentModel:omar';
  load.
```

After the participant has consented, create and authorize a recorder:

```smalltalk
recorder := EMEventRecorderLogger new.
recorder authorizeDataSending.
```

Then send data with `log:`:

```smalltalk
recorder log: 'test 2'.
recorder deliverDataNow.
```

Server-side, those logs are stored under:

```text
/home/oabedelk/px-experiments/data/complishon/complishon
```

Do not log identifying data.

## Coo Recorder Setup

Run this in the Pharo image before the participant starts the task. Use it when
you want to configure the collector explicitly instead of relying on the first
launch privacy dialog.

For the hosted RMOD collector:

```smalltalk
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'.
CooHistoryEventRecorder category: #complishon.
CooHistoryEventRecorder experienceId: 'complishon'.
CooHistoryEventRecorder saveOnDisk: false.
CooHistoryEventRecorder deliveryBatchSize: 1.
CooSession install.
CooHistoryEventRecorder install.
CooHistoryEventRecorder enableDelivery.
CooHistoryEventRecorder recordRemoteDeliveryEnabled.
```

For a local `phex-data-collector` started on port `9091`, use the server root:

```smalltalk
CooHistoryEventRecorder serverUrl: 'http://127.0.0.1:9091/'.
```

After editing a method, force a delivery and inspect the result:

```smalltalk
CooHistoryEventRecorder deliverNow.
CooHistoryEventRecorder lastDeliveryError.     "nil means the client saw no error"
CooHistoryEventRecorder lastDeliveryResponse.
```

To send one manual event without installing the code-change recorder:

```smalltalk
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'.
CooHistoryEventRecorder category: #complishon.
CooHistoryEventRecorder experienceId: 'complishon'.
CooHistoryEventRecorder install.

CooHistoryEventRecorder uniqueInstance logEvent: (Dictionary new
	at: #kind put: #manual;
	at: #event put: #test;
	at: #timestamp put: DateAndTime now asString;
	yourself).

CooHistoryEventRecorder uniqueInstance deliverLoggerDataNow.
CooHistoryEventRecorder lastDeliveryError.
```

If the server address is unknown, it cannot be guessed from the client. The
collector owner must provide the reachable URL and route. A timeout means the
port is not reachable; an HTTP 500 means the request reached the server but the
server failed while handling or storing it.
