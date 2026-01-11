Class {
	#name : 'HistoryScrapperTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper'
}

{ #category : 'tests' }
HistoryScrapperTest >> testFetchLatestCommitsConfiguresWalker [

	| scrapper |
	scrapper := HistoryScrapper new.
	self assert: scrapper commitCount equals: 10
]

{ #category : 'tests' }
HistoryScrapperTest >> testInitializeRepositoryRequiresURL [

	| scrapper |
	scrapper := HistoryScrapper new.
	self
		should: [ scrapper initializeRepository ]
		raise: Error
]
