"
When the user defines a new method. We add a description of such event in a record. 

### Open question
- what do we do when the user remove a method? Removing all the entries based on the selector is not a good approach. 
- It can be annoying to propose a removed method.
- This is why we need an amortization mecanism (may here or in a sorter). 
- May be we should have a added, modified list and a removed one?

"
Class {
	#name : 'CooNewTemporalCache',
	#superclass : 'Object',
	#instVars : [
		'selectors',
		'variables',
		'selectorDescriptions',
		'variablesDescriptions'
	],
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cache2',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cache2'
}

{ #category : 'accessing' }
CooNewTemporalCache class >> current [

	^ current ifNil: [ current := self new ]
]

{ #category : 'accessing' }
CooNewTemporalCache class >> registerInterestToSystemAnnouncement [ 
	"self registerInterestToSystemAnnouncement"
	
	self environment codeChangeAnnouncer 
		when: MethodAdded send: #addNewMethodInVocabulary: 
		to: self current
]

{ #category : 'initialization' }
CooNewTemporalCache >> addModifiedMethodInVocabulary: anAnn [
	"self
		registerSelector: anAnn selector
		ast: anAnn newMethod ast
		event: #modified
		at: DateAndTime now"
	| deltaMessage item |
	deltaMessage := self computeDeltaMessageOf: anAnn.
	selectors add: anAnn method selector.

	item := (CooMessageHistoryItem new
			 selector: anAnn method selector;
			 date: DateAndTime now;
			 event: #modified;
			 methodClassName: anAnn method methodClass name;
			 yourself).
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	selectorDescriptions add: item
]

{ #category : 'initialization' }
CooNewTemporalCache >> addNewMethodInVocabulary: anAnn [

	selectors add: anAnn method selector.
	selectorDescriptions add: (CooMessageHistoryItem new
			 selector: anAnn method selector;
			 date: DateAndTime now;
			 methodClassName: anAnn method methodClass name;
			 yourself)
			
			
			
	"we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'accessing - computed' }
CooNewTemporalCache >> computeDeltaMessageOf: aCooMockMethodModified [

	^ ((aCooMockMethodModified method ast allChildren select: [ :each | each isMessage ])
			collect: [ :each | each selector ])
		  difference:
		  ((aCooMockMethodModified oldMethod ast allChildren select: [ :each | each isMessage ]) 
				collect: [ :each | each selector ])
]

{ #category : 'initialization' }
CooNewTemporalCache >> initialize [

	super initialize.
	selectors := OrderedCollection new.
	selectorDescriptions := OrderedCollection new.
	variables := OrderedCollection new. 
	variablesDescriptions := OrderedCollection new
]

{ #category : 'initialization' }
CooNewTemporalCache >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	selectors add: aSelector.
	selectorDescriptions add: (CooMessageHistoryItem new
			 selector: aSelector;
			 time: aDateAndTime;
			 ast: anAst;
			 yourself) "I want to get the class I do not need the AST"
]

{ #category : 'accessing' }
CooNewTemporalCache >> selectorDescriptions [

	^ selectorDescriptions
]

{ #category : 'accessing' }
CooNewTemporalCache >> selectors [
	^ selectors
]
