"
HOW TO EXECUTE IT: runs completion for benchmark queries against one builder
and one session, producing exactly one CooHistoryBenchmarkQueryResult per
query and prefix size.

The AST node of a query is temporarily mutated to simulate typing a prefix.
Restoration is mandatory and protected with ensure:, so an exception raised
during completion can never corrupt the node used by the following queries.
A completion error is captured, counted in diagnostics (#completionFailure)
and recorded as a failed raw row instead of aborting the experiment.
"
Class {
	#name : 'CooHistoryBenchmarkQueryRunner',
	#superclass : 'Object',
	#instVars : [
		'session',
		'builder',
		'topK',
		'prefixSizes',
		'repositoryName',
		'historyWindow',
		'configurationName',
		'diagnostics'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Execution',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Execution'
}

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> builder [

	^ builder
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> builder: aCompletionBuilder [

	builder := aCompletionBuilder
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> configurationName [

	^ configurationName
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> configurationName: aSymbol [

	configurationName := aSymbol
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> diagnostics [

	^ diagnostics ifNil: [ diagnostics := CooHistoryBenchmarkDiagnostic new ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> diagnostics: aDiagnostic [

	diagnostics := aDiagnostic
]

{ #category : 'execution' }
CooHistoryBenchmarkQueryRunner >> executeQuery: aQuery prefixSize: anInteger [

	| candidate prefix |
	candidate := aQuery expectedCandidate asString.
	anInteger > candidate size ifTrue: [ ^ nil ].
	prefix := candidate copyFrom: 1 to: anInteger.

	^ self
		  measureAndRunQuery: aQuery
		  prefix: prefix
		  prefixSize: anInteger
]

{ #category : 'execution' }
CooHistoryBenchmarkQueryRunner >> historyWindow [

	^ historyWindow
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> historyWindow: anInteger [

	historyWindow := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> prefixSizes [

	^ prefixSizes ifNil: [ #( 2 3 4 5 6 7 8 ) ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> prefixSizes: aCollection [

	prefixSizes := aCollection
]

{ #category : 'printing' }
CooHistoryBenchmarkQueryRunner >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: repositoryName asString;
		nextPutAll: ' w=';
		print: historyWindow;
		nextPutAll: ' ';
		nextPutAll: configurationName asString;
		nextPutAll: ')'
]

{ #category : 'execution' }
CooHistoryBenchmarkQueryRunner >> runAll: aCollectionOfQueries [

	| results |
	results := OrderedCollection new.
	aCollectionOfQueries do: [ :query |
		self prefixSizes do: [ :prefixSize |
			self executeQuery: query prefixSize: prefixSize ifProduced: [ :result |
				results add: result ] ] ].
	^ results
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> repositoryName [

	^ repositoryName
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> repositoryName: aString [

	repositoryName := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> session [

	^ session
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> session: aSession [

	session := aSession
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> topK [

	^ topK ifNil: [ 10 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryRunner >> topK: anInteger [

	topK := anInteger
]

{ #category : 'private - execution' }
CooHistoryBenchmarkQueryRunner >> applyPrefix: aPrefix toQuery: aQuery during: aBlock [
	"The AST node is mutated to simulate typing; restoration happens even on
	exception so one query can never corrupt the AST used by the next ones."

	| node original |
	node := aQuery astNode.
	original := aQuery expectedCandidate.
	aQuery isSelectorTarget
		ifTrue: [ node selectorNode value: aPrefix ]
		ifFalse: [ node name: aPrefix ].
	^ aBlock ensure: [
		  aQuery isSelectorTarget
			  ifTrue: [ node selectorNode value: original ]
			  ifFalse: [ node name: original ] ]
]

{ #category : 'private - execution' }
CooHistoryBenchmarkQueryRunner >> completionClassFor: aQuery [

	^ session class environment at: aQuery className asSymbol ifAbsent: [ nil ]
]

{ #category : 'private - execution' }
CooHistoryBenchmarkQueryRunner >> executeQuery: aQuery prefixSize: anInteger ifProduced: aBlock [

	| result |
	result := self executeQuery: aQuery prefixSize: anInteger.
	result ifNotNil: [ aBlock value: result ]
]

{ #category : 'private - execution' }
CooHistoryBenchmarkQueryRunner >> measureAndRunQuery: aQuery prefix: aPrefix prefixSize: anInteger [

	| startTicks startMemory latency memoryDelta candidates contents rank errorReason |
	startTicks := Time millisecondClockValue.
	startMemory := Smalltalk vm memorySize.
	candidates := #(  ).
	errorReason := nil.

	self
		applyPrefix: aPrefix
		toQuery: aQuery
		during: [
			[
				| completion |
				completion := builder
					              node: aQuery astNode;
					              completionContext:
						              (self newCompletionContextFor: aQuery prefix: aPrefix);
					              buildCompletion.
				completion replaceFilterWith:
					(CoCaseSensitiveBeginsWithFilter filterString: aPrefix).
				candidates := completion first: self topK ]
				on: Error
				do: [ :ex |
					errorReason := #completionFailure.
					self diagnostics increment: #completionErrors ] ].

	latency := (Time millisecondClockValue - startTicks) max: 0.
	memoryDelta := Smalltalk vm memorySize - startMemory.
	rank := nil.
	errorReason ifNil: [
		contents := candidates collect: [ :each | each contents ].
		rank := contents indexOf: aQuery expectedCandidate.
		rank = 0 ifTrue: [ rank := nil ] ].

	^ self
		  resultFor: aQuery
		  prefix: aPrefix
		  prefixSize: anInteger
		  candidateCount: candidates size
		  rank: rank
		  latency: latency
		  memoryDelta: memoryDelta
		  errorReason: errorReason
]

{ #category : 'private - instance creation' }
CooHistoryBenchmarkQueryRunner >> newCompletionContextFor: aQuery prefix: aPrefix [

	^ CooBenchmarkCompletionContext
		  forCallsite: aQuery astNode
		  position: aQuery position
		  token: aPrefix
		  inClass: (self completionClassFor: aQuery)
]

{ #category : 'private - instance creation' }
CooHistoryBenchmarkQueryRunner >> resultFor: aQuery prefix: aPrefix prefixSize: anInteger candidateCount: anInteger rank: rankOrNil latency: aLatency memoryDelta: aMemoryDelta errorReason: anErrorSymbolOrNil [

	diagnostics increment: #queriesExecuted.
	^ CooHistoryBenchmarkQueryResult new
		  repositoryName: repositoryName;
		  sourceCommit: aQuery sourceCommit;
		  historyWindow: historyWindow;
		  configurationName: configurationName;
		  targetKind: aQuery targetKind;
		  className: aQuery className;
		  methodSelector: aQuery methodSelector;
		  expectedCandidate: aQuery expectedCandidate;
		  prefix: aPrefix;
		  prefixSize: anInteger;
		  candidateCount: anInteger;
		  rank: rankOrNil;
		  latencyMilliseconds: aLatency;
		  memoryDelta: aMemoryDelta;
		  methodHistorySize: session methodDescriptions size;
		  classHistorySize: session classDescriptions size;
		  interactionHistorySize: session interactionItemsSize;
		  errorReason: anErrorSymbolOrNil;
		  yourself
]
