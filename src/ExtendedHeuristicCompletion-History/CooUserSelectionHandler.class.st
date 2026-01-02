"
I'm a kind of strategy responsible for implementing different algorithms that sort and use the selection made by the user when prompted with a list of possible completion items.
"
Class {
	#name : 'CooUserSelectionHandler',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'as yet unclassified' }
CooUserSelectionHandler >> handleNewSelectionItem: aSelectionItem addedTo: aCollection [

	^ self subclassResponsibility 
]
