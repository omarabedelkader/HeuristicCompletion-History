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
	#category : 'ExtendedHeuristicCompletion-History-StructuralModel',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'StructuralModel'
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

{ #category : 'initialization' }
CooMethodHistoryItem >> initialize [ 

	super initialize.
	deltaMessages := #()
]

{ #category : 'accessing' }
CooMethodHistoryItem >> printOn: aStream [

	super printOn: aStream. 
	self ifNotNil: [  
		aStream nextPutAll: ' >> ', selector ]
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
