Class {
	#name : 'CooProgramEntityHandler',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooProgramEntityHandler >> handleNewClassItem: anItem addedTo: aCollection [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> handleNewMethodItem: anItem addedTo: aCollection [

	self subclassResponsibility
]

{ #category : 'matching' }
CooProgramEntityHandler >> selectorEntries [

	self subclassResponsibility
]

{ #category : 'accessing' }
CooProgramEntityHandler >> size [ 

	^ 0
]
