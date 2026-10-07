"
I'm a simple datastructure like object that represents history event.
live means that I have been created during a live session and not during a replay.
"
Class {
	#name : 'CooHistoryItem',
	#superclass : 'CooItem',
	#instVars : [
		'commit',
		'className',
		'live'
	],
	#category : 'ExtendedHeuristicCompletion-History-StructuralModel',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'StructuralModel'
}

{ #category : 'initialization' }
CooHistoryItem >> initialize [

	super initialize.
	live := false
]

{ #category : 'accessing' }
CooHistoryItem >> live: aBoolean [ 
	live := aBoolean 
]

{ #category : 'accessing' }
CooHistoryItem >> nameOfClass [

	^ className
]

{ #category : 'accessing' }
CooHistoryItem >> nameOfClass: aClassName [

	className := aClassName
]

{ #category : 'serialization' }
CooHistoryItem >> prepareForSerialization [
	"for now"
	^ self
]

{ #category : 'printing' }
CooHistoryItem >> printOn: aStream [

	super printOn: aStream. 
	live 
		ifTrue: [ aStream nextPutAll: '(Liv)' ]
		ifFalse: [ aStream nextPutAll: '(Rep)' ].
	aStream space. 
	className
		ifNotNil: [ aStream nextPutAll: className ]
		ifNil: [ aStream nextPutAll: 'No class name!' ]
]
