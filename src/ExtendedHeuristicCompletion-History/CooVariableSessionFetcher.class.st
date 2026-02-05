Class {
	#name : 'CooVariableSessionFetcher',
	#superclass : 'CooSessionFetcher',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'enumerating' }
CooVariableSessionFetcher >> entriesDo: aBlock [

	self session classEntries  
		do: [ :e | aBlock value: (e node: astNode) ]
]
