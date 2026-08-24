"
Description of one experimental subject (a software repository) in the benchmark catalog.

I own:
- a stable name used in CSV files and paper tables
- an HTTPS clone URL
- an optional loadBlock preparing the exact project version required by the
  benchmark. The load step is mandatory because CooSession >> existingMethods
  can only resolve history entries against methods and classes currently
  loaded in the image.
- an optional replayBlock replacing the default Git-based history replay.
  Tests use it to replay deterministic local histories without network access.

The default replay uses HistoryCachePopulator and always targets the session
given as parameter, never CooSession current.
"
Class {
	#name : 'CooHistoryBenchmarkRepository',
	#superclass : 'Object',
	#instVars : [
		'name',
		'url',
		'loadBlock',
		'replayBlock',
		'lastHeadShortId'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Model',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Model'
}

{ #category : 'instance creation' }
CooHistoryBenchmarkRepository class >> name: aString url: anUrlString [

	^ self new
		  name: aString;
		  url: anUrlString;
		  yourself
]

{ #category : 'instance creation' }
CooHistoryBenchmarkRepository class >> name: aString url: anUrlString loadBlock: aBlock [

	^ (self name: aString url: anUrlString)
		  loadBlock: aBlock;
		  yourself
]

{ #category : 'instance creation' }
CooHistoryBenchmarkRepository class >> name: aString url: anUrlString replayBlock: aBlock [

	^ (self name: aString url: anUrlString)
		  replayBlock: aBlock;
		  yourself
]

{ #category : 'testing' }
CooHistoryBenchmarkRepository >> hasCustomReplay [

	^ replayBlock isNotNil
]

{ #category : 'replay' }
CooHistoryBenchmarkRepository >> headShortId [

	^ lastHeadShortId
]

{ #category : 'preparation' }
CooHistoryBenchmarkRepository >> load [

	loadBlock ifNil: [ ^ self ].
	loadBlock value
]

{ #category : 'accessing' }
CooHistoryBenchmarkRepository >> loadBlock: aBlock [

	loadBlock := aBlock
]

{ #category : 'accessing' }
CooHistoryBenchmarkRepository >> name [

	^ name
]

{ #category : 'accessing' }
CooHistoryBenchmarkRepository >> name: aString [

	name := aString
]

{ #category : 'printing' }
CooHistoryBenchmarkRepository >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPutAll: '(';
		nextPutAll: name;
		nextPutAll: ' - ';
		nextPutAll: url;
		nextPutAll: ')'
]

{ #category : 'replay' }
CooHistoryBenchmarkRepository >> replayOntoSession: aSession window: anInteger diagnostic: aDiagnostic [

	self hasCustomReplay
		ifTrue: [
			replayBlock cull: aSession cull: anInteger.
			lastHeadShortId := 'custom-replay'.
			aDiagnostic increment: #commitsRequested by: anInteger.
			aDiagnostic increment: #commitsReplayed by: anInteger.
			^ self ].

	anInteger <= 0 ifTrue: [
		lastHeadShortId := nil.
		^ self ].

	self replayUsingPopulatorOntoSession: aSession window: anInteger diagnostic: aDiagnostic
]

{ #category : 'accessing' }
CooHistoryBenchmarkRepository >> replayBlock: aBlock [

	replayBlock := aBlock
]

{ #category : 'replay' }
CooHistoryBenchmarkRepository >> replayUsingPopulatorOntoSession: aSession window: anInteger diagnostic: aDiagnostic [

	| populator commits |
	populator := HistoryCachePopulator repo: url.
	populator session: aSession.
	commits := populator commitsForHead: anInteger.
	lastHeadShortId := commits
		ifEmpty: [ nil ]
		ifNotEmpty: [ :list | list first shortId ].
	aDiagnostic increment: #commitsRequested by: anInteger.
	aDiagnostic increment: #commitsReplayed by: commits size.
	"Commits arrive newest first; loading oldest first mimics the original
	development order so temporal handlers observe realistic sequences."
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkRepository >> url [

	^ url
]

{ #category : 'accessing' }
CooHistoryBenchmarkRepository >> url: aString [

	url := aString
]
