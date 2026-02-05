Class {
	#name : 'CooMessageSessionFetcher',
	#superclass : 'CooSessionFetcher',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'enumerating' }
CooMessageSessionFetcher >> entriesDo: aBlock [

	self session selectorEntries  
		do: [ :e | aBlock value: (e node: astNode) ]
]
