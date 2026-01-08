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

{ #category : 'accessing' }
CooTemporalHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class
	
	
	"
	
	^ classDescriptions collect: [ :each | (NECGlobalEntry contents: each nameOfClass node: nil) fetcher: CooTemporalHandler ]
]

{ #category : 'as yet unclassified' }
CooTemporalHandler >> handleNewClassItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
	
	(anItem event = #removed)
		ifTrue: [ 
			"when a class was removed we remove all the class addition with the same name"
			classDescriptions := classDescriptions copy reject: [ :each | each nameOfClass = anItem nameOfClass] ]
		ifFalse: [  classDescriptions addFirst: anItem ]
	
]

{ #category : 'as yet unclassified' }
CooTemporalHandler >> handleNewMethodItem: anItem addedTo: aCollection [
	
	(anItem event = #removed)
		ifTrue: [ 
			"when a method is removed we remove all the method addition and modification of that method"
			methodDescriptions := methodDescriptions copy reject: [ :each | each nameOfClass = anItem nameOfClass and: [ each selector = anItem selector ] ] ]
		ifFalse: [  classDescriptions addFirst: anItem ]
	
]

{ #category : 'as yet unclassified' }
CooTemporalHandler >> initialize [

	super initialize.
	classDescriptions := OrderedCollection new.
	methodDescriptions := OrderedCollection new.
]

{ #category : 'printing' }
CooTemporalHandler >> printOn: aStream [

	super printOn: aStream.

]

{ #category : 'initialization' }
CooTemporalHandler >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	methodDescriptions add: (CooMethodHistoryItem new
			 selector: aSelector;
			 time: aDateAndTime;
			 ast: anAst;
			 yourself) 
]

{ #category : 'accessing' }
CooTemporalHandler >> selectorEntries [
	
	^ methodDescriptions 	collect: [ :each | (NECSelectorEntry contents: each selector node: nil) fetcher: 'TemporalHandler' ]
]

{ #category : 'accessing' }
CooTemporalHandler >> size [ 

	^ methodDescriptions size
]
