Class {
	#name : 'CoSessionFetcher',
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
CoSessionFetcher >> astNode [

	^ astNode
]

{ #category : 'accessing' }
CoSessionFetcher >> astNode: anObject [

	astNode := anObject
]

{ #category : 'accessing' }
CoSessionFetcher >> session [

	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CoSessionFetcher >> session: anObject [

	session := anObject
]
