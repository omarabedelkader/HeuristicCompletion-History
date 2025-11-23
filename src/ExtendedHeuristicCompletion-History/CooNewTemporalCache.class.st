"
I'm recording structrure that records modified or added methods and classes.
My behavior is to record everything. 

I pay attention to not hold directly class or compiled method objects to avoid creating spurious references. 

"
Class {
	#name : 'CooNewTemporalCache',
	#superclass : 'Object',
	#instVars : [
		'selectorDescriptions',
		'variableDescriptions'
	],
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'initialization' }
CooNewTemporalCache >> addModifiedMethodInVocabulary: anAnn [

	| deltaMessage item |
	deltaMessage := self computeDeltaMessageOf: anAnn.
	item := CooMessageHistoryItem new
		        selector: anAnn method selector;
		        date: DateAndTime now;
		        event: #modified;
		        nameOfClass: anAnn method methodClass name;
		        yourself.
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	selectorDescriptions add: item
]

{ #category : 'initialization' }
CooNewTemporalCache >> addNewMethodInVocabulary: anAnn [

	selectorDescriptions add: (CooMessageHistoryItem new
			 selector: anAnn method selector;
			 date: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'adding' }
CooNewTemporalCache >> addNewVariableInVocabulary: ann [

	variableDescriptions add: (CooVariableHistoryItem new
			 nameOfClass: ann classAdded name;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"date: DateAndTime now;
			 event: #added; 
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
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
	selectorDescriptions := OrderedCollection new.
	variableDescriptions := OrderedCollection new
]

{ #category : 'initialization' }
CooNewTemporalCache >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	selectorDescriptions add: (CooMessageHistoryItem new
			 selector: aSelector;
			 time: aDateAndTime;
			 ast: anAst;
			 yourself) 
]

{ #category : 'accessing' }
CooNewTemporalCache >> selectorDescriptions [

	^ selectorDescriptions
]

{ #category : 'accessing' }
CooNewTemporalCache >> selectors [

	^ selectorDescriptions collect: [ :each | each selector ]
]

{ #category : 'accessing' }
CooNewTemporalCache >> variableDescriptions [

	^ variableDescriptions
]

{ #category : 'accessing' }
CooNewTemporalCache >> variableNames [

	^ variableDescriptions collect: [ :each | each className ]
]
