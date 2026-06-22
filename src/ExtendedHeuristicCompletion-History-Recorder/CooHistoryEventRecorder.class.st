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
		'session',
		'announcer',
		'installed',
		'serverUrl',
		'category',
		'deliveryEnabled',
		'pendingEvents',
		'deliveryMutex',
		'deliveryProcess',
		'lastDeliveryError',
		'lastDeliveryResponse',
		'logToTranscript',
		'saveOnDisk',
		'deliveryBatchSize'
	],
	#classInstVars : [
		'uniqueInstance',
		'defaultServerUrl',
		'defaultCategory',
		'defaultSaveOnDisk',
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
CooHistoryEventRecorder class >> defaultSaveOnDisk [

	^ defaultSaveOnDisk ifNil: [ defaultSaveOnDisk := false ]
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

{ #category : 'actions' }
CooHistoryEventRecorder class >> deliverNow [

	^ self uniqueInstance deliverNow
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

{ #category : 'cleanup' }
CooHistoryEventRecorder class >> reset [
	<script>

	uniqueInstance ifNotNil: [
		uniqueInstance deinstall.
		uniqueInstance := nil ]
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

	uniqueInstance ifNotNil: [ uniqueInstance prepareForImageSave ]
]

{ #category : 'system startup' }
CooHistoryEventRecorder class >> startUp: resuming [

	(uniqueInstance notNil and: [ uniqueInstance installed ])
		ifTrue: [ uniqueInstance install ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder class >> uniqueInstance [

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'events-class' }
CooHistoryEventRecorder >> addClassItemOf: aHistoryItemClass from: anAnnouncement selectors: selectorSymbols [

	| className item |
	className := self classNameFrom: anAnnouncement selectors: selectorSymbols.
	className ifNil: [ ^ self ].

	item := aHistoryItemClass new
		        nameOfClass: className;
		        live: true;
		        timestamp: DateAndTime now;
		        yourself.

	self recordClassItem: item announcement: anAnnouncement
]

{ #category : 'events-class' }
CooHistoryEventRecorder >> addMethodItemOf: aHistoryItemClass from: anAnnouncement oldMethod: oldCompiledMethod [

	| method selector className ast oldAst deltaMessages item |
	method := self methodFrom: anAnnouncement.
	method ifNil: [ ^ self ].


	selector := self selectorOf: method announcement: anAnnouncement.
	selector ifNil: [ ^ self ].

	className := self classNameFromMethod: method announcement: anAnnouncement.
	className ifNil: [ ^ self ].

	ast := self astOf: method.
	oldAst := self astOf: oldCompiledMethod.
	deltaMessages := self deltaMessagesFor: ast oldAst: oldAst.

	item := aHistoryItemClass new
		        selector: selector;
		        nameOfClass: className;
		        live: true;
		        timestamp: DateAndTime now;
		        yourself.

	ast ifNotNil: [ item ast: ast ].
	deltaMessages ifNotEmpty: [ item deltaMessages: deltaMessages ].

	self recordMethodItem: item announcement: anAnnouncement
]

{ #category : 'actions' }
CooHistoryEventRecorder >> announcer [
	^ announcer
]

{ #category : 'actions' }
CooHistoryEventRecorder >> announcer: anAnnouncer [ 
	announcer := anAnnouncer.
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> astOf: aCompiledMethod [

	aCompiledMethod ifNil: [ ^ nil ].

	^ [ aCompiledMethod ast ]
		  on: Error
		  do: [ :ex |
			  [ aCompiledMethod sourceNode ]
				  on: Error
				  do: [ :ex2 |
					  [ OCParser parseMethod: aCompiledMethod sourceCode ]
						  on: Error
						  do: [ :ex3 | nil ] ] ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> category [

	^ category ifNil: [ category := self class defaultCategory ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> category: aSymbolOrString [ 

	category := aSymbolOrString
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

{ #category : 'events-completion' }
CooHistoryEventRecorder >> completionItemSelected: anAnnouncement [

	"Keep the history-side completion interaction if the announcement has the shape CooSession expects."

	[ self session addCompletionItem: anAnnouncement ]
		on: Error
		do: [ :ex | "Do not break completion if the announcement shape changed." ].

	self enqueueEvent: (self dictionaryForCompletionAnnouncement: anAnnouncement)
]

{ #category : 'installation' }
CooHistoryEventRecorder >> deinstall [

	announcer ifNotNil: [ announcer unsubscribe: self ].
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
		lastDeliveryResponse := self putBytes: bytes category: self category.
		lastDeliveryError := nil.
		self log: 'CooHistoryEventRecorder delivered ', events size printString, ' event(s).'
	]
		on: Error
		do: [ :ex |
			lastDeliveryError := ex.
			self requeueEvents: events.
			self log: 'CooHistoryEventRecorder delivery failed: ', ex description ].

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

{ #category : 'actions' }
CooHistoryEventRecorder >> deliveryEnabled [

	^ deliveryEnabled
]

{ #category : 'actions' }
CooHistoryEventRecorder >> deliveryEnabled: aBoolean [

	deliveryEnabled := aBoolean 
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

{ #category : 'events-class' }
CooHistoryEventRecorder >> deliveryProcess [ 
	^ deliveryProcess
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> deltaMessagesFor: newAst oldAst: oldAst [

	| newMessages oldMessages |
	newAst ifNil: [ ^ #() ].

	newMessages := self messageSelectorsIn: newAst.
	oldAst ifNil: [ ^ newMessages ].

	oldMessages := self messageSelectorsIn: oldAst.
	^ newMessages difference: oldMessages
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
CooHistoryEventRecorder >> dictionaryForCompletionAnnouncement: anAnnouncement [

	| dictionary |
	dictionary := Dictionary new.
	dictionary at: #kind put: #completion.
	dictionary at: #timestamp put: DateAndTime now asString.
	dictionary at: #announcementClass put: anAnnouncement class name.
	dictionary at: #token put: (self safeValue: [ anAnnouncement token asString ] ifError: [ nil ]).
	dictionary at: #index put: (self safeValue: [ anAnnouncement index ] ifError: [ nil ]).
	dictionary at: #selectedItem put: (self safeValue: [ anAnnouncement selectedItem asString ] ifError: [ nil ]).
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

	deliveryEnabled := false
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

	deliveryEnabled := true
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
CooHistoryEventRecorder >> imageInfo [

	| info |
	info := Dictionary new.
	info at: #imageVersion put: (self safeValue: [ SystemVersion current version asString ] ifError: [ nil ]).
	info at: #latestUpdate put: (self safeValue: [ SystemVersion current commitHash asString ] ifError: [ nil ]).
	info at: #imagePath put: (self safeValue: [ SmalltalkImage current imagePath asString ] ifError: [ nil ]).
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
	session := CooSession current.
	serverUrl := self class defaultServerUrl.
	category := self class defaultCategory.
	deliveryEnabled := true.
	pendingEvents := OrderedCollection new.
	deliveryMutex := Mutex new.
	installed := false.
	saveOnDisk := self class defaultSaveOnDisk.
	deliveryBatchSize := self class defaultDeliveryBatchSize.
	logToTranscript := true
]

{ #category : 'actions' }
CooHistoryEventRecorder >> install [

	self deinstall.
	self class registerForImageLifecycle.

	announcer := self class codeChangeAnnouncer.

	[ announcer unsubscribe: self session ] on: Error do: [ :ex | nil ].

	self subscribeCodeChangeAnnouncements.
	self installCompletionHeuristics.

	installed := true.
	self log: 'CooHistoryEventRecorder installed. Server: ', self serverUrl asString.

	^ self
]

{ #category : 'installation' }
CooHistoryEventRecorder >> installCompletionHeuristics [

	| builder |
	builder := self class environment
		           at: #CoASTHeuristicsResultSetBuilder
		           ifAbsent: [ ^ self ].

	((builder respondsTo: #messagesHeuristic)
		and: [ self includesInstanceOf: CooSessionMessagesHeuristic in: builder messagesHeuristic ])
		ifFalse: [
			(builder respondsTo: #messagesHeuristic)
				ifTrue: [ builder messagesHeuristic addFirst: CooSessionMessagesHeuristic new ] ].

	((builder respondsTo: #variablesHeuristic)
		and: [ self includesInstanceOf: CooSessionVariableHeuristic in: builder variablesHeuristic ])
		ifFalse: [
			(builder respondsTo: #variablesHeuristic)
				ifTrue: [ builder variablesHeuristic addFirst: CooSessionVariableHeuristic new ] ]
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

{ #category : 'logging' }
CooHistoryEventRecorder >> log: aString [

	logToTranscript ifFalse: [ ^ self ].
	Transcript
		show: aString;
		cr
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> logToTranscript [

	^ logToTranscript
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> logToTranscript: aBoolean [

	logToTranscript := aBoolean
]

{ #category : 'helpers' }
CooHistoryEventRecorder >> messageSelectorsIn: anAst [

	anAst ifNil: [ ^ #() ].

	^ [
		  (anAst allChildren
			   select: [ :each |
				   (each respondsTo: #isMessage) and: [ each isMessage ] ])
			   collect: [ :each | each selector ] ]
		  on: Error
		  do: [ :ex | #() ]
]

{ #category : 'events-methods' }
CooHistoryEventRecorder >> methodAdded: anAnnouncement [

	self
		addMethodItemOf: CooAddedMethodHistoryItem
		from: anAnnouncement
		oldMethod: nil
]

{ #category : 'events-methods' }
CooHistoryEventRecorder >> methodFrom: anAnnouncement [

	#(method newMethod compiledMethod) do: [ :eachSelector |
		| value |
		value := self valueFrom: anAnnouncement selector: eachSelector.
		(value notNil and: [ value respondsTo: #selector ])
			ifTrue: [ ^ value ] ].

	^ nil
]

{ #category : 'events-methods' }
CooHistoryEventRecorder >> methodModified: anAnnouncement [

	self
		addMethodItemOf: CooModifiedMethodHistoryItem
		from: anAnnouncement
		oldMethod: (self oldMethodFrom: anAnnouncement)
]

{ #category : 'events-methods' }
CooHistoryEventRecorder >> methodRemoved: anAnnouncement [

	self
		addMethodItemOf: CooRemovedMethodHistoryItem
		from: anAnnouncement
		oldMethod: nil
]

{ #category : 'actions' }
CooHistoryEventRecorder >> multipartEntityForBytes: aByteArray category: aCategory [

	| entity |
	entity := ZnMultiPartFormDataEntity new.

	entity
		addPart: (ZnMimePart fieldName: 'category' value: aCategory asString);
		addPart: (ZnMimePart fieldName: 'data' entity: (ZnByteArrayEntity bytes: aByteArray)).

	^ entity
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

{ #category : 'accessing' }
CooHistoryEventRecorder >> pendingEvents [
	^ pendingEvents 
]

{ #category : 'system startup' }
CooHistoryEventRecorder >> prepareForImageSave [

	self saveOnDisk ifTrue: [ ^ self ].

	self waitForDeliveryProcess.
	self deliverNow.
	self clearPendingEvents.

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
CooHistoryEventRecorder >> putBytes: aByteArray category: aCategory [

	| client entity |
	entity := self multipartEntityForBytes: aByteArray category: aCategory.

	client := ZnClient new.
	client
		beOneShot;
		timeout: 5;
		numberOfRetries: 0;
		url: self serverUrl;
		enforceHttpSuccess: true;
		entity: entity.

	logToTranscript ifTrue: [ client logToTranscript ].

	client put.

	^ client response
]

{ #category : 'actions' }
CooHistoryEventRecorder >> recordClassItem: item announcement: anAnnouncement [

	self session addClassItem: item.
	self enqueueEvent: (self dictionaryForClassItem: item announcement: anAnnouncement)
]

{ #category : 'actions' }
CooHistoryEventRecorder >> recordMethodItem: item announcement: anAnnouncement [

	self session addMethodItem: item.
	self enqueueEvent: (self dictionaryForMethodItem: item announcement: anAnnouncement)

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

{ #category : 'accessing' }
CooHistoryEventRecorder >> session [

	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooHistoryEventRecorder >> session: aCooSession [

	session := aCooSession
]

{ #category : 'installation' }
CooHistoryEventRecorder >> subscribeAnnouncementNamed: announcementName send: selector [

	| announcementClass |
	announcementClass := self class environment
		                     at: announcementName
		                     ifAbsent: [ ^ self ].
	
	"When the passed class does not inherit from Announcement, we do nothing"
	(announcementClass inheritsFrom: Announcement)
        ifFalse: [ ^ self ].

	announcer
		when: announcementClass
		send: selector
		to: self.
]

{ #category : 'installation' }
CooHistoryEventRecorder >> subscribeCodeChangeAnnouncements [

	self subscribeAnnouncementNamed: #MethodAdded send: #methodAdded:.
	self subscribeAnnouncementNamed: #MethodModified send: #methodModified:.
	self subscribeAnnouncementNamed: #MethodRemoved send: #methodRemoved:.

	self subscribeAnnouncementNamed: #ClassAdded send: #classAdded:.
	self subscribeAnnouncementNamed: #ClassModified send: #classModified:.
	self subscribeAnnouncementNamed: #ClassRemoved send: #classRemoved:.

	self subscribeAnnouncementNamed: #CoCompletionItemSelected send: #completionItemSelected:
]

{ #category : 'actions' }
CooHistoryEventRecorder >> shouldDeliverPendingEvents [

	^ self deliveryEnabled and: [
		  pendingEvents size >= self deliveryBatchSize ]
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
