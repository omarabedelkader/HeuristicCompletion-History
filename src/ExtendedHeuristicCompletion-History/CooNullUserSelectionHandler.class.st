"
I'm drop support for user item selection.
"
Class {
	#name : 'CooNullUserSelectionHandler',
	#superclass : 'CooUserSelectionHandler',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'api' }
CooNullUserSelectionHandler >> sortedUserEntries [

	^ #()
]

{ #category : 'tracking' }
CooNullUserSelectionHandler >> sortedUserLowercasedEntries [
	
	^ #()
]

{ #category : 'tracking' }
CooNullUserSelectionHandler >> sortedUserUppercasedEntries [

		^ #()
]
