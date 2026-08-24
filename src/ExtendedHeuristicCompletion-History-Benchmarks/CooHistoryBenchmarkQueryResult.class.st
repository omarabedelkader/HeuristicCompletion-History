"
WHAT HAPPENED: the raw scientific observation of one completion query.

One instance is produced for every invocation of completion at one
callsite/prefix. Raw rows are the primary experimental artifact; aggregates
are derived from them, never the other way around.

Conventions:
- rank is nil when the expected candidate is not among the retrieved
  candidates; hitAtK answers false and MRR contributes nothing for that row.
- candidateGenerated is independent from rank: it tells whether history
  produced a candidate at all versus whether it moved an existing candidate
  upward.
"
Class {
	#name : 'CooHistoryBenchmarkQueryResult',
	#superclass : 'Object',
	#instVars : [
		'repositoryName',
		'sourceCommit',
		'historyWindow',
		'configurationName',
		'targetKind',
		'className',
		'methodSelector',
		'expectedCandidate',
		'prefix',
		'prefixSize',
		'candidateGenerated',
		'candidateCount',
		'rank',
		'hitAt1',
		'hitAt5',
		'hitAt10',
		'latencyMilliseconds',
		'memoryDelta',
		'methodHistorySize',
		'classHistorySize',
		'interactionHistorySize',
		'errorReason'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Results',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Results'
}

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> candidateCount [

	^ candidateCount
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> candidateCount: anInteger [

	candidateCount := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> candidateGenerated [

	^ candidateGenerated
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> candidateGenerated: aBoolean [

	candidateGenerated := aBoolean
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> classHistorySize [

	^ classHistorySize ifNil: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> classHistorySize: anInteger [

	classHistorySize := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> className [

	^ className
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> className: aString [

	className := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> configurationName [

	^ configurationName
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> configurationName: aSymbol [

	configurationName := aSymbol
]

{ #category : 'testing' }
CooHistoryBenchmarkQueryResult >> errored [

	^ errorReason notNil
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> errorReason [

	^ errorReason
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> errorReason: aSymbol [

	errorReason := aSymbol
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> expectedCandidate [

	^ expectedCandidate
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> expectedCandidate: aString [

	expectedCandidate := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> hitAt1 [

	^ hitAt1
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> hitAt10 [

	^ hitAt10
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> hitAt5 [

	^ hitAt5
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> historyWindow [

	^ historyWindow
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> historyWindow: anInteger [

	historyWindow := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> interactionHistorySize [

	^ interactionHistorySize ifNil: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> interactionHistorySize: anInteger [

	interactionHistorySize := anInteger
]

{ #category : 'testing' }
CooHistoryBenchmarkQueryResult >> isSuccess [

	^ self errored not
]

{ #category : 'testing' }
CooHistoryBenchmarkQueryResult >> isHitWithin: anInteger [

	^ rank notNil and: [ rank <= anInteger ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> latencyMilliseconds [

	^ latencyMilliseconds ifNil: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> latencyMilliseconds: anInteger [

	latencyMilliseconds := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> memoryDelta [

	^ memoryDelta ifNil: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> memoryDelta: anInteger [

	memoryDelta := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> methodHistorySize [

	^ methodHistorySize ifNil: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> methodHistorySize: anInteger [

	methodHistorySize := anInteger
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> methodSelector [

	^ methodSelector
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> methodSelector: aSymbol [

	methodSelector := aSymbol
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> prefix [

	^ prefix
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> prefix: aString [

	prefix := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> prefixSize [

	^ prefixSize
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> prefixSize: anInteger [

	prefixSize := anInteger
]

{ #category : 'printing' }
CooHistoryBenchmarkQueryResult >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: repositoryName asString;
		nextPutAll: ' w=';
		print: historyWindow;
		nextPutAll: ' ';
		nextPutAll: configurationName asString;
		nextPutAll: ' ';
		print: targetKind;
		nextPutAll: ' rank=';
		print: rank;
		nextPutAll: ')'
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> rank [

	^ rank
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> rank: anIntegerOrNil [
	"nil means the expected candidate was not generated within top K."

	rank := anIntegerOrNil.
	candidateGenerated := rank notNil.
	hitAt1 := self isHitWithin: 1.
	hitAt5 := self isHitWithin: 5.
	hitAt10 := self isHitWithin: 10
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> repositoryName [

	^ repositoryName
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> repositoryName: aString [

	repositoryName := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> sourceCommit [

	^ sourceCommit
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> sourceCommit: aString [

	sourceCommit := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> targetKind [

	^ targetKind
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryResult >> targetKind: aSymbol [

	targetKind := aSymbol
]
