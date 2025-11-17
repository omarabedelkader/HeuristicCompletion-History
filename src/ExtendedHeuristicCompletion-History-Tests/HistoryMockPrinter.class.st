Class {
	#name : 'HistoryMockPrinter',
	#superclass : 'Object',
	#instVars : [
		'visitedNodes'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockPrinter >> initialize [
    super initialize.
    visitedNodes := OrderedCollection new
]

{ #category : 'accessing' }
HistoryMockPrinter >> visitAddition: anAddition [
    visitedNodes add: anAddition
]

{ #category : 'accessing' }
HistoryMockPrinter >> visitModification: aModification [
    visitedNodes add: aModification
]

{ #category : 'accessing' }
HistoryMockPrinter >> visitedNodes [
    ^ visitedNodes
]
