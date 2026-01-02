"
I collect information about class and method definitions.
Their treatments is delegated to strategies implementing different behavior. 

In addition I'm collection information about the user selection in the ecompletion items. 
For now I do not delegate such behavior but just implement locally the same algorithm than the NECUsageTracker
e.g. I keep a frequence for the choices and I inject those in front of the selector or variable names.
"
Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'cache',
		'completionItems',
		'userSelectionHandler'
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
		when: ClassAdded send: #addNewVariableInVocabulary: to: self current;
		when: ClassRemoved send: #removeVariableFromVocabulary: to: self current.
		
	"now for the user choices
	We should probably handle the fact that the user may not select and cancel the prompt."	
		
	codeAnnouncer 
		when: CompletionItemSelected
		send: #addCompletionItem: 
		to: self current. 
]

{ #category : 'instance creation' }
CooSession class >> resetCache [ 
	<script>
	
	self current resetCache
		
]

{ #category : 'instance creation' }
CooSession class >> withCache: aCache [

	^ self current vocabularyCache: aCache
]

{ #category : 'interaction items' }
CooSession >> addCompletionItem: aCompletionEntryItem [

	| item |
	item := CooInteractionItem new.
	item token: aCompletionEntryItem token.
	item choices: (aCompletionEntryItem entries collect: [ :each | each contents ]).
	item index: aCompletionEntryItem index. "Could be computed instead of storing it."
	item selectedItem: (item choices at: item index).

	item fetchers: (aCompletionEntryItem entries collect: [ :each | each fetcher class name]).

	completionItems addFirst: item.
	userSelectionHandler handleNewSelectionItem: item addedTo: completionItems
]

{ #category : 'adding' }
CooSession >> addModifiedMethodInVocabulary: anAnn [

	cache addModifiedMethodInVocabulary: anAnn 
]

{ #category : 'adding' }
CooSession >> addNewMethodInVocabulary: anAnn [

	cache addNewMethodInVocabulary: anAnn
]

{ #category : 'adding' }
CooSession >> addNewVariableInVocabulary: aClassAdded [

	cache addNewVariableInVocabulary: aClassAdded
]

{ #category : 'accessing' }
CooSession >> cache [

	^ cache 
]

{ #category : 'initialization' }
CooSession >> initialize [

	super initialize.
	self resetCache.
	completionItems := OrderedCollection new.
	
	userSelectionHandler := CooMostRecentFrequencyHandler new.
]

{ #category : 'adding' }
CooSession >> removeMethodFromVocabulary: aMethodRemovedAnnouncement [ 

	cache removeMethodFromVocabulary: aMethodRemovedAnnouncement 
]

{ #category : 'adding' }
CooSession >> removeVariableFromVocabulary: aClassRemoved [

	cache removeVariableFromVocabulary: aClassRemoved 
]

{ #category : 'initialization' }
CooSession >> resetCache [

	cache := CooTemporalCache new.
	
]

{ #category : 'matching' }
CooSession >> selectors [
	
	^ userSelectionHandler sortedUserVocabulary,  cache selectors
]

{ #category : 'accessing' }
CooSession >> size [ 

	^ cache size
]

{ #category : 'accessing' }
CooSession >> useSelectionHandler: aUserSelectionHandler [

	userSelectionHandler := aUserSelectionHandler
]

{ #category : 'matching' }
CooSession >> variableNames [

	^ cache variableNames
]

{ #category : 'accessing' }
CooSession >> vocabularyCache [

	^ cache 
]

{ #category : 'accessing' }
CooSession >> vocabularyCache: aCache [

	cache := aCache
]
