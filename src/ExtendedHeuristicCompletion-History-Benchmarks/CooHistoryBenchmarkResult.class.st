"
HOW TO AGGREGATE IT: metrics for one treatment cell, i.e. one
repository x historyWindow x configuration x targetKind combination.

Aggregates are always derived from raw CooHistoryBenchmarkQueryResult rows.

Conventions (tested in CooHistoryBenchmarkResultTest):
- rank nil counts as a miss for every metric.
- MRR@10 sums 1/rank over successful hits only.
- coverage is the fraction of queries where a candidate was generated at all,
  independently of its rank.
- medianRank is computed over successful hits only; it is nil when nothing
  was ever found.
- medianLatency and p95Latency are computed over all executed queries.
"
Class {
	#name : 'CooHistoryBenchmarkResult',
	#superclass : 'Object',
	#instVars : [
		'repositoryName',
		'historyWindow',
		'configurationName',
		'targetKind',
		'queryResults'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Results',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Results'
}

{ #category : 'instance creation' }
CooHistoryBenchmarkResult class >> aggregating: aCollectionOfQueryResults repositoryName: aRepositoryName historyWindow: anInteger configurationName: aSymbol targetKind: aTargetKind [

	^ self new
		  repositoryName: aRepositoryName;
		  historyWindow: anInteger;
		  configurationName: aSymbol;
		  targetKind: aTargetKind;
		  queryResults: aCollectionOfQueryResults;
		  yourself
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> coverage [

	self queryCount = 0 ifTrue: [ ^ 0.0 ].
	^ (queryResults select: [ :each | each candidateGenerated ]) size
	  / self queryCount asFloat
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> hitAt1 [

	^ self hitRateWithin: 1
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> hitAt10 [

	^ self hitRateWithin: 10
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> hitAt5 [

	^ self hitRateWithin: 5
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> hitRateWithin: anInteger [

	self queryCount = 0 ifTrue: [ ^ 0.0 ].
	^ (queryResults select: [ :each | each isSuccess and: [ each rank notNil and: [ each rank <= anInteger ] ] ])
		  size / self queryCount asFloat
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> configurationName [

	^ configurationName
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> configurationName: aSymbol [

	configurationName := aSymbol
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> historyWindow [

	^ historyWindow
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> historyWindow: anInteger [

	historyWindow := anInteger
]

{ #category : 'testing' }
CooHistoryBenchmarkResult >> isEmptyTreatment [

	^ queryResults isEmpty
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> mrrAt10 [

	| total reciprocalSum |
	total := queryResults size.
	total = 0 ifTrue: [ ^ 0.0 ].
	reciprocalSum := queryResults sum: [ :each |
			each isSuccess and: [ each rank notNil ]
				ifTrue: [ 1.0 / each rank ]
				ifFalse: [ 0.0 ] ].
	^ reciprocalSum / total asFloat
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> medianLatency [

	^ self medianOf: (queryResults collect: [ :each | each latencyMilliseconds ])
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> medianOf: aCollectionOfNumbers [

	| sorted size |
	size := aCollectionOfNumbers size.
	size = 0 ifTrue: [ ^ nil ].
	sorted := aCollectionOfNumbers asSortedCollection asArray.
	size odd ifTrue: [ ^ sorted at: size + 1 // 2 ].
	^ ((sorted at: size // 2) + (sorted at: size // 2 + 1)) / 2
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> medianRank [
	"Median rank among successful hits; nil when no candidate was ever found."

	| ranks |
	ranks := queryResults
		         select: [ :each | each isSuccess and: [ each rank notNil ] ]
		         thenCollect: [ :each | each rank ].
	^ self medianOf: ranks
]

{ #category : 'printing' }
CooHistoryBenchmarkResult >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		nextPutAll: repositoryName;
		nextPutAll: ' w=';
		print: historyWindow;
		nextPutAll: ' ';
		nextPutAll: configurationName asString;
		nextPutAll: ' ';
		print: targetKind;
		nextPutAll: ' n=';
		print: self queryCount;
		nextPutAll: ')'
]

{ #category : 'metrics' }
CooHistoryBenchmarkResult >> p95Latency [

	| latencies sorted index size |
	latencies := queryResults collect: [ :each | each latencyMilliseconds ].
	size := latencies size.
	size = 0 ifTrue: [ ^ nil ].
	sorted := latencies asSortedCollection asArray.
	index := (size * 0.95) ceiling max: 1.
	^ sorted at: index
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> queryCount [

	^ queryResults size
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> queryResults [

	^ queryResults
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> queryResults: aCollection [

	queryResults := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> repositoryName [

	^ repositoryName
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> repositoryName: aString [

	repositoryName := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> targetKind [

	^ targetKind
]

{ #category : 'accessing' }
CooHistoryBenchmarkResult >> targetKind: aSymbol [

	targetKind := aSymbol
]
