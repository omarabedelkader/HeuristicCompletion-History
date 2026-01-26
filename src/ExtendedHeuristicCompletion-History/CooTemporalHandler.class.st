"
I'm recording structrure that records modified or added methods and classes.
My behavior is to record everything. 

I pay attention to not hold directly class or compiled method objects to avoid creating spurious references. 

"
Class {
	#name : 'CooTemporalHandler',
	#superclass : 'CooProgramEntityHandler',
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'adding' }
CooTemporalHandler >> addMethodItem: aCooAddedMethodHistoryItem [ 
	self handleNewMethodItem: aCooAddedMethodHistoryItem addedTo: methodDescriptions
]

{ #category : 'accessing' }
CooTemporalHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class
	
	
	"
	
	^ classDescriptions collect: [ :each | (NECGlobalEntry contents: each nameOfClass node: nil) fetcher: CooTemporalHandler ]
]

{ #category : 'api' }
CooTemporalHandler >> handleNewClassItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
	
	(anItem event = #removed)
		ifTrue: [ 
			"when a class was removed we remove all the class addition with the same name"
			classDescriptions := classDescriptions copy reject: [ :each | each nameOfClass = anItem nameOfClass] ]
		ifFalse: [  classDescriptions addFirst: anItem ]
	
]

{ #category : 'api' }
CooTemporalHandler >> handleNewMethodItem: anItem addedTo: aCollection [
	
	(anItem event = #removed)
		ifTrue: [ 
			"when a method is removed we remove all the method addition and modification of that method"
			methodDescriptions := methodDescriptions copy reject: [ :each | 
				each ~~ anItem and: [ each nameOfClass = anItem nameOfClass and: [ each selector = anItem selector ] ] ] ]
		ifFalse: [  methodDescriptions addFirst: anItem ]
	
]

{ #category : 'initialization' }
CooTemporalHandler >> initialize [

	super initialize.
	classDescriptions := OrderedCollection new.
	methodDescriptions := OrderedCollection new.
]

{ #category : 'accessing' }
CooTemporalHandler >> methodSize [ 

	^ methodDescriptions size
]

{ #category : 'printing' }
CooTemporalHandler >> printOn: aStream [

	super printOn: aStream.

]

{ #category : 'initialization' }
CooTemporalHandler >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	methodDescriptions add: (CooMethodHistoryItem new
			 selector: aSelector;
			 timestamp: aDateAndTime;
			 ast: anAst;
			 yourself)
]

{ #category : 'accessing' }
CooTemporalHandler >> selectorEntries [
	
	^ (methodDescriptions reject: [ :each | each event = #removed ])
		collect: [ :each | (NECSelectorEntry contents: each selector node: nil) fetcher: 'TemporalHandler' ]
]

{ #category : 'accessing' }
CooTemporalHandler >> size [ 
	^ methodDescriptions size
]
