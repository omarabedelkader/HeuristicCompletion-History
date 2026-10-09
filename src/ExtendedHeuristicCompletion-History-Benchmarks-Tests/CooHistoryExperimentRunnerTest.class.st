Class {
	#name : 'CooHistoryExperimentRunnerTest',
	#superclass : 'TestCase',
	#instVars : [ 'runner', 'session', 'benchmarkRuns' ],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'running' }
CooHistoryExperimentRunnerTest >> setUp [

	super setUp.
	session := CooSession new.
	benchmarkRuns := OrderedCollection new.
	runner := CooHistoryExperimentRunnerDouble new.
	runner benchmarkBlock: [
		benchmarkRuns add: (session methodDescriptions collect: #selector) asArray ]
]

{ #category : 'private' }
CooHistoryExperimentRunnerTest >> addMethod: aSelector [

	session addMethodItem: (CooAddedMethodHistoryItem new
		selector: aSelector;
		nameOfClass: 'ReplayFixture';
		yourself)
]

{ #category : 'private' }
CooHistoryExperimentRunnerTest >> replay: commits [

	runner replayCommits: commits session: session benchmarks: (Array new: 6 withAll: runner)
]

{ #category : 'tests' }
CooHistoryExperimentRunnerTest >> testFailedCheckoutIsSkippedAndEventsAreCleared [

	self replay: {
		[ self addMethod: #newest ].
		[ self addMethod: #partial. self error: 'Checkout failed' ].
		[ self addMethod: #oldest ] }.

	self assert: runner statistics historyCommitCount equals: 2.
	self assert: runner statistics successfulCommitCount equals: 2.
	self assert: runner statistics failedCommitCount equals: 1.
	self assert: runner statistics historyMethodCount equals: 2.
	self assert: benchmarkRuns asArray equals:
		((Array new: 6 withAll: #(oldest)), (Array new: 6 withAll: #(newest))).
	self assert: session methodDescriptions isEmpty.
	self assert: (runner statistics asDictionary at: #successfulCommitCount) equals: 2.
	self assert: (runner statistics asDictionary at: #failedCommitCount) equals: 1
]

{ #category : 'tests' }
CooHistoryExperimentRunnerTest >> testAllFailedCheckoutsReportZeroAnalyzedCommits [

	self replay: {
		[ self error: 'Checkout failed' ].
		[ self error: 'Checkout failed' ] }.

	self assert: runner statistics historyCommitCount equals: 0.
	self assert: runner statistics failedCommitCount equals: 2.
	self assert: benchmarkRuns isEmpty
]

{ #category : 'tests' }
CooHistoryExperimentRunnerTest >> testNoReplayCommitsReportsZeroAnalyzedCommits [

	self replay: #().

	self assert: runner statistics historyCommitCount equals: 0.
	self assert: runner statistics failedCommitCount equals: 0.
	self assert: benchmarkRuns isEmpty
]

{ #category : 'tests' }
CooHistoryExperimentRunnerTest >> testBenchmarkErrorDoesNotCountCommitAndStillClearsEvents [

	runner benchmarkBlock: [
		benchmarkRuns add: #run.
		benchmarkRuns size = 6 ifTrue: [ self error: 'Benchmark failed' ] ].
	self
		should: [ self replay: { [ self addMethod: #example ] } ]
		raise: Error.

	self assert: benchmarkRuns size equals: 6.
	self assert: runner statistics historyCommitCount equals: 0.
	self assert: runner statistics failedCommitCount equals: 0.
	self assert: session methodDescriptions isEmpty
]
