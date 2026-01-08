"
I'm recording structrure that records modified or added methods and classes.
My behavior is to record everything. 

I pay attention to not hold directly class or compiled method objects to avoid creating spurious references. 

"
Class {
	#name : 'CooTemporalHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'selectorDescriptions',
		'classDescriptions'
	],
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'class handling' }
CooTemporalHandler >> addClassItem: anItem [

	classDescriptions addFirst: anItem
]

{ #category : 'method handling' }
CooTemporalHandler >> addMethodItem: anItem [

	selectorDescriptions addFirst: anItem
]

{ #category : 'method handling' }
CooTemporalHandler >> addModifiedMethodInVocabulary: anAnn [

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
CooTemporalHandler >> addNewClassInVocabulary: ann [

	self addClassItem: (CooAddedClassHistoryItem new
			 nameOfClass: ann classAdded name;
			live: true;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"timestamp: DateAndTime now;
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'method handling' }
CooTemporalHandler >> addNewMethodInVocabulary: anAnn [

	self addMethodItem: (CooAddedMethodHistoryItem new
			 selector: anAnn method selector;
			 live: true;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself) "we could also decide that when a class gets a new method the name of the class is getting more important. 
	Focus of attention. So this can be computed latter based on such information. "
]

{ #category : 'class handling' }
CooTemporalHandler >> addVariableItem: anItem [

	classDescriptions addFirst: anItem
]

{ #category : 'accessing' }
CooTemporalHandler >> classEntries [

	^ classDescriptions collect: [ :each | (NECGlobalEntry contents: each className node: nil) fetcher: CooTemporalHandler ]
]

{ #category : 'initialization' }
CooTemporalHandler >> initialize [

	super initialize.
	selectorDescriptions := OrderedCollection new.
	classDescriptions := OrderedCollection new
]

{ #category : 'printing' }
CooTemporalHandler >> printOn: aStream [

	super printOn: aStream.
	aStream space ; nextPutAll: 'mths: '; print: selectorDescriptions size.
	aStream space ; nextPutAll: 'cls '; print: classDescriptions size.
]

{ #category : 'initialization' }
CooTemporalHandler >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	selectorDescriptions add: (CooMethodHistoryItem new
			 selector: aSelector;
			 time: aDateAndTime;
			 ast: anAst;
			 yourself) 
]

{ #category : 'class handling' }
CooTemporalHandler >> removeClassFromVocabulary: ann [

	self addClassItem: (CooRemovedClassHistoryItem new
			 nameOfClass: ann classRemoved name;
			 "meta: anAnn classAdded check if we get the classAdded for metaclass"
			live: true;
			timestamp: DateAndTime now;

			 yourself)
]

{ #category : 'method handling' }
CooTemporalHandler >> removeMethodFromVocabulary: anAnn [

	self addMethodItem: (CooRemovedMethodHistoryItem new
			 selector: anAnn method selector;
			live: true;
			 timestamp: DateAndTime now;
			 nameOfClass: anAnn method methodClass name;
			 yourself)
]

{ #category : 'accessing' }
CooTemporalHandler >> selectorDescriptions [

	^ selectorDescriptions
]

{ #category : 'accessing' }
CooTemporalHandler >> selectorEntries [

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
										ifFalse: [ 
											each selector ifNotNil: [
												"we should find how this is possible to get a description with a nil selector." 
											selectors add: each selector ] ] ] ].
	^ selectors	collect: [ :each | (NECSelectorEntry contents: each  node: nil) fetcher: self ]
]

{ #category : 'accessing' }
CooTemporalHandler >> size [ 

	^ selectorDescriptions size
]

{ #category : 'accessing' }
CooTemporalHandler >> variableDescriptions [

	^ classDescriptions
]
