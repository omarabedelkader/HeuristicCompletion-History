Class {
	#name : 'CooVariableSessionFetcher',
	#superclass : 'CoSessionFetcher',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'enumerating' }
CooVariableSessionFetcher >> entriesDo: aBlock [

	self session classEntries  
		do: [ :e | aBlock value: (e node: astNode) ]
]
