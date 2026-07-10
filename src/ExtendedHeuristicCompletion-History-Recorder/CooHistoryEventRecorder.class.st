"
""
I am a self-contained event recorder for the Extended Heuristic Completion history system.

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

2. I send a serialized copy of the events to a remote server.

   Every event is also converted into a Dictionary and added to my internal
   pendingEvents queue.

   The queued events are wrapped in an envelope dictionary with metadata such as:

     - schema name
     - recorder class name
     - timestamp
     - category
     - image information
     - session information
     - the list of recorded events

   The envelope is serialized using STON when STON is available. If STON is not
   available, I fall back to printString.

   The serialized bytes are sent to the serverUrl using an HTTP PUT request.

   The HTTP request uses the same general wire shape as the old EventRecorder
   server protocol: multipart/form-data with two fields:

     - category
     - data

   The category field contains my category, usually #history.
   The data field contains the serialized event envelope.

Typical usage:

	CooHistoryEventRecorder reset.
	CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/'.
	CooHistoryEventRecorder category: #history.
	CooHistoryEventRecorder saveOnDisk: false.
	CooHistoryEventRecorder install.

Events are kept in memory and sent in batches. By default, the recorder sends
pending events when the queue reaches 100 records. It also tries to send pending
events before the image is saved. When saveOnDisk is false, pending events are
cleared before the image is saved so event data is not persisted in the image
file.

To force delivery manually:

	CooHistoryEventRecorder deliverNow.

To inspect delivery state:

	CooHistoryEventRecorder lastDeliveryError.
	CooHistoryEventRecorder lastDeliveryResponse.

Logging behavior:

I log locally to the Pharo Transcript when logToTranscript is true.

The local Transcript logs are only diagnostic messages for the developer. They
tell whether I was installed, whether delivery succeeded, or whether delivery
failed.

Examples of local Transcript logs:

	CooHistoryEventRecorder installed. Server: https://rmod-xp.lille.inria.fr/
	CooHistoryEventRecorder delivered 1 event(s).
	CooHistoryEventRecorder delivery failed: ConnectionTimedOut: ...

These Transcript messages are not the server log. They only describe what
happened inside the Pharo image.

Server-side logging depends on the server implementation.

From the server point of view, each delivery is an HTTP PUT request containing a
multipart form. A server that logs only HTTP requests may show something like:

	PUT /gt/events 200
	category=history
	data=1842 bytes

A server that decodes the data field can log the actual history content, for
example:

	schema=coo-history-event-recorder-v1
	event.kind=method
	event.event=added
	event.className=MyClass
	event.selector=myNewMethod

Delivery failure handling:

When delivery succeeds, the sent events are removed from pendingEvents.

When delivery fails, I store the exception in lastDeliveryError and put the
events back into pendingEvents, so they can be retried later by sending
deliverNow again.

I intentionally do not depend on DebuggingSpy, PXEventRecorder,
PXEventCollector, EREventRecorderSettings, ERPrivacy, or the old EventRecorder
delivery classes. This makes me usable in Pharo 14 even when those classes do
not exist.

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
	HTTP server storing the serialized event logs
""



# INSTALLATION

Installation:
```
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'http://127.0.0.1:8080/gt/events'.
CooHistoryEventRecorder category: #history.
CooHistoryEventRecorder saveOnDisk: false.
CooHistoryEventRecorder install.
```

```
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/'.
CooHistoryEventRecorder category: #history.
CooHistoryEventRecorder saveOnDisk: false.
CooHistoryEventRecorder install.
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
		'deliveryBatchSize'
	],
	#classInstVars : [
		'uniqueInstance',
		'defaultServerUrl',
		'defaultCategory',
		'defaultDeliveryBatchSize'
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
CooHistoryEventRecorder class >> defaultCategory [

	^ defaultCategory ifNil: [ defaultCategory := #history ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultDeliveryBatchSize [

	^ defaultDeliveryBatchSize ifNil: [ defaultDeliveryBatchSize := 100 ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultServerUrl [

	"Default server used by the DebuggingSpy/EventRecorder setup.
	Change this with:
		CooHistoryEventRecorder serverUrl: 'http://localhost:8080/gt/events'
	or:
		CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/'"

	^ defaultServerUrl ifNil: [
		  defaultServerUrl := 'https://rmod-xp.lille.inria.fr/' asZnUrl ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> deinstall [
	<script>

	self uniqueInstance deinstall
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

	uniqueInstance ifNotNil: [ uniqueInstance prepareForImageSave ]
]

{ #category : 'system startup' }
CooHistoryEventRecorder class >> startUp: resuming [
	resuming ifTrue:[
	(uniqueInstance notNil and: [ uniqueInstance installed ])
		ifTrue: [ uniqueInstance install ]]
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> uniqueInstance [

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
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
CooHistoryEventRecorder >> clearPendingEvents [

	deliveryMutex critical: [ pendingEvents removeAll ].
	^ self
]

{ #category : 'installation' }
CooHistoryEventRecorder >> deinstall [

	installed := false
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliverNow [

	| events payload bytes |
	self deliveryEnabled ifFalse: [ ^ self ].

	events := self drainPendingEvents.
	events isEmpty ifTrue: [ ^ self ].

	payload := self envelopeFor: events.
	bytes := self serializePayload: payload.

	[
		logger log: bytes.
		lastDeliveryError := nil.
	]
		on: Error
		do: [ :ex |
			lastDeliveryError := ex.
			self requeueEvents: events.].

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

	^ true
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

{ #category : 'actions' }
CooHistoryEventRecorder >> disableDelivery [

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
	CooSession current recorder ifNil: [ CooSession current recorder: self class uniqueInstance ]
]

{ #category : 'actions' }
CooHistoryEventRecorder >> enqueueEvent: anEventDictionary [

	| shouldDeliver |
	deliveryMutex critical: [
		pendingEvents addLast: anEventDictionary.
		shouldDeliver := self shouldDeliverPendingEvents ].

	shouldDeliver ifTrue: [ self deliverNowInBackground ].
	^ self
]

{ #category : 'actions' }
CooHistoryEventRecorder >> envelopeFor: eventDictionaries [

	| envelope |
	envelope := Dictionary new.
	envelope at: #schema put: 'coo-history-event-recorder-v1'.
	envelope at: #recorder put: self class name.
	envelope at: #timestamp put: DateAndTime now asString.
	envelope at: #category put: self category asString.
	envelope at: #image put: self imageInfo.
	envelope at: #events put: eventDictionaries asArray.
	^ envelope
]

{ #category : 'actions' }
CooHistoryEventRecorder >> flush [

    pendingEvents isEmpty ifTrue: [ ^ self ].
    self deliverNowInBackground.
]

{ #category : 'actions' }
CooHistoryEventRecorder >> imageInfo [

	| info |
	info := Dictionary new.
	info at: #imageVersion put: (self safeValue: [ SystemVersion current version asString ] ifError: [ nil ]).
	info at: #latestUpdate put: (self safeValue: [ SystemVersion current commitHash asString ] ifError: [ nil ]).
	info at: #imageHash put: (self safeValue: [ SmalltalkImage current imagePath hash ] ifError: [ nil ]).
	info at: #sessionUUID put: (self safeValue: [ SmalltalkImage current session id asString ] ifError: [ nil ]).
	info at: #sessionCreationTime put: (self safeValue: [ SmalltalkImage current session creationTime asString ] ifError: [ nil ]).
	info at: #computerUUID put: (self safeValue: [ GlobalIdentifier uniqueInstance computerUUID asString ] ifError: [ nil ]).
	^ info
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
]

{ #category : 'actions' }
CooHistoryEventRecorder >> install [

	self deinstall.
	self class registerForImageLifecycle.

	Iceberg announcer unsubscribe: self.
	
	Iceberg announcer when: IceCommited send: #onIcePushed: to: self. 
	

	installed := true.
	
	logger := EMEventRecorderLogger new.
	
	logger authorizeDataSending.
	

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
CooHistoryEventRecorder >> onIcePushed: anIcePushedAnnouncement [

    self flush.
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
CooHistoryEventRecorder >> requeueEvents: events [

	deliveryMutex critical: [
		pendingEvents := events asOrderedCollection , pendingEvents ]

]

{ #category : 'actions' }
CooHistoryEventRecorder >> safeValue: aBlock ifError: errorBlock [

	^ [ aBlock value ]
		  on: Error
		  do: [ :ex | errorBlock value ]
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

{ #category : 'actions' }
CooHistoryEventRecorder >> waitForDeliveryProcess [

	(deliveryProcess isNil or: [ deliveryProcess == Processor activeProcess ])
		ifTrue: [ ^ self ].

	[ deliveryProcess isTerminated ]
		whileFalse: [ (Delay forMilliseconds: 50) wait ].

	^ self
]
