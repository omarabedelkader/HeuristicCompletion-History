"
I'm recording program elements e.g., modified or added methods and classes.
My behavior is to record everything. Other variations may keep only the last ones.

I pay attention to not hold directly class or compiled method objects to avoid creating spurious references. 

"
Class {
	#name : 'CooTemporalHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'classDescriptions',
		'methodDescriptions'
	],
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'adding' }
CooTemporalHandler >> addMethodItem: aCooAddedMethodHistoryItem [ 
	self handleNewMethodItem: aCooAddedMethodHistoryItem
]

{ #category : 'accessing' }
CooTemporalHandler >> classDescriptions [

	^ classDescriptions
]

{ #category : 'accessing' }
CooTemporalHandler >> classDescriptions: aCollection [

	classDescriptions := aCollection
]

{ #category : 'accessing' }
CooTemporalHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class
	
	"

	^ classDescriptions collect: [ :each |
			  (CoGlobalEntry contents: each nameOfClass node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Temporal' ]
]

{ #category : 'api' }
CooTemporalHandler >> handleNewClassItem: anItem [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."

	anItem event = #removed
		ifTrue: [ "when a class was removed we remove all the class addition with the same name"
			classDescriptions := classDescriptions reject: [ :each | each nameOfClass = anItem nameOfClass ].
			methodDescriptions := methodDescriptions reject: [ :each |
		                      each nameOfClass = anItem nameOfClass ]]
		ifFalse: [ classDescriptions addFirst: anItem ]
]

{ #category : 'api' }
CooTemporalHandler >> handleNewMethodItem: anItem [

	anItem event = #removed
		ifTrue: [ "when a method is removed we remove all the method addition and modification of that method"
			self removeMethodItem: anItem ]
		ifFalse: [ methodDescriptions addFirst: anItem ]
]

{ #category : 'initialization' }
CooTemporalHandler >> initialize [

	super initialize.
	classDescriptions := OrderedCollection new.
	methodDescriptions := OrderedCollection new.
]

{ #category : 'accessing' }
CooTemporalHandler >> methodDescriptions [

	^ methodDescriptions
]

{ #category : 'accessing' }
CooTemporalHandler >> methodDescriptions: aCollection [

	methodDescriptions := aCollection
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

{ #category : 'api' }
CooTemporalHandler >> removeMethodItem: anItem [

	methodDescriptions := methodDescriptions reject: [ :each |
		                      each nameOfClass = anItem nameOfClass and: [ each selector = anItem selector ] ]
]

{ #category : 'accessing' }
CooTemporalHandler >> selectorEntries [

	^ methodDescriptions collect: [ :each |
			  (CoSelectorEntry contents: each selector node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Temporal' ]
]
