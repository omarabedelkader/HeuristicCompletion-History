"
Accounting object for everything the experiment did not measure silently:
commits requested vs replayed, parse failures, methods unresolved in the
image, skipped queries with reasons, and completion errors.

The benchmark must never lose half of its dataset without a trace: every
query that is not executed is recorded here with a reason.
"
Class {
	#name : 'CooHistoryBenchmarkDiagnostic',
	#superclass : 'Object',
	#instVars : [
		'counters',
		'skipReasons'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Model',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Model'
}

{ #category : 'accessing' }
CooHistoryBenchmarkDiagnostic >> counterAt: aSymbol [

	^ counters at: aSymbol ifAbsent: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkDiagnostic >> counters [

	^ counters associations asSortedCollection: [ :a :b | a key < b key ]
]

{ #category : 'increasing' }
CooHistoryBenchmarkDiagnostic >> increment: aSymbol [

	self increment: aSymbol by: 1
]

{ #category : 'increasing' }
CooHistoryBenchmarkDiagnostic >> increment: aSymbol by: anInteger [

	counters at: aSymbol put: (self counterAt: aSymbol) + anInteger
]

{ #category : 'initialization' }
CooHistoryBenchmarkDiagnostic >> initialize [

	super initialize.
	counters := Dictionary new.
	skipReasons := Dictionary new
]

{ #category : 'printing' }
CooHistoryBenchmarkDiagnostic >> printOn: aStream [

	super printOn: aStream.
	self counters do: [ :association |
		aStream
			cr;
			print: association key;
			nextPutAll: ': ';
			print: association value ].
	self skipReasons do: [ :association |
		aStream
			cr;
			nextPutAll: 'skipped (';
			print: association key;
			nextPutAll: '): ';
			print: association value ]
]

{ #category : 'skipping' }
CooHistoryBenchmarkDiagnostic >> recordSkipReason: aSymbol [
	"Records one skipped query together with its reason, e.g. #classNotLoaded."

	self increment: #queriesSkipped.
	skipReasons at: aSymbol put: (self skipCountFor: aSymbol) + 1
]

{ #category : 'skipping' }
CooHistoryBenchmarkDiagnostic >> skipCountFor: aSymbol [

	^ skipReasons at: aSymbol ifAbsent: [ 0 ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkDiagnostic >> skipReasons [

	^ skipReasons associations asSortedCollection: [ :a :b | a key < b key ]
]
