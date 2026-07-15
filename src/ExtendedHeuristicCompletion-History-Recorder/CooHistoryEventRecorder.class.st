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

2. I pass a copy of each event to the existing ExperimentModel recorder stack.

   Every event is converted into a Dictionary, added to my internal
   pendingEvents queue, and, once I am installed, logged through
   EMEventRecorderLogger.

   EMEventRecorderLogger uses PXEventCollector, PXEventRecorder, EventRecorder
   packing, and the Pharo-XP multipart protocol. I do not build the HTTP
   multipart request myself.

Typical usage:

	CooHistoryEventRecorder reset.
	CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'.
	CooHistoryEventRecorder category: #complishon.
	CooHistoryEventRecorder install.

Events are kept in memory and logged through EMEventRecorderLogger. By default,
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

When EMEventRecorderLogger accepts an event, EventRecorder is responsible for
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
	EMEventRecorderLogger
		->
	PXEventRecorder/EventRecorder
		->
	HTTP server storing the EventRecorder logs
""



# INSTALLATION

Installation:
```
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'http://127.0.0.1:8080'.
CooHistoryEventRecorder category: #complishon.
CooHistoryEventRecorder install.
```

```
CooHistoryEventRecorder reset.
CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'.
CooHistoryEventRecorder category: #complishon.
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

	^ defaultCategory ifNil: [ defaultCategory := #complishon ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultDeliveryBatchSize [

	^ defaultDeliveryBatchSize ifNil: [ defaultDeliveryBatchSize := 100 ]
]

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> defaultServerUrl [

	"Default server used by the DebuggingSpy/EventRecorder setup.
	Change this with:
		CooHistoryEventRecorder serverUrl: 'http://localhost:8080'
	or:
		CooHistoryEventRecorder serverUrl: 'https://rmod-xp.lille.inria.fr/complishon'"

	^ defaultServerUrl ifNil: [
		  defaultServerUrl := 'https://rmod-xp.lille.inria.fr/complishon' asZnUrl ]
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

{ #category : 'actions' }
CooHistoryEventRecorder class >> recordRemoteDeliveryEnabled [

	^ self uniqueInstance recordRemoteDeliveryEnabled
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
CooHistoryEventRecorder >> deliverLoggerDataNow [

	PXEventRecorder uniqueInstance delivery packAndDeliver: false.
	^ self
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
CooHistoryEventRecorder >> recordRecorderEvent: anEventSymbol [

	self enqueueEvent: (self dictionaryForRecorderEvent: anEventSymbol).
	^ self
]

{ #category : 'actions' }
CooHistoryEventRecorder >> recordRemoteDeliveryEnabled [

	^ self recordRecorderEvent: #remoteDeliveryEnabled
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
]

{ #category : 'actions' }
CooHistoryEventRecorder >> install [

	self deinstall.
	self class registerForImageLifecycle.

	Iceberg announcer unsubscribe: self.
	
	Iceberg announcer when: IceCommited send: #onIcePushed: to: self. 
	

	installed := true.
	
	logger := self newLogger.
	

	^ self
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> logger [

	^ logger ifNil: [ logger := self newLogger ]
]

{ #category : 'actions' }
CooHistoryEventRecorder >> logEvent: anEventDictionary [

	[
		self logger log: anEventDictionary.
		lastDeliveryError := nil ]
		on: Error
		do: [ :ex | lastDeliveryError := ex ].
	^ self
]

{ #category : 'initialization' }
CooHistoryEventRecorder >> configureEventRecorderSettings [

	EREventRecorderSettings url: self serverUrl.
	^ self
]

{ #category : 'initialization' }
CooHistoryEventRecorder >> newLogger [

	| eventRecorderLogger |
	eventRecorderLogger := EMEventRecorderLogger new.
	self configureEventRecorderSettings.
	eventRecorderLogger authorizeDataSending.
	^ eventRecorderLogger
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
