Class {
	#name : 'HistoryScrapperTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper'
}

{ #category : 'tests' }
HistoryScrapperTest >> testFetchLatestCommitsConfiguresWalker [

	| scrapper repository head walk commits |
	scrapper := HistoryScrapper new.
	repository := HistoryMockRepository new.
	walk := HistoryMockCommitWalk new.
	walk commits: #( mockCommit ).
	head := HistoryMockHead new.
	head walk: walk.
	repository head: head.
	scrapper instVarNamed: 'repository' put: repository.
	scrapper commitCount: 5.
	commits := scrapper fetchLatestCommits.
	self assert: repository fetchCount equals: 1.
	self assert: walk maxNumber equals: 5.
	self assert: commits equals: #( mockCommit )
]
