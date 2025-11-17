Class {
	#name : 'HistoryScrapperTestDouble',
	#superclass : 'HistoryScrapper',
	#instVars : [
		'testPrinter'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'as yet unclassified' }
HistoryScrapperTestDouble >> printCommitHeader: commit index: index [ 
    "Avoid transcript writes during tests"
]

{ #category : 'as yet unclassified' }
HistoryScrapperTestDouble >> printer [
    ^ testPrinter ifNil: [ super printer ]
]

{ #category : 'as yet unclassified' }
HistoryScrapperTestDouble >> printer: aPrinter [
    testPrinter := aPrinter
]

{ #category : 'as yet unclassified' }
HistoryScrapperTestDouble >> repository: aRepository [
    repository := aRepository
]
