"
I'm a little datastructure like object that hold information about the newly defined, modified methods.

"
Class {
	#name : 'CooMessageHistoryItem',
	#superclass : 'CooHistoryItem',
	#instVars : [
		'selector',
		'ast',
		'deltaMessages'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'accessing' }
CooMessageHistoryItem >> deltaMessages [
	^ deltaMessages
]

{ #category : 'accessing' }
CooMessageHistoryItem >> deltaMessages: aCollection [ 
	deltaMessages := aCollection
]

{ #category : 'accessing' }
CooMessageHistoryItem >> printOn: aStream [

	aStream nextPutAll: self nameOfClass.
	aStream nextPutAll: ' >> ', selector
]

{ #category : 'accessing' }
CooMessageHistoryItem >> selector [

	^ selector
]

{ #category : 'accessing' }
CooMessageHistoryItem >> selector: anObject [

	selector := anObject
]
