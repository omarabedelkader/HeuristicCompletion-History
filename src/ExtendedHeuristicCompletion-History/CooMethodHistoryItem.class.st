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

{ #category : 'testing' }
CooMethodHistoryItem class >> isMessageCompletionSelector: aSelector [

	| selector |
	aSelector ifNil: [ ^ false ].
	selector := aSelector asSymbol.
	^ selector isUnary or: [ selector isKeyword ]
]

{ #category : 'accessing' }
CooMethodHistoryItem class >> messageCompletionSelectorsFromAST: aMethodAst [

	aMethodAst ifNil: [ ^ #(  ) ].
	^ ((aMethodAst allChildren select: [ :each | each isMessage ])
		   collect: [ :each | each selector ])
		  select: [ :each | self isMessageCompletionSelector: each ]
]

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
