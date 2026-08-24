"
Metric computation tests on synthetic raw rows. These pin the exact
conventions used by the exported summary: rank nil is a miss, coverage is
independent from ranking, and percentiles follow standard definitions.
"
Class {
	#name : 'CooHistoryBenchmarkResultTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'fixture' }
CooHistoryBenchmarkResultTest >> resultWithRank: anIntegerOrNil latency: aNumber [

	^ CooHistoryBenchmarkQueryResult new
		  repositoryName: 'Fixture';
		  historyWindow: 1;
		  configurationName: #temporal;
		  targetKind: #selector;
		  rank: anIntegerOrNil;
		  latencyMilliseconds: aNumber;
		  yourself
]

{ #category : 'fixture' }
CooHistoryBenchmarkResultTest >> resultWithRanks: rankCollection [

	^ self aggregateOf: (rankCollection collect: [ :each |
			   self resultWithRank: each latency: 10 ])
]

{ #category : 'fixture' }
CooHistoryBenchmarkResultTest >> aggregateOf: aCollection [

	^ CooHistoryBenchmarkResult
		  aggregating: aCollection
		  repositoryName: 'Fixture'
		  historyWindow: 1
		  configurationName: #temporal
		  targetKind: #selector
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testCoverageCalculation [
	"Coverage counts generated candidates regardless of their rank."

	self assert: (self resultWithRanks: #( 1 3 nil )) coverage equals: 2 / 3.
	self assert: (self resultWithRanks: #( nil nil )) coverage equals: 0.0
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testHitAt10Calculation [

	self assert: (self resultWithRanks: #( 1 5 11 nil )) hitAt10 equals: 2 / 4
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testHitAt1Calculation [

	self assert: (self resultWithRanks: #( 1 2 nil )) hitAt1 equals: 1 / 3.
	self assert: (self resultWithRanks: #( 2 nil )) hitAt1 equals: 0.0
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testHitAt5Calculation [

	self assert: (self resultWithRanks: #( 1 5 6 nil )) hitAt5 equals: 2 / 4
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testMedianLatencyCalculation [

	| aggregate evenAggregate |
	aggregate := self aggregateOf:
		             (#( 30 10 20 ) collect: [ :each |
			             self resultWithRank: 1 latency: each ]).
	self assert: aggregate medianLatency equals: 20.

	evenAggregate := self aggregateOf:
		                 (#( 40 10 30 20 ) collect: [ :each |
			                 self resultWithRank: 1 latency: each ]).
	self assert: evenAggregate medianLatency equals: 25
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testMRRAt10Calculation [
	"MRR sums reciprocal ranks of hits only; misses contribute zero."

	self assert: ((self resultWithRanks: #( 1 3 nil )) mrrAt10 closeTo: (1 + (1 / 3)) / 3).
	self assert: (self resultWithRanks: #( nil nil )) mrrAt10 equals: 0.0
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testMedianRankConsidersHitsOnly [

	| aggregate |
	aggregate := self resultWithRanks: #( 1 3 nil ).
	self assert: aggregate medianRank equals: 2.
	self assert: (self resultWithRanks: #( nil )) medianRank isNil
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testP95LatencyCalculation [

	| latencies aggregate |
	latencies := 1 to: 100.
	aggregate := self aggregateOf:
		             (latencies collect: [ :each |
			             self resultWithRank: 1 latency: each ]).
	self assert: aggregate p95Latency equals: (100 * 0.95) ceiling
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testQueryCount [

	self assert: (self resultWithRanks: #( 1 3 nil )) queryCount equals: 3.
	self assert: (self aggregateOf: #(  )) queryCount equals: 0
]

{ #category : 'tests' }
CooHistoryBenchmarkResultTest >> testRankNilConventionMeansMiss [

	| result |
	result := self resultWithRank: nil latency: 5.

	self deny: result candidateGenerated.
	self assert: result rank isNil.
	self deny: result hitAt1.
	self deny: result hitAt5.
	self deny: result hitAt10
]
