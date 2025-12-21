"
This class locates or clones a Git repository, fetches a chosen number of commits, and prints each commit’s metadata and diff contents with a structured visitor.

Initial code:

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
		""this looks super dangerous 
		
		location exists ifTrue: [ location ensureDeleteAll ].""
		
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
		'location',
		'repositoryURL',
		'commitCount'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'instance creation' }
HistoryScrapper class >> fetchRepo: aURLString [
	"Fetch and show commits for the given repository URL.
	Usage: HistoryScrapper fetchRepo: 'https://github.com/pharo-spec/Spec'"
	
	^ self new
		repositoryURLString: aURLString;
		initializeRepository;
		fetchLatestCommits;
		yourself
]

{ #category : 'instance creation' }
HistoryScrapper class >> fetchRepo: aURLString commits: aNumber [
	"Fetch and show a specific number of commits for the given repository URL.
	Usage: 
	
	HistoryScrapper fetchRepo: 'https://github.com/pharo-spec/Spec' commits: 20"
	
	^ self new
		repositoryURLString: aURLString;
		commitCount: aNumber;
		initializeRepository;
		fetchLatestCommits;
		yourself
]

{ #category : 'example' }
HistoryScrapper class >> spec10 [
	<script>
	^ self fetchRepo: 'https://github.com/pharo-spec/Spec' commits: 10
]

{ #category : 'example' }
HistoryScrapper class >> toplo [
	<script>
	^ self fetchRepo: 'git@github.com:pharo-graphics/Toplo.git' commits: 10
]

{ #category : 'actions' }
HistoryScrapper >> cloneRepositoryToTemporaryLocationFrom: url [
	"Clone the repository to a temporary location."

	| creator |
	""
	Transcript
		show: 'Cloning repository to: ' , location pathString;
		cr.
		
	location := FileLocator tmp  / 'iceberg-repos' / (url copyAfterLast: $/).
	location parent ensureCreateDirectory.
	creator := IceRepositoryCreator new
		           url: url;
		           location: location;
		           yourself.

	^ [ creator createRepository ]
		  on: IceDuplicatedRepository
		  do: [ :ex | ex return: ex repository ]
]

{ #category : 'accessing' }
HistoryScrapper >> commitCount [
	"Answer the number of commits to fetch (default: 10)"
	
	^ commitCount
]

{ #category : 'accessing' }
HistoryScrapper >> commitCount: aNumber [
	
	commitCount := aNumber
]

{ #category : 'actions' }
HistoryScrapper >> fetchLatestCommits [
	"Fetch remote changes and answer the requested number of commits."
	
	Transcript show: 'Fetching latest ', commitCount asString, ' changes...'; cr.
	repository fetch.
	^ repository head withCommitWalkDo: [ :walk |
		walk
			maxNumber: commitCount;
			commits ]
]

{ #category : 'initialization' }
HistoryScrapper >> initializeRepository [
	"Find or clone the repository locally."

	| url |
	url := self repositoryURLString.
	url ifNil: [ self error: 'Repository URL must be set before initializing' ].
	
	
	repository := IceRepository registry
		detect: [ :repo | 
			repo remotes anySatisfy: [ :remote | 
				remote url = url or: [ remote url = (url , '.git') ] ] ]
		ifNone: [ "self cloneRepositoryFrom: url" 
			"Ok it was a clone to a temporary repo, so we may try.
			we should not blindly remove the files because the person may have
			not pushed the changes."
			nil
			].
	repository ifNil: [ ^ self ].
	self registerRepositoryIfNeeded
]

{ #category : 'actions' }
HistoryScrapper >> registerRepositoryIfNeeded [

	(IceRepository registry includes: repository)
		ifFalse: [ repository register ]
]

{ #category : 'accessing' }
HistoryScrapper >> repository: aRepo [
	repository := aRepo
]

{ #category : 'accessing' }
HistoryScrapper >> repositoryURLString [
	"Answer the repository URL"
	
	^ repositoryURL
]

{ #category : 'accessing' }
HistoryScrapper >> repositoryURLString: aString [
	
	repositoryURL := aString
]
