"
I'm a little populator dedicated for benchmark logic: I **LOAD** commits and their loading affects the session.
In comparison, the CachePopulator does not load the code of commits
"
Class {
	#name : 'HistoryPopulatorForBench',
	#superclass : 'HistoryPopulator',
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'forBenchmarks' }
HistoryPopulatorForBench >> commitsForHead: aNumber [

	^ self scrapper commitsFromHead: aNumber
	
]
