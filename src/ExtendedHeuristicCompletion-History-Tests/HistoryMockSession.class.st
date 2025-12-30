Class {
	#name : 'HistoryMockSession',
	#superclass : 'Object',
	#instVars : [
		'registrations'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockSession >> initialize [
    super initialize.
    registrations := OrderedCollection new
]

{ #category : 'accessing' }
HistoryMockSession >> registerSelector: aSelector ast: anAst event: anEvent at: aTimestamp [

	registrations add: (CooAddedMethodHistoryItem new
			 selector: aSelector;
			 ast: anAst;
			 timestamp: aTimestamp;
			 yourself)
]

{ #category : 'accessing' }
HistoryMockSession >> registrations [
    ^ registrations
]
