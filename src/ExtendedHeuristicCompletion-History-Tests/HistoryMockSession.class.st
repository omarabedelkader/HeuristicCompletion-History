Class {
	#name : 'HistoryMockSession',
	#superclass : 'Object',
	#instVars : [
		'registrations'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockSession >> initialize [
    super initialize.
    registrations := OrderedCollection new
]

{ #category : 'accessing' }
HistoryMockSession >> registerSelector: aSelector ast: anAst event: anEvent at: aTimestamp [
    registrations add: (Dictionary new
        at: #selector put: aSelector;
        at: #ast put: anAst;
        at: #event put: anEvent;
        at: #timestamp put: aTimestamp;
        yourself)
]

{ #category : 'accessing' }
HistoryMockSession >> registrations [
    ^ registrations
]
