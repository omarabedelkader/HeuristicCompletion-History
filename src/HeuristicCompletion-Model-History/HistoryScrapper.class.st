"
```st
| url repository commits location |

""Set your repository URL""
url := 'https://github.com/omarabedelkader/ChatPharo'.

""Set location for the clone""
location := FileLocator temp / 'iceberg-repos' / 'ChatPharo'.

""Try to find existing repository, or clone it""
repository := IceRepository registry 
	detect: [ :repo | 
		repo remotes anySatisfy: [ :remote | 
			remote url = url or: [ remote url = (url, '.git') ] ] ]
	ifNone: [ 
		| creator |
		Transcript show: 'Cloning repository to: ', location pathString; cr.
		
		""Ensure parent directory exists""
		location parent ensureCreateDirectory.
		
		""Remove existing directory if present to avoid conflicts""
		location exists ifTrue: [ location ensureDeleteAll ].
		
		creator := IceRepositoryCreator new
			url: url;
			location: location;
			yourself.
		
		[ creator createRepository ] 
			on: IceDuplicatedRepository 
			do: [ :ex | ex return: ex repository ] ].

""Ensure repository is registered""
(IceRepository registry includes: repository) 
	ifFalse: [ repository register ].

""Fetch latest changes from remote""
Transcript show: 'Fetching latest changes...'; cr.
repository fetch.

""Get last 10 commits from HEAD""
commits := repository head withCommitWalkDo: [ :walk |
	walk 
		maxNumber: 10;
		commits ].

""Print commits""
Transcript show: '=== Last 10 Commits ==='; cr; cr.
commits do: [ :commit |
	Transcript 
		show: commit shortId; 
		show: ' | ';
		show: commit author; 
		show: ' | ';
		show: commit datetime asLocalStringYMDHM; 
		cr;
		show: '    ';
		show: commit comment; 
		cr; cr ].

Transcript show: 'Done!'; cr.

```
"
Class {
	#name : 'HistoryScrapper',
	#superclass : 'Object',
	#instVars : [
		'repository',
		'location'
	],
	#classInstVars : [
		'RepositoryURL'
	],
	#category : 'HeuristicCompletion-Model-History',
	#package : 'HeuristicCompletion-Model-History'
}

{ #category : 'as yet unclassified' }
HistoryScrapper class >> fetchAndShowCommits [

	| inspector |
	inspector := self new.
	inspector
		initializeRepository;
		fetchLatestCommitsAndPrint.
]

{ #category : 'as yet unclassified' }
HistoryScrapper class >> repositoryURL [

	^ RepositoryURL ifNil: [ RepositoryURL := 'https://github.com/omarabedelkader/ChatPharo' ]

]

{ #category : 'as yet unclassified' }
HistoryScrapper class >> repositoryURL: aString [

	RepositoryURL := aString.
]

{ #category : 'as yet unclassified' }
HistoryScrapper >> cloneRepositoryFrom: url [
	"Clone the repository to a temporary location."
	| creator |
	Transcript show: 'Cloning repository to: ', location pathString; cr.

	location parent ensureCreateDirectory.
	location exists ifTrue: [ location ensureDeleteAll ].

	creator := IceRepositoryCreator new
		url: url;
		location: location;
		yourself.

	^ [ creator createRepository ]
		on: IceDuplicatedRepository
		do: [ :ex | ex return: ex repository ].
]

{ #category : 'as yet unclassified' }
HistoryScrapper >> fetchLatestCommitsAndPrint [
	"Fetch remote changes and show last 10 commits with diffs."
	| commits |
	Transcript show: 'Fetching latest changes...'; cr.
	repository fetch.

	commits := repository head withCommitWalkDo: [ :walk |
		walk maxNumber: 10; commits ].

	Transcript cr; show: '=== Last 10 Commits with Contents ==='; cr; cr.

	commits doWithIndex: [ :commit :index |
		self printCommit: commit index: index ].

	Transcript show: 'Done!'; cr.
]

{ #category : 'as yet unclassified' }
HistoryScrapper >> initializeRepository [
	"Find or clone the repository locally."
	| url |
	url := self class repositoryURL.
	location := FileLocator temp / 'iceberg-repos' / (url copyAfterLast: $/).

	repository := IceRepository registry
		detect: [ :repo | 
			repo remotes anySatisfy: [ :remote | 
				remote url = url or: [ remote url = (url, '.git') ] ] ]
		ifNone: [ self cloneRepositoryFrom: url ].

	(IceRepository registry includes: repository)
		ifFalse: [ repository register ].
]

{ #category : 'as yet unclassified' }
HistoryScrapper >> printCommit: commit index: index [
	| diff printer |
	printer := HistoryPrinter new
		transcript: Transcript;
		indent: '  ';
		yourself.

	Transcript
		show: '--- Commit ', index asString, ' ---'; cr;
		show: 'Hash:   ', commit shortId; cr;
		show: 'Author: ', commit author; cr;
		show: 'Date:   ', commit datetime asLocalStringYMDHM; cr;
		show: 'Message: ', commit comment; cr; cr.

	diff := commit diffToParent.

	diff ifNotNil: [
		diff isEmpty
			ifTrue: [ Transcript show: '  (No changes)'; cr ]
			ifFalse: [
				Transcript show: 'Changes:'; cr.
				diff tree allChildrenDo: [ :node | node value accept: printer ].
			]
	].
]
