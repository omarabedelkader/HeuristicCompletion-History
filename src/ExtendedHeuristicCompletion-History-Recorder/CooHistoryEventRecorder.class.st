"
""
I am the event recorder for the Extended Heuristic Completion history system.

My job is to listen to Pharo code-change announcements and convert them into
history items understood by CooSession.

I do two things at the same time:

1. I record events locally in the history model.

   I listen to the system codeChangeAnnouncer for announcements such as:

     - MethodAdded
     - MethodModified
     - MethodRemoved
     - ClassAdded
     - ClassModified
     - ClassRemoved
     - CoCompletionItemSelected, when available

   For each announcement, I create the corresponding history item:

     - CooAddedMethodHistoryItem
     - CooModifiedMethodHistoryItem
     - CooRemovedMethodHistoryItem
     - CooAddedClassHistoryItem
     - CooRemovedClassHistoryItem

   Then I send the item to CooSession using:

     - CooSession current addMethodItem:
     - CooSession current addClassItem:

   This means the normal history completion system can use the events through
   CooSession selectorEntries and classEntries.

   I do not modify the history package. I only feed it with events.

2. I pass a copy of each event to the existing Pharo-XP EventRecorder stack.

   Every event is converted into a Dictionary, added to my internal
   pendingEvents queue, and, once I am installed, logged through PXEventCollector.

   PXEventCollector uses PXEventRecorder, EventRecorder packing, and the
   Pharo-XP multipart protocol. I do not build the HTTP multipart request myself.

Typical usage:

	CooHistoryEventRecorder reset.
	CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'.
	CooHistoryEventRecorder category: #complishon.
	CooHistoryEventRecorder install.

Events are kept in memory and logged through PXEventCollector. By default,
the recorder asks the logger to deliver when the queue reaches 100 records. The
Metacello first-launch consent flow changes the batch size to 1 after the user
answers Yes, so installed users begin sending events immediately. The recorder
also asks the logger to deliver pending events before the image is saved.

To force delivery manually:

	CooHistoryEventRecorder deliverNow.

To inspect delivery state:

	CooHistoryEventRecorder lastDeliveryError.
	CooHistoryEventRecorder lastDeliveryResponse.

Logging behavior:

Server-side logging depends on the server implementation.

From the server point of view, each delivery is an HTTP PUT request containing a
multipart form. A server that logs only HTTP requests may show something like:

	PUT /complishon 200
	category={#category:#complishon,#experienceId:#complishon,...}
	data=EventRecorder-packed bytes

A server that decodes the data field can log the actual history content, for
example:

	event.kind=method
	event.event=added
	event.className=MyClass
	event.selector=myNewMethod

Delivery failure handling:

When PXEventCollector accepts an event, EventRecorder is responsible for
packing, delivery, and retrying failed HTTP sends. When my call to the logger
raises an exception, I store it in lastDeliveryError and keep the event in
pendingEvents so it can be retried later by sending deliverNow again.

I am meant to be the bridge between:

	Pharo codeChangeAnnouncer
		->
	CooHistoryEventRecorder
		->
	CooSession history
		->
	history-based completion

and, optionally:

	CooHistoryEventRecorder
		->
	PXEventCollector
		->
	PXEventRecorder/EventRecorder
		->
	HTTP server storing the EventRecorder logs
""




# INSTALLATION

Local development against the PX server (pharo-data-collector project):

Start the server in another Pharo image with:

	PXServer start.

It listens on http://localhost:8008 and maps the '/events' endpoint. Then:

```
CooHistoryEventRecorder configureForLocalPXServer.
CooSession install.
CooHistoryEventRecorder install.
CooHistoryEventRecorder enableDelivery.
CooHistoryEventRecorder recordRemoteDeliveryEnabled.
```

Equivalent explicit configuration:

```
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'http://localhost:8008/events'.
CooHistoryEventRecorder category: #complishon.
CooHistoryEventRecorder experienceId: 'complishon'.
CooHistoryEventRecorder participantUUID: UUID new asString.
CooHistoryEventRecorder taskOrSurveyId: 'coding-session-1'.
CooHistoryEventRecorder saveOnDisk: false.
CooHistoryEventRecorder deliveryBatchSize: 1.
CooSession install.
CooHistoryEventRecorder recordRemoteDeliveryEnabled.
```

The Pharo-XP server requires the multipart 'category' field to be a STON/JSON
dictionary carrying exactly these four keys: category, experienceId,
participantUUID and taskOrSurveyId, and every value must be a non-empty
string. These values also define the on-disk directory
data/<category>/<experienceId>/<participantUUID>/<taskOrSurveyId> on the
server. The recorder validates this contract before creating the PX collector
(see validateRemoteConfiguration), so misconfiguration fails fast locally.

The serverUrl path must match the route the server maps. The supplied PXServer
maps '/events', so use 'http://localhost:8008/events' for local development,
not the bare server root.

For the production research server use an explicit setup such as:
```
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'.
CooHistoryEventRecorder category: #complishon.
CooHistoryEventRecorder experienceId: 'complishon'.
CooHistoryEventRecorder participantUUID: 'participant-01'.
CooHistoryEventRecorder taskOrSurveyId: 'session-1'.
CooHistoryEventRecorder saveOnDisk: false.
CooHistoryEventRecorder deliveryBatchSize: 1.
CooSession install.
CooHistoryEventRecorder install.
CooHistoryEventRecorder enableDelivery.
CooHistoryEventRecorder recordRemoteDeliveryEnabled.
```

# CHECKING:
```
CooHistoryEventRecorder installed.
CooHistoryEventRecorder serverUrl.
CooHistoryEventRecorder category.
```


# Force send anything pending:

```
CooHistoryEventRecorder deliverNow.
CooHistoryEventRecorder lastDeliveryError.
CooHistoryEventRecorder lastDeliveryResponse.
```



"
Class {
	#name : 'CooHistoryEventRecorder',
	#superclass : 'Object',
	#instVars : [
		'announcer',
		'logger',
		'installed',
		'serverUrl',
		'category',
		'deliveryEnabled',
		'pendingEvents',
		'deliveryMutex',
		'deliveryProcess',
		'lastDeliveryError',
		'lastDeliveryResponse',
		'deliveryBatchSize',
		'logToTranscript',
		'saveOnDisk',
		'experienceId',
		'participantUUID',
		'taskOrSurveyId'
	],
	#classInstVars : [
		'uniqueInstance',
		'defaultServerUrl',
		'defaultCategory',
		'defaultDeliveryBatchSize',
		'defaultSaveOnDisk',
		'defaultExperienceId',
		'defaultParticipantUUID',
		'defaultTaskOrSurveyId'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'organization' }
CooHistoryEventRecorder class >> category [

	^ self uniqueInstance category
]

{ #category : 'organization' }
CooHistoryEventRecorder class >> category: aSymbolOrString [

	defaultCategory := aSymbolOrString.
	self uniqueInstance category: aSymbolOrString
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> cleanUp [
	
	self reset
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> codeChangeAnnouncer [

	(self environment respondsTo: #codeChangeAnnouncer)
		ifTrue: [ ^ self environment codeChangeAnnouncer ].

	^ SystemAnnouncer uniqueInstance
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> configureForLocalPXServer [
	<script>
	"Configure the recorder to deliver events to a PXServer started locally
	with PXServer start in the pharo-data-collector image. The canonical
	ingest URL of that server is http://localhost:8008/events; the server
	validates that metadata carries exactly category, experienceId,
	participantUUID and taskOrSurveyId as non-empty strings, and persists
	each event under var/data/<category>/<experienceId>/<participantUUID>/
	<taskOrSurveyId>.

	The anonymous participant UUID and task/session id keep their stable
	per-image values (they are generated once on first access). Experiments
	that need explicit study semantics should set them with
	CooHistoryEventRecorder participantUUID: and taskOrSurveyId:."

	self serverUrl: 'http://localhost:8008/events'.
	self category: #complishon.
	self experienceId: 'complishon'.
	self participantUUID ifNil: [
		self participantUUID: UUID new asString ].
	self taskOrSurveyId ifNil: [
		self taskOrSurveyId: UUID new asString ].
	self deliveryBatchSize: 1
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultCategory [

	^ defaultCategory ifNil: [ defaultCategory := #complishon ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultDeliveryBatchSize [

	"Deliver every event as soon as it is recorded so data appears on the
	server during a normal typing session. Raise this with
	CooHistoryEventRecorder deliveryBatchSize: n to batch instead."

	^ defaultDeliveryBatchSize ifNil: [ defaultDeliveryBatchSize := 1 ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultExperienceId [

	^ defaultExperienceId ifNil: [
		  defaultExperienceId := 'complishon' ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultParticipantUUID [

	"Anonymous and stable participant identifier. It is generated once per
	image installation and reused afterwards so all events of a participant
	are routed to the same directory on the PX server. Never derive this
	value from a user name, email address, or machine username."

	^ defaultParticipantUUID ifNil: [
		  defaultParticipantUUID := UUID new asString ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultSaveOnDisk [

	^ defaultSaveOnDisk ifNil: [ defaultSaveOnDisk := false ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultServerUrl [

	"Default server used by the DebuggingSpy/EventRecorder setup.
	Change this with:
		CooHistoryEventRecorder configureForLocalPXServer
	or:
		CooHistoryEventRecorder serverUrl: 'http://localhost:8008/events'
	or:
		CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'"

	^ defaultServerUrl ifNil: [
		  defaultServerUrl := 'https://rmod-xp.lille.inria.fr/complishon' asZnUrl ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultTaskOrSurveyId [

	"Identifier of the current coding task or session. It is generated once
	per image and kept stable so events are not fragmented across task
	directories. Real experiments should inject an explicit identifier with
	CooHistoryEventRecorder taskOrSurveyId:."

	^ defaultTaskOrSurveyId ifNil: [
		  defaultTaskOrSurveyId := UUID new asString ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> deinstall [
	<script>

	self uniqueInstance deinstall
]

{ #category : 'actions' }
CooHistoryEventRecorder class >> deliverLoggerDataNow [

	^ self uniqueInstance deliverLoggerDataNow
]

{ #category : 'actions' }
CooHistoryEventRecorder class >> deliverNow [

	^ self uniqueInstance deliverNow
]

{ #category : 'actions' }
CooHistoryEventRecorder class >> deliverNowInBackground [

	^ self uniqueInstance deliverNowInBackground
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> deliveryBatchSize [

	^ self uniqueInstance deliveryBatchSize
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> deliveryBatchSize: anInteger [

	defaultDeliveryBatchSize := anInteger max: 1.
	self uniqueInstance deliveryBatchSize: defaultDeliveryBatchSize
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> disableDelivery [

	self uniqueInstance disableDelivery
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> enableDelivery [

	self uniqueInstance enableDelivery
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> experienceId [

	^ self uniqueInstance experienceId
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> experienceId: aString [

	defaultExperienceId := aString.
	self uniqueInstance experienceId: aString
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> install [
	<script>

	^ self uniqueInstance install
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> installed [

	^ self uniqueInstance installed
]

{ #category : 'actions' }
CooHistoryEventRecorder class >> lastDeliveryError [

	^ self uniqueInstance lastDeliveryError
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> lastDeliveryResponse [

	^ self uniqueInstance lastDeliveryResponse
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> participantUUID [

	^ self uniqueInstance participantUUID
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> participantUUID: aString [

	defaultParticipantUUID := aString.
	self uniqueInstance participantUUID: aString
]

{ #category : 'actions' }
CooHistoryEventRecorder class >> recordImageCloseSurveyPayload: payloadDictionary [

	^ self uniqueInstance recordImageCloseSurveyPayload: payloadDictionary
]

{ #category : 'actions' }
CooHistoryEventRecorder class >> recordRemoteDeliveryEnabled [

	^ self uniqueInstance recordRemoteDeliveryEnabled
]

{ #category : 'system startup' }
CooHistoryEventRecorder class >> registerForImageLifecycle [

	| sessionManager registered |
	sessionManager := self environment at: #SessionManager ifAbsent: [ nil ].

	registered := sessionManager
		              ifNil: [ false ]
		              ifNotNil: [
			              | manager |
			              manager := sessionManager default.
			              (manager respondsTo: #registerUserClassNamed:)
				              ifTrue: [
					              [
					              manager registerUserClassNamed: self name.
					              true ]
						              on: Error
						              do: [ :ex | false ] ]
				              ifFalse: [
					              (manager respondsTo: #registerSystemClassNamed:)
						              ifTrue: [
							              [
							              manager registerSystemClassNamed: self name.
							              true ]
								              on: Error
								              do: [ :ex | false ] ]
						              ifFalse: [ false ] ] ].

	registered ifTrue: [ ^ self ].

	[
	Smalltalk addToShutDownList: self.
	Smalltalk addToStartUpList: self ]
		on: Error
		do: [ :ex | nil ].

	^ self
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> reset [
	<script>

	uniqueInstance ifNotNil: [
		uniqueInstance deinstall.
		uniqueInstance := nil ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> saveOnDisk [

	^ self uniqueInstance saveOnDisk
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> saveOnDisk: aBoolean [

	defaultSaveOnDisk := aBoolean.
	self uniqueInstance saveOnDisk: aBoolean
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> serverUrl [

	^ self uniqueInstance serverUrl
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> serverUrl: aStringOrZnUrl [

	defaultServerUrl := aStringOrZnUrl asZnUrl.
	self uniqueInstance serverUrl: defaultServerUrl
]

{ #category : 'system startup' }
CooHistoryEventRecorder class >> shutDown: quitting [

	uniqueInstance ifNotNil: [
		quitting ifTrue: [
			CooHistoryImageCloseSurvey
				promptBeforeImageQuitUsing: CooHistoryImageCloseSurvey uiManager
				recorder: uniqueInstance ].
		uniqueInstance prepareForImageSave ]
]

{ #category : 'system startup' }
CooHistoryEventRecorder class >> startUp: resuming [
	CooHistoryImageCloseSurvey resetPromptState.
	resuming ifTrue:[
	(uniqueInstance notNil and: [ uniqueInstance installed ])
		ifTrue: [ uniqueInstance install ]]
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> taskOrSurveyId [

	^ self uniqueInstance taskOrSurveyId
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> taskOrSurveyId: aString [

	defaultTaskOrSurveyId := aString.
	self uniqueInstance taskOrSurveyId: aString
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> uniqueInstance [

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'actions' }
CooHistoryEventRecorder >> announcer [

	^ announcer ifNil: [ announcer := self class codeChangeAnnouncer ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> category [

	^ category ifNil: [ category := self class defaultCategory ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> category: aSymbolOrString [

	category := aSymbolOrString
]

{ #category : 'actions' }
CooHistoryEventRecorder >> categoryFieldValue: aCategory [

	"The Pharo-XP server does not accept a bare category string. Its
	PXEventRecorderPutHandler>>hasCategoryAndDataParts: STON-decodes the
	'category' multipart field and requires a dictionary holding exactly the
	four PXEventMultiBundle metadata keys: category, experienceId,
	participantUUID and taskOrSurveyId, all non-empty. These values also
	become the on-disk directory path
	data/<category>/<experienceId>/<participantUUID>/<taskOrSurveyId>.
	We therefore send a STON-encoded metadata dictionary, not a plain string."

	self validateRemoteConfiguration.
	^ STON toString: (Dictionary new
			  at: 'category' put: aCategory asString;
			  at: 'experienceId' put: self experienceId asString;
			  at: 'participantUUID' put: self participantUUID asString;
			  at: 'taskOrSurveyId' put: self taskOrSurveyId asString;
			  yourself)
]

{ #category : 'events-class' }
CooHistoryEventRecorder >> classAdded: anAnnouncement [

	self
		addClassItemOf: CooAddedClassHistoryItem
		from: anAnnouncement
		selectors: #(classAdded classAffected affectedClass behaviorAffected behavior)

]

{ #category : 'events-class' }
CooHistoryEventRecorder >> classModified: anAnnouncement [

	(self class environment includesKey: #CooModifiedClassHistoryItem)
		ifFalse: [ ^ self ].

	self
		addClassItemOf: CooModifiedClassHistoryItem
		from: anAnnouncement
		selectors: #(classModified classAffected affectedClass behaviorAffected behavior)

]

{ #category : 'helpers' }
CooHistoryEventRecorder >> classNameFrom: anAnnouncement selectors: selectorSymbols [

	selectorSymbols do: [ :eachSelector |
		| value |
		value := self valueFrom: anAnnouncement selector: eachSelector.
		value ifNotNil: [ ^ self normalizedClassNameFrom: value ] ].

	^ nil
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> classNameFromMethod: aCompiledMethod announcement: anAnnouncement [

	| methodClass |
	methodClass := self valueFrom: aCompiledMethod selector: #methodClass.
	methodClass ifNotNil: [ ^ self normalizedClassNameFrom: methodClass ].

	^ self
		  classNameFrom: anAnnouncement
		  selectors: #(methodClass classAffected affectedClass behaviorAffected behavior classRemoved classAdded)
]

{ #category : 'events-class' }
CooHistoryEventRecorder >> classRemoved: anAnnouncement [

	self
		addClassItemOf: CooRemovedClassHistoryItem
		from: anAnnouncement
		selectors: #(classRemoved classAffected affectedClass behaviorAffected behavior)
]

{ #category : 'actions' }
CooHistoryEventRecorder >> clearPendingEvents [

	deliveryMutex critical: [ pendingEvents removeAll ].
	^ self
]

{ #category : 'initialization' }
CooHistoryEventRecorder >> configureEventRecorderSettings [

	EREventRecorderSettings url: self serverUrl.
	^ self
]

{ #category : 'installation' }
CooHistoryEventRecorder >> deinstall [

	announcer ifNotNil: [ announcer unsubscribe: self ].
	Iceberg announcer unsubscribe: self.
	logger ifNotNil: [
		(logger respondsTo: #liberate)
			ifTrue: [ logger liberate ] ].
	installed := false
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliverLoggerDataNow [

	PXEventRecorder uniqueInstance delivery packAndDeliver: false.
	^ self
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliverNow [

	| eventLogger |
	self deliveryEnabled ifFalse: [ ^ self ].
	self installed ifFalse: [ ^ self ].
	pendingEvents isEmpty ifTrue: [ ^ self ].

	[
		eventLogger := self logger.
		self deliverLoggerDataNow.
		lastDeliveryResponse := eventLogger.
		lastDeliveryError := nil.
		self clearPendingEvents
	]
		on: Error
		do: [ :ex |
			lastDeliveryError := ex.
			lastDeliveryResponse := nil ].

	^ lastDeliveryResponse
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliverNowInBackground [

	self deliveryEnabled ifFalse: [ ^ self ].

	deliveryMutex critical: [
		(deliveryProcess notNil and: [ deliveryProcess isTerminated not ])
			ifTrue: [ ^ self ].

		deliveryProcess := [
			self deliverNow
		] forkAt: Processor userBackgroundPriority named: 'CooHistoryEventRecorder delivery' ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> deliveryBatchSize [

	^ deliveryBatchSize ifNil: [
		  deliveryBatchSize := self class defaultDeliveryBatchSize ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> deliveryBatchSize: anInteger [

	deliveryBatchSize := anInteger max: 1
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliveryEnabled [

	^ deliveryEnabled ifNil: [ deliveryEnabled := true ]
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliveryEnabled: aBoolean [

	deliveryEnabled := aBoolean 
]

{ #category : 'events-class' }
CooHistoryEventRecorder >> deliveryProcess [ 
	^ deliveryProcess
]

{ #category : 'serializing' }
CooHistoryEventRecorder >> dictionaryForClassItem: item announcement: anAnnouncement [

	| dictionary |
	dictionary := Dictionary new.
	dictionary at: #kind put: #class.
	dictionary at: #event put: item event.
	dictionary at: #className put: item nameOfClass.
	dictionary at: #timestamp put: item timestamp asString.
	dictionary at: #live put: true.
	dictionary at: #announcementClass put: anAnnouncement class name.
	^ dictionary
]

{ #category : 'serializing' }
CooHistoryEventRecorder >> dictionaryForCompletionItem: anItem [

	| dictionary |

   dictionary := Dictionary new.
   dictionary at: #kind put: #completion.
   dictionary at: #timestamp put: DateAndTime now asString.

   dictionary at: #token put: (self safeValue: [ anItem token asString ] ifError: [ nil ]).
   dictionary at: #index put: (self safeValue: [ anItem index ] ifError: [ nil ]).
   dictionary at: #selectedItem put: (self safeValue: [ anItem selectedItem asString ] ifError: [ nil ]).
	dictionary at: #fetchers put: (self safeValue: [ anItem fetchers ] ifError: [ #() ]).
	dictionary at: #choices put: (self safeValue: [ anItem choices collect: [ :each | each asString ] ] ifError: [ #() ]).
   ^ dictionary
]

{ #category : 'serializing' }
CooHistoryEventRecorder >> dictionaryForImageCloseSurveyPayload: payloadDictionary [

	| dictionary |
	dictionary := Dictionary new.
	dictionary at: #kind put: #survey.
	dictionary at: #event put: #imageCloseSurvey.
	dictionary at: #timestamp put: DateAndTime now asString.
	dictionary at: #serverUrl put: self serverUrl asString.
	dictionary at: #category put: self category asString.
	dictionary at: #payload put: payloadDictionary.
	^ dictionary
]

{ #category : 'serializing' }
CooHistoryEventRecorder >> dictionaryForMethodItem: item announcement: anAnnouncement [

	| dictionary |
	dictionary := Dictionary new.
	dictionary at: #kind put: #method.
	dictionary at: #event put: item event.
	dictionary at: #className put: item nameOfClass.
	dictionary at: #selector put: item selector asString.
	dictionary at: #timestamp put: item timestamp asString.
	dictionary at: #live put: true.
	dictionary at: #deltaMessages put: (item deltaMessages collect: [ :each | each asString ]) asArray.
	dictionary at: #announcementClass put: anAnnouncement class name.
	^ dictionary
]

{ #category : 'serializing' }
CooHistoryEventRecorder >> dictionaryForRecorderEvent: anEventSymbol [

	| dictionary |
	dictionary := Dictionary new.
	dictionary at: #kind put: #recorder.
	dictionary at: #event put: anEventSymbol.
	dictionary at: #timestamp put: DateAndTime now asString.
	dictionary at: #serverUrl put: self serverUrl asString.
	dictionary at: #category put: self category asString.
	^ dictionary
]

{ #category : 'actions' }
CooHistoryEventRecorder >> disableDelivery [

	deliveryEnabled := false.
	CooSession current recorder: CooNullHistoryEventRecorder uniqueInstance.
]

{ #category : 'actions' }
CooHistoryEventRecorder >> drainPendingEvents [

	| events |
	events := OrderedCollection new.

	deliveryMutex critical: [
		events addAll: pendingEvents.
		pendingEvents removeAll ].

	^ events
]

{ #category : 'actions' }
CooHistoryEventRecorder >> enableDelivery [
	deliveryEnabled := true.
	CooSession current recorder: self class uniqueInstance
]

{ #category : 'actions' }
CooHistoryEventRecorder >> enqueueEvent: anEventDictionary [

	| shouldDeliver |
	deliveryMutex critical: [
		pendingEvents addLast: anEventDictionary.
		shouldDeliver := self shouldDeliverPendingEvents ].

	(self installed and: [ self deliveryEnabled ])
		ifTrue: [ self logEvent: anEventDictionary ].

	shouldDeliver ifTrue: [ self deliverNowInBackground ].
	^ self
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> experienceId [

	^ experienceId ifNil: [ experienceId := self class defaultExperienceId ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> experienceId: aString [

	experienceId := aString
]

{ #category : 'actions' }
CooHistoryEventRecorder >> flush [

    pendingEvents isEmpty ifTrue: [ ^ self ].
    self deliverNowInBackground.
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> includesInstanceOf: aClass in: aCollection [

	^ aCollection anySatisfy: [ :each | each class = aClass ]
]

{ #category : 'initialization' }
CooHistoryEventRecorder >> initialize [

	super initialize.
	serverUrl := self class defaultServerUrl.
	category := self class defaultCategory.
	deliveryEnabled := true.
	pendingEvents := OrderedCollection new.
	deliveryMutex := Mutex new.
	installed := false.
	deliveryBatchSize := self class defaultDeliveryBatchSize.
	saveOnDisk := self class defaultSaveOnDisk.
	experienceId := self class defaultExperienceId.
	participantUUID := self class defaultParticipantUUID.
	taskOrSurveyId := self class defaultTaskOrSurveyId.
	logToTranscript := true
]

{ #category : 'actions' }
CooHistoryEventRecorder >> install [

	self deinstall.
	self class registerForImageLifecycle.

	Iceberg announcer unsubscribe: self.
	
	Iceberg announcer when: IceCommited send: #onIcePushed: to: self. 
	

	installed := true.

	self resetEventRecorderTransport.
	logger := self newLogger.
	

	^ self
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> installed [

	^ installed
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> lastDeliveryError [

	^ lastDeliveryError
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> lastDeliveryResponse [

	^ lastDeliveryResponse
]

{ #category : 'actions' }
CooHistoryEventRecorder >> logEvent: anEventDictionary [

	| eventLogger |
	[
		eventLogger := self logger.
		(eventLogger respondsTo: #add:)
			ifTrue: [ eventLogger add: anEventDictionary ]
			ifFalse: [ eventLogger log: anEventDictionary ].
		lastDeliveryError := nil ]
		on: Error
		do: [ :ex | lastDeliveryError := ex ].
	^ self
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> logger [

	^ logger ifNil: [ logger := self newLogger ]
]

{ #category : 'actions' }
CooHistoryEventRecorder >> multipartEntityForBytes: aByteArray category: aCategory [

	| entity |
	entity := ZnMultiPartFormDataEntity new.

	entity
		addPart: (ZnMimePart
				 fieldName: 'category'
				 value: (self categoryFieldValue: aCategory));
		addPart: (ZnMimePart fieldName: 'data' entity: (ZnByteArrayEntity bytes: aByteArray)).

	^ entity
]

{ #category : 'initialization' }
CooHistoryEventRecorder >> newLogger [

	| eventCollector |
	self validateRemoteConfiguration.
	ERPrivacy sendDiagnosticsAndUsageData: true.
	self configureEventRecorderSettings.

	eventCollector := PXEventCollector new.
	eventCollector
		url: self serverUrl;
		category: self category asString;
		experienceId: self experienceId asString;
		participantUUID: self participantUUID asString;
		taskOrSurveyId: self taskOrSurveyId asString;
		occupant: self;
		register.
	^ eventCollector
]

{ #category : 'actions' }
CooHistoryEventRecorder >> normalizedClassNameFrom: anObject [

	| name |
	anObject ifNil: [ ^ nil ].

	name := (anObject respondsTo: #name)
		        ifTrue: [ anObject name ]
		        ifFalse: [ anObject asString ].

	name := name asString.

	(name beginsWith: 'AnObsolete')
		ifTrue: [ name := name allButFirst: 'AnObsolete' size ].

	^ name
]

{ #category : 'events-methods' }
CooHistoryEventRecorder >> oldMethodFrom: anAnnouncement [

	#(oldMethod previousMethod oldCompiledMethod) do: [ :eachSelector |
		| value |
		value := self valueFrom: anAnnouncement selector: eachSelector.
		(value notNil and: [ value respondsTo: #selector ])
			ifTrue: [ ^ value ] ].

	^ nil
]

{ #category : 'actions' }
CooHistoryEventRecorder >> onIcePushed: anIcePushedAnnouncement [

    self flush.
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> participantUUID [

	^ participantUUID ifNil: [ participantUUID := self class defaultParticipantUUID ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> participantUUID: aString [

	participantUUID := aString
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> pendingEvents [
	^ pendingEvents 
]

{ #category : 'system startup' }
CooHistoryEventRecorder >> prepareForImageSave [

	self waitForDeliveryProcess.
	self deliverNow.
	lastDeliveryError 
		ifNil: [ self clearPendingEvents. ].

	^ self
]

{ #category : 'printing' }
CooHistoryEventRecorder >> printOn: aStream [

	super printOn: aStream.
	aStream
		space;
		nextPutAll: (installed ifTrue: [ 'installed' ] ifFalse: [ 'not installed' ]);
		space;
		nextPutAll: 'server=';
		nextPutAll: self serverUrl asString;
		space;
		nextPutAll: 'pending=';
		print: pendingEvents size
]

{ #category : 'actions' }
CooHistoryEventRecorder >> recordImageCloseSurveyPayload: payloadDictionary [

	self enqueueEvent: (self dictionaryForImageCloseSurveyPayload: payloadDictionary).
	^ self
]

{ #category : 'actions' }
CooHistoryEventRecorder >> recordRecorderEvent: anEventSymbol [

	self enqueueEvent: (self dictionaryForRecorderEvent: anEventSymbol).
	^ self
]

{ #category : 'actions' }
CooHistoryEventRecorder >> recordRemoteDeliveryEnabled [

	^ self recordRecorderEvent: #remoteDeliveryEnabled
]

{ #category : 'actions' }
CooHistoryEventRecorder >> requeueEvents: events [

	deliveryMutex critical: [
		pendingEvents := events asOrderedCollection , pendingEvents ]

]

{ #category : 'actions' }
CooHistoryEventRecorder >> resetEventRecorderTransport [

	| recorderClass |
	recorderClass := self class environment
		                 at: #PXEventRecorder
		                 ifAbsent: [ nil ].
	recorderClass ifNil: [ ^ self ].

	[
	recorderClass reset ]
		on: Error
		do: [ :ex | nil ].

	^ self
]

{ #category : 'actions' }
CooHistoryEventRecorder >> safeValue: aBlock ifError: errorBlock [

	^ [ aBlock value ]
		  on: Error
		  do: [ :ex | errorBlock value ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> saveOnDisk [

	^ saveOnDisk ifNil: [ saveOnDisk := self class defaultSaveOnDisk ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> saveOnDisk: aBoolean [

	saveOnDisk := aBoolean
]

{ #category : 'events-methods' }
CooHistoryEventRecorder >> selectorOf: aCompiledMethod [

	^ self valueFrom: aCompiledMethod selector: #selector
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> selectorOf: aCompiledMethod announcement: anAnnouncement [

	| selector |
	selector := self valueFrom: aCompiledMethod selector: #selector.
	selector ifNotNil: [ ^ selector ].

	#(selector methodSelector) do: [ :eachSelector |
		| value |
		value := self valueFrom: anAnnouncement selector: eachSelector.
		value ifNotNil: [ ^ value ] ].

	^ nil
]

{ #category : 'actions' }
CooHistoryEventRecorder >> serializePayload: payloadDictionary [

	| string ston |
	ston := self class environment at: #STON ifAbsent: [ nil ].

	string := ston
		          ifNil: [ payloadDictionary printString ]
		          ifNotNil: [ ston toString: payloadDictionary ].

	^ [ string utf8Encoded ]
		  on: Error
		  do: [ :ex | string asByteArray ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> serverUrl [

	^ serverUrl ifNil: [ serverUrl := self class defaultServerUrl ]

]

{ #category : 'accessing' }
CooHistoryEventRecorder >> serverUrl: aStringOrZnUrl [

	serverUrl := aStringOrZnUrl asZnUrl
]

{ #category : 'actions' }
CooHistoryEventRecorder >> shouldDeliverPendingEvents [

	^ self deliveryEnabled and: [
		  pendingEvents size >= self deliveryBatchSize ]
]

{ #category : 'installation' }
CooHistoryEventRecorder >> subscribeAnnouncementNamed: announcementName send: selector [

	| announcementClass |
	announcementClass := self class environment
		                     at: announcementName
		                     ifAbsent: [ ^ self ].

	(announcementClass inheritsFrom: Announcement)
		ifFalse: [ ^ self ].

	self announcer
		when: announcementClass
		send: selector
		to: self.

	^ self
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> taskOrSurveyId [

	^ taskOrSurveyId ifNil: [ taskOrSurveyId := self class defaultTaskOrSurveyId ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> taskOrSurveyId: aString [

	taskOrSurveyId := aString
]

{ #category : 'initialization' }
CooHistoryEventRecorder >> validateRemoteConfiguration [

	"The Pharo-XP server accepts an upload only when its metadata carries
	exactly category, experienceId, participantUUID and taskOrSurveyId and
	every value is a non-empty String (see
	PXEventRecorderPutHandler>>isValidMetadata: on the server side).
	Validate that contract here, before PXEventCollector is created and
	registered, so misconfiguration fails fast with a clear error in this
	image instead of a cryptic HTTP failure later."

	self category ifNil: [
		self error: 'History telemetry requires a category' ].
	self category asString isEmpty ifTrue: [
		self error: 'History telemetry category cannot be empty' ].

	self experienceId ifNil: [
		self error: 'History telemetry requires an experienceId' ].
	self experienceId asString isEmpty ifTrue: [
		self error: 'History telemetry experienceId cannot be empty' ].

	self participantUUID ifNil: [
		self error: 'History telemetry requires a participantUUID' ].
	self participantUUID asString isEmpty ifTrue: [
		self error: 'History telemetry participantUUID cannot be empty' ].

	self taskOrSurveyId ifNil: [
		self error: 'History telemetry requires a taskOrSurveyId' ].
	self taskOrSurveyId asString isEmpty ifTrue: [
		self error: 'History telemetry taskOrSurveyId cannot be empty' ]
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> valueFrom: anObject selector: selector [

	anObject ifNil: [ ^ nil ].
	(anObject respondsTo: selector) ifFalse: [ ^ nil ].

	^ [ anObject perform: selector ]
		  on: Error
		  do: [ :ex | nil ]
]

{ #category : 'actions' }
CooHistoryEventRecorder >> waitForDeliveryProcess [

	(deliveryProcess isNil or: [ deliveryProcess == Processor activeProcess ])
		ifTrue: [ ^ self ].

	[ deliveryProcess isTerminated ]
		whileFalse: [ (Delay forMilliseconds: 50) wait ].

	^ self
]
