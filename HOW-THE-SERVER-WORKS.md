# How the Recorder and the Collector Server Work

This note explains, at an engineer level, how history events travel from your
Pharo image to the data-collector server, why you were seeing **no data** when
you clicked "yes" and started typing, why the stored data looked like
**unreadable serialized bytes**, and what was changed in this repo to fix both.

Only this repo (`HeuristicCompletion-History`) was changed. The server
(`phex-data-collector` / `Pharo-XP-EventRecorder`) was **not** touched.

---

## 1. The big picture

```
   Your Pharo image (the "client")                 The collector (the "server")
   ┌───────────────────────────────┐               ┌──────────────────────────────┐
   │ You edit code / use completion │               │ PXServer (ZnServer :9091)     │
   │            │                   │               │   → PXServerDelegate          │
   │            ▼                   │               │      → PXEventRecorderPutHandler
   │ SystemAnnouncer fires          │   HTTP PUT    │         (validates request)   │
   │ (MethodAdded, ClassAdded, …)   │  multipart    │      → PXServerFileStorage    │
   │            │                   │  form-data    │         (writes files)        │
   │            ▼                   │ ────────────► │            │                  │
   │ CooHistoryEventRecorder        │               │            ▼                  │
   │  - builds history items        │               │  ~/px-experiments/data/       │
   │  - queues serialized events    │               │    <category>/<experienceId>/ │
   │  - PUTs batches to the server  │               │    <participantUUID>/<taskId>/│
   └───────────────────────────────┘               └──────────────────────────────┘
```

Two independent things happen inside the recorder:

1. **Local**: it feeds a `CooSession` so history-based code completion works.
2. **Remote**: it serializes each event and PUTs it to the collector server.

This document is about the **remote** path.

---

## 2. The recorder (the "logger") — `CooHistoryEventRecorder`

File: `src/ExtendedHeuristicCompletion-History-Recorder/CooHistoryEventRecorder.class.st`

### What it listens to
On `install`, it subscribes to the system code-change announcer:

- `MethodAdded`, `MethodModified`, `MethodRemoved`
- `ClassAdded`, `ClassModified`, `ClassRemoved`
- `CoCompletionItemSelected` (completion picks, when available)

Every announcement is turned into a small `Dictionary` (kind, event, className,
selector, timestamp, …) and appended to an in-memory queue, `pendingEvents`.

### How it decides to send
- Events accumulate in `pendingEvents`.
- When `pendingEvents size >= deliveryBatchSize`, it forks a background process
  and calls `deliverNow`.
- `deliverNow` also runs before the image is saved, and can be called manually:
  `CooHistoryEventRecorder deliverNow`.

### How it sends (the wire format)
`deliverNow` wraps the queued events in an **envelope** dictionary
(`schema`, `recorder`, `timestamp`, `category`, `image`, `events`), serializes
it, and PUTs it as **`multipart/form-data`** with two fields:

- `category` — metadata describing where the data belongs
- `data`     — the serialized envelope bytes

### The two logs — don't confuse them
- **`Transcript` log** (`log:` method): local, developer-only messages like
  `"CooHistoryEventRecorder delivered 3 event(s)."` or `"... delivery failed: …"`.
  This is **not** the server log. It only tells you what happened *inside your image*.
- **Server log**: whatever the collector prints. In dev mode the server traces
  the decoded `category` and the stored file path.

To see why a delivery did or did not work from the client side:
```smalltalk
CooHistoryEventRecorder lastDeliveryError.     "the exception, if any"
CooHistoryEventRecorder lastDeliveryResponse.  "the HTTP response, if it went through"
```

---

## 3. The server (the "collector") — `Pharo-XP-EventRecorder`

Startup (`phex-data-collector/start.st`) boots a `ZnServer` on port **9091**,
routing **`/`** to a `PXServerDelegate`. The request flow is:

`PXServerDelegate` → `PXEventRecorderPutHandler` → `PXServerFileStorage`.

### The validation gate — `PXEventRecorderPutHandler>>hasCategoryAndDataParts:`
This is the important part. Before storing anything, the handler:

1. Checks the base rules: the multipart parts must come in `category`/`data`
   pairs, `category` is `text/plain`, `data` is `application/octet-stream`.
2. **Then it STON-decodes the `category` field and requires it to be a
   dictionary containing exactly these four keys**
   (`PXEventMultiBundle metaDataFieldNames`):
   - `category`
   - `experienceId`
   - `participantUUID`
   - `taskOrSurveyId`

If the `category` field is not a STON dictionary with exactly those four keys,
`hasCategoryAndDataParts:` returns `false`, the handler answers **HTTP 400 Bad
Request**, and **nothing is stored**.

### Where files land — `PXServerFileStorage`
On a valid request, those same four values become the directory path:

```
~/px-experiments/data/<category>/<experienceId>/<participantUUID>/<taskOrSurveyId>/<uuid>-<unixtime>
```

The `data` field bytes are written to that file **verbatim, as raw bytes**. The
server does not re-encode them — whatever the client serialized is exactly what
lands on disk.

---

## 4. Why you saw NO data when you clicked "yes" and typed

Two separate causes, both on the client side:

1. **Wrong `category` format (the real blocker).**
   The recorder sent the `category` field as the bare string `'history'`. The
   PX server tried `STON fromString: 'history'`, did not get a 4-key metadata
   dictionary, failed the `hasCategoryAndDataParts:` gate, and returned
   **400 Bad Request**. Every delivery was silently rejected — so the server
   received nothing, and the on-disk tree stayed empty (only stray
   `complishon/complishon` folders from earlier experiments existed, with no
   files inside).

2. **Batch size of 100.**
   Even once the format was correct, the recorder only delivered after
   **100** queued events (`deliveryBatchSize` defaulted to 100). A short typing
   session rarely produces 100 code-change events, so nothing was sent during
   normal use.

---

## 5. Why the stored data was "serialized data I cannot read"

The `data` field is stored **as raw bytes**. The original Pharo-XP /
EventRecorder client serialized its payload with **Fuel** (a *binary* object
format), so the files on disk were opaque binary blobs — unreadable in a text
editor.

This recorder instead serializes with **STON**, which is **human-readable
text**. So once deliveries are accepted, the files written under
`px-experiments/data/...` contain readable STON, e.g.:

```
{ 'schema' : 'coo-history-event-recorder-v1', 'events' : [ { 'kind' : 'method',
  'event' : 'added', 'className' : 'MyClass', 'selector' : 'myMethod', ... } ] }
```

(The `data` MIME part still has to be `application/octet-stream` because the
server's base gate requires it — but the *bytes* inside are UTF-8 STON text, so
the file opens cleanly as text.)

---

## 6. What was changed in this repo

All changes are in
`src/ExtendedHeuristicCompletion-History-Recorder/CooHistoryEventRecorder.class.st`:

1. **Correct `category` field.** New method `categoryFieldValue:` builds a STON
   dictionary with exactly the four keys the server requires
   (`category`, `experienceId`, `participantUUID`, `taskOrSurveyId`).
   `multipartEntityForBytes:category:` now sends that instead of a bare string.
   → The server now **accepts** the request and stores the file.

2. **New configurable metadata.** Added `experienceId`, `participantUUID`
   (defaults to the machine UUID), and `taskOrSurveyId`, with class- and
   instance-side accessors. These control both server acceptance and the
   on-disk folder path.

3. **Immediate delivery.** `defaultDeliveryBatchSize` changed from `100` to
   `1`, so an event is delivered as soon as it is recorded and you see data on
   the server while typing. Raise it again with
   `CooHistoryEventRecorder deliveryBatchSize: n` if you prefer batching.

4. **Readable payload.** The `data` bytes are STON text (unchanged behavior,
   documented here), so stored files are human-readable.

Tests added in
`src/ExtendedHeuristicCompletion-History-Recorder-Tests/CooHistoryEventRecorderTest.class.st`
lock down the new `category` format and the multipart shape.

---

## 7. How to run it against your server

```smalltalk
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'http://127.0.0.1:9091/'.  "server root — matches the '/' route"
CooHistoryEventRecorder category: #history.
CooHistoryEventRecorder experienceId: 'heuristic-completion-history'.
CooHistoryEventRecorder participantUUID: 'participant-01'.
CooHistoryEventRecorder taskOrSurveyId: 'session-1'.
CooHistoryEventRecorder saveOnDisk: false.
CooHistoryEventRecorder install.
```

Then edit a method and check:

```smalltalk
CooHistoryEventRecorder deliverNow.            "force a send"
CooHistoryEventRecorder lastDeliveryError.     "nil means success"
CooHistoryEventRecorder lastDeliveryResponse.  "the HTTP 201 Created response"
```

On the server, a new readable file appears under:

```
~/px-experiments/data/history/heuristic-completion-history/participant-01/session-1/
```

> Note on the URL: the server maps the `/` route. Point `serverUrl` at the
> server **root** (e.g. `http://host:9091/`). A sub-path like `/gt/events`
> would not match the server's `/` mapping and would be rejected.
