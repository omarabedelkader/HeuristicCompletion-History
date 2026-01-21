Class {
	#name : 'CooHistoryBenchmarksRunner',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> run [

	^ self runWithSession: CooSession current
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runBenchmarks [

	^ self runBenchmarksWithSession: CooSession current
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runBenchmarksWithSession: aSession [

	| messageBenchmark variableBenchmark |
	messageBenchmark := CooStaticBenchmarksMessageHistory new
		session: aSession;
		yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		session: aSession;
		yourself.

	Transcript show: 'Running history completion benchmarks...'; cr.
	messageBenchmark run.
	variableBenchmark run.
	Transcript show: 'History benchmarks complete.'; cr.

	^ { messageBenchmark . variableBenchmark }
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runWithSession: aSession [

	(aSession isNil or: [ aSession size = 0 ]) ifTrue: [
		Transcript
			show: 'History cache is empty. Populate caches before running benchmarks.';
			cr.
		^ self ].

	^ self runBenchmarksWithSession: aSession
]
