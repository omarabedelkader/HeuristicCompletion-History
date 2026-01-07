"
I collect and treat information about development sessions. I take two sources of information: the definition/modification of program elements (class added, removed,...) and the choices made by the developer when selecting a completion item in the proposed list.

I collect information about class and method definitions.
Their treatments are delegated to strategies implementing different behavior and acessible via the `cache` message.


In addition I'm collecting information about the user selection in the ecompletion items. 
I delegate the treatment of such information to a dedicated strategy. The protocol of communication between me and the strategy is the following one:  The message `handleNewSelectionItem: item addedTo: completionItems` is sent to the strategy the item and the full collection of recorded item included the newly added one. 

I then compose the results coming from the structural program definitions and the user selection using the message `sortedUserVocabulary`

```
selectors
	
	^ userSelectionHandler sortedUserVocabulary,  cache selectors
```
"
Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'completionItems',
		'userSelectionHandler',
		'programEntityHandler'
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
	Current := nil
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

	"We should kill this idea of shorter it does not help."
	CompletionContext sorterClass: NoSorter.
	
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
		
	(CoASTHeuristicsResultSetBuilder classVarNamed: 'MessageHeuristic') addFirst: CooSessionMessagesHeuristic new
]

{ #category : 'instance creation' }
CooSession class >> resetCache [ 
	<script>
	
	self current resetCache
		
]

{ #category : 'instance creation' }
CooSession class >> withCache: aCache [

	^ self current programEntityHandler: aCache
]

{ #category : 'interaction items' }
CooSession >> addCompletionItem: aCompletionEntryItem [

	| item |
	item := CooInteractionItem new.
	item token: aCompletionEntryItem token.
	item choices: aCompletionEntryItem entries.
	item index: aCompletionEntryItem index. "Could be computed instead of storing it."
	item selectedItem: (item choices at: item index).
	item fetchers: (aCompletionEntryItem entries collect: [ :each | each fetcher class name]).

	completionItems addFirst: item.
	userSelectionHandler handleNewSelectionItem: item addedTo: completionItems
]

{ #category : 'adding' }
CooSession >> addModifiedMethodInVocabulary: anAnn [

	programEntityHandler addModifiedMethodInVocabulary: anAnn 
]

{ #category : 'adding' }
CooSession >> addNewClassInVocabulary: aClassAdded [

	programEntityHandler addNewClassInVocabulary: aClassAdded
]

{ #category : 'adding' }
CooSession >> addNewMethodInVocabulary: anAnn [

	programEntityHandler addNewMethodInVocabulary: anAnn
]

{ #category : 'matching' }
CooSession >> classEntries [

	^ programEntityHandler classEntries
]

{ #category : 'initialization' }
CooSession >> initialize [

	super initialize.
	self resetCache.
	completionItems := OrderedCollection new.
	
	userSelectionHandler := CooMostRecentFrequencyHandler new.
]

{ #category : 'accessing' }
CooSession >> programEntityHandler [

	^ programEntityHandler 
]

{ #category : 'accessing' }
CooSession >> programEntityHandler: aCache [

	programEntityHandler := aCache
]

{ #category : 'adding' }
CooSession >> removeClassFromVocabulary: aClassRemoved [

	programEntityHandler removeClassFromVocabulary: aClassRemoved 
]

{ #category : 'adding' }
CooSession >> removeMethodFromVocabulary: aMethodRemovedAnnouncement [ 

	programEntityHandler removeMethodFromVocabulary: aMethodRemovedAnnouncement 
]

{ #category : 'initialization' }
CooSession >> resetCache [

	programEntityHandler := CooTemporalCache new.
	
]

{ #category : 'matching' }
CooSession >> selectorEntries [
	"Return a list of message selector entries computed from the user interaction and the modification of program."
	
	^ userSelectionHandler sortedUserVocabulary,  programEntityHandler selectorEntries
]

{ #category : 'accessing' }
CooSession >> size [ 

	^ programEntityHandler size
]

{ #category : 'accessing' }
CooSession >> useSelectionHandler: aUserSelectionHandler [

	userSelectionHandler := aUserSelectionHandler
]
