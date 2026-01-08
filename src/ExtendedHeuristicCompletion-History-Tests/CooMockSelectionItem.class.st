Class {
	#name : 'CooMockSelectionItem',
	#superclass : 'Object',
	#instVars : [
		'selectedItemEntry'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session-Mock'
}

{ #category : 'as yet unclassified' }
CooMockSelectionItem class >> forEntry: anEntry [

	^ self new
		selectedItemEntry: anEntry;
		yourself
]

{ #category : 'accessing' }
CooMockSelectionItem >> selectedItemEntry [

	^ selectedItemEntry
]

{ #category : 'accessing' }
CooMockSelectionItem >> selectedItemEntry: anEntry [

	selectedItemEntry := anEntry
]
