"
I'm the superclass of the items (add addition, item selection, class navigation) that are passed to session handlers to propose some completion choices. 
"
Class {
	#name : 'CooItem',
	#superclass : 'Object',
	#instVars : [
		'timestamp'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'accessing' }
CooItem >> timestamp [

	^ timestamp
]

{ #category : 'accessing' }
CooItem >> timestamp: aTimestamp [

	timestamp := aTimestamp
]
