Class {
	#name : 'CooLRUCache',
	#superclass : 'CooCache',
	#instVars : [
		'selectorLRU'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'initialization' }
CooLRUCache >> initialize [ 

	super initialize.
	selectorLRU := LRUCache new maximumWeight: 1000
]
