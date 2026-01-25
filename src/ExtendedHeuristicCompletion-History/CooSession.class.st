"
I collect and treat information about development sessions. I take two sources of information: the definition/modification of program elements (class added, removed,...) and the choices made by the developer when selecting a completion item in the proposed list.

I collect information about class and method definitions.
Their treatments are delegated to strategies implementing different behavior and acessible via the `cache` message.


In addition I'm collecting information about the user selection in the ecompletion items. 
I delegate the treatment of such information to a dedicated strategy. The protocol of communication between me and the strategy is the following one:  The message `handleNewSelectionItem: item addedTo: completionItems` is sent to the strategy the item and the full collection of recorded item included the newly added one. 

I then compose the results coming from the structural program definitions and the user selection using the message `sortedUserVocabulary`

```
selectorEntries
	""Return a list of message selector entries computed from the user interaction and the modification of program.""
	
	^ userSelectionHandler sortedUserEntries,  programEntityHandler selectorEntries
```
"
Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'completionItems',
		'userSelectionHandler',
		'programEntityHandler',
		'classDescriptions',
		'methodDescriptions'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'accessing' }
CooSession class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSession class >> deinstall [

	<script>
	self environment codeChangeAnnouncer unsubscribe: self current.
	Current := nil.
	
	(CoASTHeuristicsResultSetBuilder messagesHeuristic first class = CooSessionMessagesHeuristic)
		ifTrue: [ CoASTHeuristicsResultSetBuilder messagesHeuristic removeFirst ].
		
	(CoASTHeuristicsResultSetBuilder variablesHeuristic first class = CooSessionVariableHeuristic )
		ifTrue: [ CoASTHeuristicsResultSetBuilder variablesHeuristic removeFirst ].
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
	| codeAnnouncer |
	
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
		
	codeAnnouncer 
		when: CompletionItemSelected
		send: #addCompletionItem: 
		to: self current. 
		
	(CoASTHeuristicsResultSetBuilder messagesHeuristic first class = CooSessionMessagesHeuristic)
		ifFalse: [ CoASTHeuristicsResultSetBuilder messagesHeuristic addFirst: CooSessionMessagesHeuristic new ].
		
	(CoASTHeuristicsResultSetBuilder variablesHeuristic first class = CooSessionVariableHeuristic)
		ifFalse: [ CoASTHeuristicsResultSetBuilder variablesHeuristic addFirst: CooSessionVariableHeuristic new ].


]

{ #category : 'instance creation' }
CooSession class >> resetProgramEntities [ 
	<script>
	
	self current resetProgramEntities
		
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
	programEntityHandler handleNewClassItem: anItem addedTo: classDescriptions
]

{ #category : 'interaction items' }
CooSession >> addCompletionItem: aCompletionEntryItem [

	| item |

	item := CooInteractionItem new.
	item token: aCompletionEntryItem token.
	item choices: aCompletionEntryItem entries.
	item index: aCompletionEntryItem index. "Could be computed instead of storing it."
	item selectedItem: aCompletionEntryItem selectedItem.
	item fetchers: (aCompletionEntryItem entries collect: [ :each | each fetcher class name]).

	completionItems addFirst: item.
	
	"Instead of poking the handler during each addition we could pass it all the info when 
	requesting a list of entries."
	userSelectionHandler handleNewSelectionItem: item addedTo: completionItems
]

{ #category : 'method handling' }
CooSession >> addMethodItem: anItem [

	methodDescriptions addFirst: anItem.
	"Instead of poking the handler during each addition we could pass it all the info when 
	requesting a list of entries."
	
	programEntityHandler handleNewMethodItem: anItem addedTo: methodDescriptions
]

{ #category : 'method handling' }
CooSession >> addModifiedMethodInVocabulary: anAnn [

	| deltaMessage item |
	deltaMessage := self computeDeltaMessageOf: anAnn.
	item := CooModifiedMethodHistoryItem new
		        selector: anAnn method selector;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: anAnn method methodClass name;
		        yourself.
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	
	self addMethodItem: item
]

{ #category : 'class handling' }
CooSession >> addNewClassInVocabulary: ann [

	self addClassItem: (CooAddedClassHistoryItem new
			 nameOfClass: ann classAdded name;
			live: true;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"
			timestamp: DateAndTime now;
			yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'method handling' }
CooSession >> addNewMethodInVocabulary: anAnn [

	self addMethodItem: (CooAddedMethodHistoryItem new
			 selector: anAnn method selector;
			 live: true;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'matching' }
CooSession >> classEntries [

	^ userSelectionHandler sortedUserUppercasedEntries, programEntityHandler classEntries
]

{ #category : 'helpers' }
CooSession >> computeDeltaMessageBetween: aNewMethodAst andOld: anOldMethodAst [

	^ ((aNewMethodAst allChildren select: [ :each | each isMessage ])
			collect: [ :each | each selector ])
		  difference:
		  ((anOldMethodAst allChildren select: [ :each | each isMessage ]) 
				collect: [ :each | each selector ])
]

{ #category : 'helpers' }
CooSession >> computeDeltaMessageOf: aMethodModifiedAnnouncement [

	^ self 
		computeDeltaMessageBetween: aMethodModifiedAnnouncement method ast
		andOld: aMethodModifiedAnnouncement oldMethod ast 
	
]

{ #category : 'initialization' }
CooSession >> initialize [

	super initialize.
	self resetProgramEntities.
	self resetInteractionItems.
]

{ #category : 'configuration' }
CooSession >> mostDualRecentFrequentSelectionHandling [

	userSelectionHandler := CooDualMostRecentFrequencyHandler new.
]

{ #category : 'configuration' }
CooSession >> mostRecentFrequentSelectionHandling [

	userSelectionHandler := CooMostRecentFrequencyHandler new.
]

{ #category : 'configuration' }
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
]

{ #category : 'accessing' }
CooSession >> programEntityHandler [

	^ programEntityHandler 
]

{ #category : 'accessing' }
CooSession >> programEntityHandler: aCache [

	programEntityHandler := aCache
]

{ #category : 'class handling' }
CooSession >> removeClassFromVocabulary: ann [

	| removedClassName |
	removedClassName := ann classRemoved name.
	(removedClassName beginsWith: 'AnObsolete')
		ifTrue: [ removedClassName := removedClassName allButFirst: 'AnObsolete' size ].
		
	self addClassItem: (CooRemovedClassHistoryItem new
			nameOfClass: removedClassName;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"
			live: true;
			timestamp: DateAndTime now;
			yourself)
]

{ #category : 'method handling' }
CooSession >> removeMethodFromVocabulary: anAnn [

	self addMethodItem: (CooRemovedMethodHistoryItem new
			 selector: anAnn method selector;
			 live: true;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself) 
]

{ #category : 'initialization' }
CooSession >> resetInteractionItems [
	
	completionItems := OrderedCollection new.
	userSelectionHandler := CooMostRecentFrequencyHandler new.
]

{ #category : 'initialization' }
CooSession >> resetProgramEntities [

	methodDescriptions := OrderedCollection new.
	classDescriptions := OrderedCollection new.
	programEntityHandler := CooTemporalHandler new.
	
]

{ #category : 'matching' }
CooSession >> selectorEntries [
	"Return a list of message selector entries computed from the user interaction and the modification of program."
	
	"here I would love to know the token because I could then 
	decide if the user is looking for a global or not."
	
	^ userSelectionHandler sortedUserLowercasedEntries, programEntityHandler selectorEntries 
]

{ #category : 'accessing' }
CooSession >> size [ 

	^ programEntityHandler size
]

{ #category : 'accessing' }
CooSession >> useSelectionHandler: aUserSelectionHandler [

	userSelectionHandler := aUserSelectionHandler
]
