"
I'm a little datastructure like object that hold information about the newly defined, modified methods.

"
Class {
	#name : 'CooMethodHistoryItem',
	#superclass : 'CooHistoryItem',
	#instVars : [
		'selector',
		'deltaMessages',
		'ast'
	],
	#category : 'ExtendedHeuristicCompletion-History-Model',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Model'
}

{ #category : 'accessing' }
CooMethodHistoryItem >> ast [
	^ ast
]

{ #category : 'accessing' }
CooMethodHistoryItem >> ast: anOCMethodNode [ 
	ast := anOCMethodNode 
]

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

	anObject ifNil: [ ^ self halt ].
	selector := anObject
]
