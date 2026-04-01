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

{ #category : 'matching' }
CooLRUHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class"

	| col |
	col := OrderedCollection new.
	classLRU keysAndValuesDo: [ :k :v | 
		col add: ((NECSessionGlobalEntry contents: v nameOfClass node: nil)
					 sessionItem: v;
					 fetcher: 'Session LRU';
					 yourself) ].
	^ col
]

{ #category : 'matching' }
CooLRUHandler >> handleNewClassItem: anItem addedTo: aCollection [

	classLRU at: anItem nameOfClass put: anItem
]

{ #category : 'matching' }
CooLRUHandler >> handleNewMethodItem: anItem addedTo: aCollection [

	selectorLRU at: anItem selector put: anItem
]

{ #category : 'initialization' }
CooLRUHandler >> initialize [ 

	super initialize.
	selectorLRU := LRUCache new maximumWeight: 1000.
	classLRU := LRUCache new maximumWeight: 1000
]

{ #category : 'matching' }
CooLRUHandler >> selectorEntries [
	"Clearly we should manage what happen when we remove a class"
	
	
	| col |
	col := OrderedCollection new. 
	selectorLRU keysAndValuesDo: [ :k :v | 
		col add: 
			((NECSessionSelectorEntry contents: v selector node: nil)
				  sessionItem: v;
				  fetcher: 'Session LRU';
					yourself )
			].
	^ col 
]
