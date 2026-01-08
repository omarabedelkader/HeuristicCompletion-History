Class {
	#name : 'CooLRUHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'selectorLRU'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'initialization' }
CooLRUHandler >> initialize [ 

	super initialize.
	selectorLRU := LRUCache new maximumWeight: 1000
]
