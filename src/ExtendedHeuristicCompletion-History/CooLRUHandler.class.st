Class {
	#name : 'CooLRUHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'selectorLRU',
		'classLRU'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'initialization' }
CooLRUHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class"
	
	
	| col |
	col := OrderedCollection new. 
	classLRU keysAndValuesDo: [ :k :v | col add: v ].
	^ col 
]

{ #category : 'initialization' }
CooLRUHandler >> handleNewClassItem: anItem addedTo: aCollection [

	classLRU at: anItem name put: anItem
]

{ #category : 'initialization' }
CooLRUHandler >> handleNewMethodItem: anItem addedTo: aCollection [

	selectorLRU at: anItem selector put: anItem
]

{ #category : 'initialization' }
CooLRUHandler >> initialize [ 

	super initialize.
	selectorLRU := LRUCache new maximumWeight: 1000.
	classLRU := LRUCache new maximumWeight: 1000
]

{ #category : 'initialization' }
CooLRUHandler >> selectorEntries [
	"Clearly we should manage what happen when we remove a class"
	
	
	| col |
	col := OrderedCollection new. 
	selectorLRU keysAndValuesDo: [ :k :v | col add: v ].
	^ col 
]
