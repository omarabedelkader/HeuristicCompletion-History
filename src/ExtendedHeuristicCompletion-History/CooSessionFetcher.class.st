Class {
	#name : 'CooSessionFetcher',
	#superclass : 'CoFetcher',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'accessing' }
CooSessionFetcher >> session [
	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooSessionFetcher >> session: aCoSession [
	
	session := aCoSession 
]
