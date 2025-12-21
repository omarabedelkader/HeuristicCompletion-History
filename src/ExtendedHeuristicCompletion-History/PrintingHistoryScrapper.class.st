Class {
	#name : 'PrintingHistoryScrapper',
	#superclass : 'HistoryScrapper',
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'printing' }
PrintingHistoryScrapper >> fetchLatestCommitsAndPrint [

	| commits |
	repository ifNil: [ ^ self ].
	commits := self fetchLatestCommits.
	self printCommits: commits.
]

{ #category : 'printing' }
PrintingHistoryScrapper >> printCommit: commit index: index [

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

{ #category : 'printing' }
PrintingHistoryScrapper >> printCommitHeader: commit index: index [

	Transcript
		show: '--- Commit ', index asString, ' ---'; cr;
		show: 'Hash:   ', commit shortId; cr;
		show: 'Author: ', commit author; cr;
		show: 'Date:   ', commit datetime asLocalStringYMDHM; cr;
		show: 'Message: ', commit comment; cr; cr
]

{ #category : 'printing' }
PrintingHistoryScrapper >> printCommits: commits [

	commits ifNil: [ ^ Transcript show: 'No commits found.'; cr ].
	commits ifEmpty: [ ^ Transcript show: 'No commits found.'; cr ].
	Transcript cr; show: '=== Last 10 Commits with Contents ==='; cr; cr.
	commits withIndexDo: [ :commit :index | self printCommit: commit index: index ].
	Transcript show: 'Done!'; cr
]

{ #category : 'printing' }
PrintingHistoryScrapper >> printer [

	^ HistoryPrinter new
		transcript: Transcript;
		indent: '  ';
		yourself
]
