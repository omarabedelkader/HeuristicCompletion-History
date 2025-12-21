Class {
	#name : 'HistoryScrapperTestDouble',
	#superclass : 'HistoryScrapper',
	#instVars : [
		'testPrinter'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'printing' }
HistoryScrapperTestDouble >> printCommit: commit index: index [

	| diff printer |
	self printCommitHeader: commit index: index.
	diff := commit diffToParent.
	diff ifNil: [ ^ self ].
	diff isEmpty
		ifTrue: [ Transcript show: '  (No changes)'; cr ]
		ifFalse: [
			Transcript show: 'Changes:'; cr.
			printer := self printer.
			diff tree allChildrenDo: [ :node | node value accept: printer ] ]
]

{ #category : 'as yet unclassified' }
HistoryScrapperTestDouble >> printCommitHeader: commit index: index [ 
    "Avoid transcript writes during tests"
]

{ #category : 'printing' }
HistoryScrapperTestDouble >> printCommits: commits [

	commits ifNil: [ ^ Transcript show: 'No commits found.'; cr ].
	commits ifEmpty: [ ^ Transcript show: 'No commits found.'; cr ].
	Transcript cr; show: '=== Last 10 Commits with Contents ==='; cr; cr.
	commits withIndexDo: [ :commit :index | self printCommit: commit index: index ].
	Transcript show: 'Done!'; cr
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
