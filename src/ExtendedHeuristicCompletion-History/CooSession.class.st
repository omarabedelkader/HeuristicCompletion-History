"
I collect and treat information about development sessions. I take two sources of information: the definition/modification of program elements (class added, removed,...) and the choices made by the developer when selecting a completion item in the proposed list.

### Program definitions
I collect information about class and method definitions.
Their treatments are delegated to strategies implementing different behavior and accessible via the `cache` message.


### User selection

In addition I'm collecting information about the user selection in the ecompletion items. 
I delegate the treatment of such information to a dedicated strategy. The protocol of communication between me and the strategy is the following one:  The message `handleNewSelectionItem: item addedTo: completionItems` is sent to the strategy the item and the full collection of recorded item included the newly added one. 


### Composition of information

I then compose the results coming from the structural program definitions and the user selection using the message `sortedUserVocabulary`

```
selectorEntries
	""Return a list of message selector entries computed from the user interaction and the modification of program.""
	
	^ userSelectionHandler sortedUserEntries,  programEntityHandler selectorEntries
```

### Current implementation

To be able to produce benchmarks I keep track of all the information program entities as well as interaction.
In addition to the information kept in handlers. This redundancy is just to be able to replay different handlers on the same data. In the future it should be removed.
 
This supports the switch and rebuild of handler data. Now this collection of all the history is not good for production level. In normal execution we can expect that the session does not hold any information but that the event are passed directly to the current handlers.

"
Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'completionItems',
		'userSelectionHandler',
		'programEntityHandler',
		'classDescriptions',
		'methodDescriptions',
		'navigationItems',
		'recorder'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'actions' }
CooSession class >> completionItemSelectedAnnouncementClass [

	^ self environment at: #CoCompletionItemSelected ifAbsent: [ nil ]
]

{ #category : 'actions' }
CooSession class >> completionResultSetBuilderClass [

	^ self environment at: #CoASTHeuristicsResultSetBuilder ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CooSession class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSession class >> deinstall [

	<script>
	self environment codeChangeAnnouncer unsubscribe: self current.
	Current := nil.

	self removeCompletionHeuristics
]

{ #category : 'instance creation' }
CooSession class >> entityHandler: aProgramEntityHandler [

	^ self current programEntityHandler: aProgramEntityHandler
]

{ #category : 'actions' }
CooSession class >> initialize [

	self install
]

{ #category : 'actions' }
CooSession class >> install [

	<script>
	| codeAnnouncer completionAnnouncementClass |
	
	self deinstall.

	
	"First handling changes of structural code entities: classes and methods so far"
	
	codeAnnouncer := self environment codeChangeAnnouncer.
	codeAnnouncer when: MethodAdded send: #addNewMethodInVocabulary: to: self current.
	codeAnnouncer when: MethodModified send: #addModifiedMethodInVocabulary: to: self current.
	codeAnnouncer when: MethodRemoved send: #removeMethodFromVocabulary: to: self current.
		
	codeAnnouncer
		when: ClassAdded send: #addNewClassInVocabulary: to: self current;
		when: ClassRemoved send: #removeClassFromVocabulary: to: self current.
		
	"now for the user choices
	We should probably handle the fact that the user may not select and cancel the prompt."	
		
	completionAnnouncementClass := self completionItemSelectedAnnouncementClass.
	completionAnnouncementClass ifNotNil: [
		codeAnnouncer
			when: completionAnnouncementClass
			send: #addCompletionItem:
			to: self current ].

	self installCompletionHeuristics


]

{ #category : 'actions' }
CooSession class >> installCompletionHeuristics [

	| builderClass messagesHeuristic variablesHeuristic |
	builderClass := self completionResultSetBuilderClass.
	(builderClass notNil
		and: [ (builderClass respondsTo: #messagesHeuristic)
		and: [ builderClass respondsTo: #variablesHeuristic ] ])
		ifFalse: [ ^ self ].

	messagesHeuristic := builderClass messagesHeuristic.
	(messagesHeuristic isEmpty
		or: [ messagesHeuristic first class ~= CooSessionMessagesHeuristic ])
		ifTrue: [ messagesHeuristic addFirst: CooSessionMessagesHeuristic new ].

	variablesHeuristic := builderClass variablesHeuristic.
	(variablesHeuristic isEmpty
		or: [ variablesHeuristic first class ~= CooSessionVariableHeuristic ])
		ifTrue: [ variablesHeuristic addFirst: CooSessionVariableHeuristic new ]
]

{ #category : 'actions' }
CooSession class >> removeCompletionHeuristics [

	| builderClass messagesHeuristic variablesHeuristic |
	builderClass := self completionResultSetBuilderClass.
	(builderClass notNil
		and: [ (builderClass respondsTo: #messagesHeuristic)
		and: [ builderClass respondsTo: #variablesHeuristic ] ])
		ifFalse: [ ^ self ].

	messagesHeuristic := builderClass messagesHeuristic.
	(messagesHeuristic notEmpty
		and: [ messagesHeuristic first class = CooSessionMessagesHeuristic ])
		ifTrue: [ messagesHeuristic removeFirst ].

	variablesHeuristic := builderClass variablesHeuristic.
	(variablesHeuristic notEmpty
		and: [ variablesHeuristic first class = CooSessionVariableHeuristic ])
		ifTrue: [ variablesHeuristic removeFirst ]
]

{ #category : 'instance creation' }
CooSession class >> resetProgramEntities [ 
	<script>
	
	self current resetProgramEntities
		
]

{ #category : 'todo' }
CooSession class >> todos [

^ '- loading code element should be tagged as live
- check the protocol to add element to the handler
- [x] implement LRU
- check more history handler
- what about the information stored in the completionItem (the class but we need a symbol to give feedback when we reuse them)
- [~] filling up the repo.
- [ON IT] what is happening when we remove a class


Pharo 
- remove CoASTSession....
'
]

{ #category : 'instance creation' }
CooSession class >> withCache: aCache [
	
	self deprecated: 'use entityHandler' transformWith: '`@rec withCache: `@a' ->  '`@rec withEntityHandler: `@a'. 
	^ self withEntityHandler: aCache
]

{ #category : 'instance creation' }
CooSession class >> withEntityHandler: aProgramEntityHandler [

	^ self current programEntityHandler: aProgramEntityHandler
]

{ #category : 'class handling' }
CooSession >> addClassItem: anItem [
	
	classDescriptions addFirst: anItem.
	
	"Instead of poking the handler during each addition we could pass it all the info when 
	requesting a list of entries."
	programEntityHandler handleNewClassItem: anItem
]

{ #category : 'interaction items' }
CooSession >> addCompletionItem: aCompletionEntryItem [

	| item |

	item := CooInteractionItem new.
	item token: aCompletionEntryItem token.
	item choices: aCompletionEntryItem entries.
	item index: aCompletionEntryItem index. "Could be computed instead of storing it."
	item selectedItem: aCompletionEntryItem selectedItem.

	item fetchers: (aCompletionEntryItem entries collect: [ :each | each fetcher ]).


	completionItems addFirst: item.
	
	"Instead of poking the handler during each addition we could pass it all the info when 
	requesting a list of entries."
	userSelectionHandler handleNewSelectionItem: item. 
	
	"pass the selected item to the recorder"
	self recorder enqueueEvent: (self recorder dictionaryForCompletionItem: item).
]

{ #category : 'method handling' }
CooSession >> addMethodItem: anItem [
	
	
	methodDescriptions addFirst: anItem.
	"keeping item is needed for bcnhing because we need to know newly defined and modified entities"
	
	programEntityHandler handleNewMethodItem: anItem
]

{ #category : 'method handling' }
CooSession >> addModifiedMethodInVocabulary: anAnn [
	"When a nmethod is modified we compute in addition the delta so that we can only bench the difference"
	
	| deltaMessage item |
	anAnn method selector = #extractLine: ifTrue: [ self halt. ].
	deltaMessage := self computeDeltaMessageOf: anAnn.
	item := CooModifiedMethodHistoryItem new
		        selector: anAnn method selector;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: anAnn method methodClass name;
		        yourself.
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	
	self addMethodItem: item.
	
]

{ #category : 'navigation' }
CooSession >> addNavigationItem: aNavigationHistoryItem [

	navigationItems addFirst: aNavigationHistoryItem
]

{ #category : 'class handling' }
CooSession >> addNewClassInVocabulary: ann [

	|historyItem|

	historyItem := CooAddedClassHistoryItem new
			 nameOfClass: ann classAdded name;
			live: true;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"
			timestamp: DateAndTime now;
			yourself.

	self addClassItem: historyItem.  
	
	"we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "

]

{ #category : 'method handling' }
CooSession >> addNewMethodInVocabulary: anAnn [

	| historyItem |

	historyItem := CooAddedMethodHistoryItem new
			 selector: anAnn method selector;
			 live: true;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself.

	self addMethodItem: historyItem. 
	
	"we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "

]

{ #category : 'for benchmark' }
CooSession >> addedMethodDescriptions [
	"this is unclear how to handle removed method when we load commits"
	
	| tmps removed existing |
	tmps := methodDescriptions copy.
	tmps := tmps select: [ :each | each event = #added  ].
	existing := Set new.
	removed := Set new.
	
	tmps do: [ :each |
			"we make sure that if a method was removed we do not handle it.
			Now this unclear if we get removed method when loading back code so the following
			test looks useless."
			each event = #removed ifTrue: [ removed add: each ].
			(removed anySatisfy: [ :r | r selector = each selector and: [ r nameOfClass = each nameOfClass ] ]) 
				ifFalse: [ existing add: each ] ].
	^ existing
]

{ #category : 'for benchmark' }
CooSession >> addedMethods [
	"pay attention this requires that the classes are loaded in Pharo."
	"we may have some extensions...."
	
	| col |
	col := OrderedCollection new. 
	
	self addedMethodDescriptions do: [ :each |
		| metaclass clss |
		metaclass := false.
		clss := each nameOfClass.
		(each nameOfClass endsWith: ' class') ifTrue: [
			metaclass := true.
			clss := each nameOfClass allButLast: 6 ].
			self class environment at: clss asSymbol ifPresent: [ :myClass |
				col add: (metaclass
					ifTrue: [ myClass class >> each selector ]
				   ifFalse: [ myClass >> each selector ]) ] ].
	^ col 
]

{ #category : 'low-level' }
CooSession >> classDescriptions [ 
	
	^ classDescriptions 
]

{ #category : 'matching' }
CooSession >> classEntries [
	
	^ userSelectionHandler sortedUserUppercasedEntries
		", self navigationClassEntries"
		, programEntityHandler classEntries
]

{ #category : 'matching' }
CooSession >> completionClassSpies [
	"return the first result recorded completion items and the information about the completion items"
	
	^ {userSelectionHandler sortedUserUppercasedEntries first . completionItems first}
]

{ #category : 'helpers' }
CooSession >> computeDeltaMessageBetween: aNewMethodAst andOld: anOldMethodAst [
	"Pay attention we do not use difference: because difference is set based. 
	with difference we may lose a delta
	see 
		#( #a #b #c #a) difference: #(a).
		returns #(b c) while we need to have #(#b #c #a)
	"
	
	
	
	| first |
	first := (CooMethodHistoryItem messageCompletionSelectorsFromAST: aNewMethodAst).
	 (CooMethodHistoryItem messageCompletionSelectorsFromAST: anOldMethodAst)
		 do: [ :each | 
			first remove: each ifAbsent: [  ]].
	^ first 
	
]

{ #category : 'helpers' }
CooSession >> computeDeltaMessageOf: aMethodModifiedAnnouncement [

	^ self 
		computeDeltaMessageBetween: aMethodModifiedAnnouncement method ast
		andOld: aMethodModifiedAnnouncement oldMethod ast 
	
]

{ #category : 'emit' }
CooSession >> dictionaryForClassItem: item announcement: anAnnouncement [ 

	| dictionary |
	self halt: 'This should be delegated to the Announcement class! '.
	dictionary := Dictionary new.
	dictionary at: #kind put: #class.
	dictionary at: #event put: item event.
	dictionary at: #className put: item nameOfClass.
	dictionary at: #timestamp put: item timestamp asString.
	dictionary at: #live put: true.
	dictionary at: #announcementClass put: anAnnouncement class name.
	^ dictionary
]

{ #category : 'emit' }
CooSession >> dictionaryForMethodItem: item announcement: anAnnouncement [
	"we should find a way to avoid to pass the announcement."
	
	| dictionary |
	self halt: 'This should be delegated to the Announcement class! '.
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

{ #category : 'emit' }
CooSession >> emitClass: historyItem announcement: ann [
	self halt: 'We should only write
		self recorder enqueueEvent: history asEvent.
		
		Now this is strange that enqueueEvent: expect a dictionary and not something else
		why not the item (of course it means that you need the class for the analysis. duh but why not?)
	'.
	self recorder enqueueEvent: (self dictionaryForClassItem: historyItem announcement: ann)
]

{ #category : 'emit' }
CooSession >> emitMethod: historyItem announcement: ann [
	self halt: 'We should only write
		self recorder enqueueEvent: history asEvent.
		
		Now this is strange that enqueueEvent: expect a dictionary and not something else
		why not the item (of course it means that you need the class for the analysis. duh but why not?)
	'.
	self recorder enqueueEvent: (self dictionaryForMethodItem: historyItem announcement: ann)
]

{ #category : 'for benchmark' }
CooSession >> existingMethodDescriptions [

	| tmps removed existing |
	tmps := methodDescriptions copy.
	existing := Set new.
	removed := Set new.
	tmps do: [ :each |
			each event = #removed ifTrue: [ removed add: each ].
			(removed anySatisfy: [ :r | r selector = each selector and: [ r nameOfClass = each nameOfClass ] ]) 
				ifFalse: [ existing add: each ] ].
	^ existing
]

{ #category : 'for benchmark' }
CooSession >> existingMethods [
	"pay attention this requires that the classes are loaded in Pharo."
	"we may have some extensions...."
	| col |
	col := OrderedCollection new. 
	
	self existingMethodDescriptions do: [ :each |
		| metaclass clss |
		metaclass := false.
		clss := each nameOfClass.
		(each nameOfClass endsWith: ' class') ifTrue: [
			metaclass := true.
			clss := each nameOfClass allButLast: 6 ].
			self class environment at: clss asSymbol ifPresent: [ :myClass |
				col add: (metaclass
					ifTrue: [ myClass class >> each selector ]
				   ifFalse: [ myClass >> each selector ]) ] ].
	^ col 
]

{ #category : 'initialization' }
CooSession >> initialize [

	super initialize.
	self resetProgramEntities.
	self resetInteractionItems.
	self resetNavigationItems.
]

{ #category : 'low-level' }
CooSession >> methodDescriptions [ 
	
	^ methodDescriptions 
]

{ #category : 'for benchmark' }
CooSession >> modifiedMethodDescriptions [
	"this is unclear how to handle removed method when we load commits"
	
	| tmps removed existing |
	tmps := methodDescriptions copy.
	tmps := tmps select: [ :each | each event = #modified  ].
	existing := OrderedCollection new.
	removed := OrderedCollection new.
	
	tmps do: [ :each |
			"we make sure that if a method was removed we do not handle it.
			Now this unclear if we get removed method when loading back code so the following
			test looks useless."
			each event = #removed ifTrue: [ removed add: each ].
			(removed anySatisfy: [ :r | r selector = each selector and: [ r nameOfClass = each nameOfClass ] ]) 
				ifFalse: [ existing add: each ] ].
	^ existing
]

{ #category : 'for benchmark' }
CooSession >> modifiedMethods [
	"pay attention this requires that the classes are loaded in Pharo."
	"we may have some extensions...."
	
	| col |
	col := OrderedCollection new. 
	
	self modifiedMethodDescriptions do: [ :each |
		| metaclass clss |
		metaclass := false.
		clss := each nameOfClass.
		(each nameOfClass endsWith: ' class') ifTrue: [
			metaclass := true.
			clss := each nameOfClass allButLast: 6 ].
			self class environment at: clss asSymbol ifPresent: [ :myClass |
				col add: (metaclass
					ifTrue: [ myClass class >> each selector ]
				   ifFalse: [ myClass >> each selector ]) ] ].
	^ col 
]

{ #category : 'for benchmark' }
CooSession >> modifiedMethodsAndDescriptions [
	"pay attention this requires that the classes are loaded in Pharo."
	"we may have some extensions...."
	
	| col modified res |
	col := OrderedCollection new. 
	modified := self modifiedMethodDescriptions.
	modified do: [ :each |
		| metaclass clss |
		metaclass := false.
		clss := each nameOfClass.
		(each nameOfClass endsWith: ' class') 
			ifTrue: [
				metaclass := true.
				clss := each nameOfClass allButLast: 6 ].
			self class environment 
				at: clss asSymbol 
				ifPresent: [ :myClass |
				col add: ((metaclass
							ifTrue: [ myClass class >> each selector ]
				  			 ifFalse: [ myClass >> each selector ]) -> each) ] ].
	^ col  
]

{ #category : 'interaction configuration' }
CooSession >> mostDualRecentFrequentSelectionHandling [

	userSelectionHandler := CooDualMostRecentFrequencyHandler new.
]

{ #category : 'interaction configuration' }
CooSession >> mostRecentFrequentSelectionHandling [

	userSelectionHandler := CooMostRecentFrequencyHandler new.
]

{ #category : 'navigation' }
CooSession >> navigationClassEntries [

	| seen entries |
	navigationItems ifNil: [ ^ #() ].
	seen := Set new.
	entries := OrderedCollection new.
	navigationItems do: [ :item |
		(item isClassObservation and: [ (seen includes: item name) not ]) ifTrue: [
			seen add: item name.
			entries add: ((CoGlobalEntry contents: item name node: nil)
					 sessionItem: item;
					 fetcherName: 'Session Navigation';
					 yourself) ] ].
	^ entries first: (entries size min: 5)
]

{ #category : 'navigation' }
CooSession >> navigationItems [

	^ navigationItems
]

{ #category : 'navigation' }
CooSession >> navigationSelectorEntries [

	| seen entries |
	navigationItems ifNil: [ ^ #() ].
	seen := Set new.
	entries := OrderedCollection new.
	navigationItems do: [ :item |
		(item isSelectorObservation and: [ (seen includes: item name) not ]) ifTrue: [
			seen add: item name.
			entries add: ((CoSelectorEntry contents: item name node: nil)
					 sessionItem: item;
					 fetcherName: 'Session Navigation';
					 yourself) ] ].
	^ entries first: (entries size min: 5)
]

{ #category : 'interaction configuration' }
CooSession >> noUserSelectionHandling [

	userSelectionHandler := CooNullUserSelectionHandler new.
]

{ #category : 'printing' }
CooSession >> printOn: aStream [


	super printOn: aStream.
	aStream space ; nextPutAll: (programEntityHandler class name allButFirst: 3).
	aStream space ; nextPutAll: 'mths '; print: methodDescriptions size.
	aStream space ; nextPutAll: 'cls '; print: classDescriptions size.
	aStream space ; nextPutAll: (userSelectionHandler class name allButFirst: 3).
	aStream space ; nextPutAll: 'interaction'; print: completionItems size.
	aStream space ; nextPutAll: 'navigation'; print: (navigationItems ifNil: [ 0 ] ifNotNil: [ navigationItems size ]).
]

{ #category : 'accessing - handlers' }
CooSession >> programEntityHandler [

	^ programEntityHandler 
]

{ #category : 'accessing - handlers' }
CooSession >> programEntityHandler: aCache [

	programEntityHandler := aCache
]

{ #category : 'accessing' }
CooSession >> recorder [ 
	^ recorder
]

{ #category : 'accessing' }
CooSession >> recorder: aRecorder [
	recorder := aRecorder 
]

{ #category : 'class handling' }
CooSession >> removeClassFromVocabulary: ann [

	| removedClassName historyItem|
	removedClassName := ann classRemoved name.
	(removedClassName beginsWith: 'AnObsolete')
		ifTrue: [ removedClassName := removedClassName allButFirst: 'AnObsolete' size ].

	historyItem := CooRemovedClassHistoryItem new
			nameOfClass: removedClassName;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"
			live: true;
			timestamp: DateAndTime now;
			yourself.

	self addClassItem: historyItem
]

{ #category : 'method handling' }
CooSession >> removeMethodFromVocabulary: anAnn [

	| historyItem |

	historyItem := CooRemovedMethodHistoryItem new
			 selector: anAnn method selector;
			 live: true;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself.

	self addMethodItem:  historyItem
]

{ #category : 'printing' }
CooSession >> reportString [ 

	^ String streamContents: [ :aStream |  
		super printOn: aStream.
		aStream space ; nextPutAll: (programEntityHandler class name allButFirst: 3).
		aStream space ; nextPutAll: 'mths '; print: methodDescriptions size.
		aStream space ; nextPutAll: 'cls '; print: classDescriptions size.
		aStream space ; nextPutAll: (userSelectionHandler class name allButFirst: 3).
		aStream space ; nextPutAll: 'interaction'; print: completionItems size .
	aStream space ; nextPutAll: 'navigation'; print: (navigationItems ifNil: [ 0 ] ifNotNil: [ navigationItems size ]) ]
]

{ #category : 'for benchmark' }
CooSession >> resetDevelopmentItems [
	"this method is needed to be able bench only the newly added or modified items."
	
	methodDescriptions := OrderedCollection new.  
	"unclear for now what we should do for class"
]

{ #category : 'initialization' }
CooSession >> resetInteractionItems [
	
	completionItems := OrderedCollection new.
	self mostDualRecentFrequentSelectionHandling.
	
]

{ #category : 'printing' }
CooSession >> resetNavigationItems [

	navigationItems := OrderedCollection new
]

{ #category : 'initialization' }
CooSession >> resetProgramEntities [

	methodDescriptions := OrderedCollection new.
	classDescriptions := OrderedCollection new.
	programEntityHandler := CooTemporalHandler new.
	
]

{ #category : 'navigation' }
CooSession >> scrapeNavigationFromOpenBrowsers [

	^ CooNavigationScrapper new feedSession: self
]

{ #category : 'matching' }
CooSession >> selectorEntries [
	"Return a list of message selector entries computed from the user interaction and the modification of program."

	"here I would love to know the token because I could then 
	decide if the user is looking for a global or not."

	^ userSelectionHandler sortedUserLowercasedEntries
		", self navigationSelectorEntries"
		, programEntityHandler selectorEntries
]

{ #category : 'updating' }
CooSession >> shiftHandlerTo: aCooHandler [ 

	programEntityHandler := aCooHandler.
	methodDescriptions do: [ :item | 
		programEntityHandler handleNewMethodItem: item] .
	classDescriptions do: [ :item | 
		programEntityHandler handleNewClassItem: item ]
]

{ #category : 'accessing - handlers' }
CooSession >> size [ 

	^ programEntityHandler size
]

{ #category : 'structural handler configuration' }
CooSession >> structuralFrequency [

	programEntityHandler := CooWeightedClassFrequencyHandler new.

 
]

{ #category : 'structural handler configuration' }
CooSession >> structuralTemporal [

	programEntityHandler := CooTemporalHandler new.
	
]

{ #category : 'accessing' }
CooSession >> userSelectionHandler [

	^ userSelectionHandler
]

{ #category : 'accessing - handlers' }
CooSession >> userSelectionHandler: aUserSelectionHandler [

	userSelectionHandler := aUserSelectionHandler
]
