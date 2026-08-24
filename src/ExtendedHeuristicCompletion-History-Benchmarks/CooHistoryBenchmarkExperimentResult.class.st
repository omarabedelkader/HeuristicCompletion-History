"
The complete result of one experiment run.

It owns:
- queryResults: the raw observations (primary scientific artifact)
- aggregateResults: one CooHistoryBenchmarkResult per
  repository x window x configuration x target cell
- diagnostics: skipped queries, failures and counters
- metadata: environment and experiment description

CooHistoryBenchmarkRunner run answers an instance of me; the caller may then
inspect it or read its aggregates.
"
Class {
	#name : 'CooHistoryBenchmarkExperimentResult',
	#superclass : 'Object',
	#instVars : [
		'queryResults',
		'aggregateResults',
		'diagnostics',
		'metadata'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Results',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Results'
}

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> aggregateResults [

	^ aggregateResults ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> aggregateResults: aCollection [

	aggregateResults := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> diagnostics [

	^ diagnostics ifNil: [ diagnostics := CooHistoryBenchmarkDiagnostic new ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> diagnostics: aDiagnostic [

	diagnostics := aDiagnostic
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> metadata [

	^ metadata
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> metadata: aDictionary [

	metadata := aDictionary
]

{ #category : 'printing' }
CooHistoryBenchmarkExperimentResult >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		print: self queryResults size;
		nextPutAll: ' raw results, ';
		print: self aggregateResults size;
		nextPutAll: ' aggregates)'
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> queryResults [

	^ queryResults ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperimentResult >> queryResults: aCollection [

	queryResults := aCollection
]
