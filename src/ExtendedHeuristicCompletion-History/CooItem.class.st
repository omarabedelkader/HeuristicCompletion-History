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
