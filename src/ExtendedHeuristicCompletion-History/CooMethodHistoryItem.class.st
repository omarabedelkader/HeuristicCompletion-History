"
I'm a little datastructure like object that hold information about the newly defined, modified methods.

"
Class {
	#name : 'CooMethodHistoryItem',
	#superclass : 'CooHistoryItem',
	#instVars : [
		'selector',
		'deltaMessages'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'accessing' }
CooMethodHistoryItem >> deltaMessages [
	^ deltaMessages
]

{ #category : 'accessing' }
CooMethodHistoryItem >> deltaMessages: aCollection [ 
	deltaMessages := aCollection
]

{ #category : 'accessing' }
CooMethodHistoryItem >> printOn: aStream [

	aStream nextPutAll: self nameOfClass.
	aStream nextPutAll: ' >> ', selector
]

{ #category : 'accessing' }
CooMethodHistoryItem >> selector [

	^ selector
]

{ #category : 'accessing' }
CooMethodHistoryItem >> selector: anObject [

	selector := anObject
]
