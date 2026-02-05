Class {
	#name : 'CooSessionFetcher',
	#superclass : 'CoFetcher',
	#instVars : [
		'astNode',
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'accessing' }
CooSessionFetcher >> astNode [

	^ astNode
]

{ #category : 'accessing' }
CooSessionFetcher >> astNode: anObject [

	astNode := anObject
]

{ #category : 'accessing' }
CooSessionFetcher >> session [

	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooSessionFetcher >> session: anObject [

	session := anObject
]
