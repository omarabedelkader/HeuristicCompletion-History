"
I'm a simple datastructure like object that represents history event.
live means that I have been created during a live session and not during a replay.
"
Class {
	#name : 'CooHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'commit',
		'className',
		'live',
		'timestamp'
	],
	#category : 'ExtendedHeuristicCompletion-History-StructuralModel',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'StructuralModel'
}

{ #category : 'accessing' }
CooHistoryItem >> date [
	self deprecated: 'use timestamp' transformWith: '`@rec date' -> '`@rec timestamp'.
	^ timestamp
]

{ #category : 'accessing' }
CooHistoryItem >> date: avar [
	self deprecated: 'use timestamp' transformWith: '`@rec date: `@var' -> '`@rec timestamp: `@var'.
	timestamp := avar
]

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

{ #category : 'accessing' }
CooHistoryItem >> timestamp [

	^ timestamp
]

{ #category : 'accessing' }
CooHistoryItem >> timestamp: aTimestamp [

	timestamp := aTimestamp
]
