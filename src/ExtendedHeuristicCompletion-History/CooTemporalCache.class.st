"
I'm recording structrure that records modified or added methods and classes.
My behavior is to record everything. 

I pay attention to not hold directly class or compiled method objects to avoid creating spurious references. 

"
Class {
	#name : 'CooTemporalCache',
	#superclass : 'CooCache',
	#instVars : [
		'selectorDescriptions',
		'variableDescriptions'
	],
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'method handling' }
CooTemporalCache >> addMethodItem: anItem [

	selectorDescriptions addFirst: anItem
]

{ #category : 'method handling' }
CooTemporalCache >> addModifiedMethodInVocabulary: anAnn [

	| deltaMessage item |
	deltaMessage := self computeDeltaMessageOf: anAnn.
	item := CooModifiedMethodHistoryItem new
		        selector: anAnn method selector;
		        timestamp: DateAndTime now;
		        nameOfClass: anAnn method methodClass name;
		        yourself.
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	self addMethodItem: item
]

{ #category : 'method handling' }
CooTemporalCache >> addNewMethodInVocabulary: anAnn [

	self addMethodItem: (CooAddedMethodHistoryItem new
			 selector: anAnn method selector;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'class handling' }
CooTemporalCache >> addNewVariableInVocabulary: ann [

	self addVariableItem: (CooAddedVariableHistoryItem new
			 nameOfClass: ann classAdded name;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"timestamp: DateAndTime now;
		
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'class handling' }
CooTemporalCache >> addVariableItem: anItem [

	variableDescriptions addFirst: anItem
]

{ #category : 'accessing - computed' }
CooTemporalCache >> computeDeltaMessageOf: aCooMockMethodModified [

	^ ((aCooMockMethodModified method ast allChildren select: [ :each | each isMessage ])
			collect: [ :each | each selector ])
		  difference:
		  ((aCooMockMethodModified oldMethod ast allChildren select: [ :each | each isMessage ]) 
				collect: [ :each | each selector ])
]

{ #category : 'initialization' }
CooTemporalCache >> initialize [

	super initialize.
	selectorDescriptions := OrderedCollection new.
	variableDescriptions := OrderedCollection new
]

{ #category : 'initialization' }
CooTemporalCache >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	selectorDescriptions add: (CooMethodHistoryItem new
			 selector: aSelector;
			 time: aDateAndTime;
			 ast: anAst;
			 yourself) 
]

{ #category : 'method handling' }
CooTemporalCache >> removeMethodFromVocabulary: anAnn [

	self addMethodItem: (CooRemovedMethodHistoryItem new
			 selector: anAnn method selector;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself)
]

{ #category : 'class handling' }
CooTemporalCache >> removeVariableFromVocabulary: ann [

	self addVariableItem: (CooRemovedVariableHistoryItem new
			 nameOfClass: ann classRemoved name;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"
			timestamp: DateAndTime now;

			 yourself)
]

{ #category : 'accessing' }
CooTemporalCache >> selectorDescriptions [

	^ selectorDescriptions
]

{ #category : 'accessing' }
CooTemporalCache >> selectors [

	| selectors filters |
	selectors := OrderedCollection new: selectorDescriptions size.
	"this cries for a little hierarchy for message history item."
	"an add CM1, add/modified CM1, add CM1, removed CM1 = {}"
	
	"The following does implement this semantics removed CM1, add CM1 = CM1"
	
	filters := OrderedCollection new.
	selectorDescriptions do: [ :each | 
		(each event = #removed)
				ifTrue: [ filters add: each ]
				ifFalse: [ (filters anySatisfy: [ :f | ((f selector = each selector ) 
																		and: [ f nameOfClass = each nameOfClass ])])
										ifFalse: [ selectors add: each selector ] ] ].
	^ selectors	
]

{ #category : 'accessing' }
CooTemporalCache >> variableDescriptions [

	^ variableDescriptions
]

{ #category : 'accessing' }
CooTemporalCache >> variableNames [

	^ variableDescriptions collect: [ :each | each className ]
]
