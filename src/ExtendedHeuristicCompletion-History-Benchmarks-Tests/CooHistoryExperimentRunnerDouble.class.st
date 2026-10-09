Class {
	#name : 'CooHistoryExperimentRunnerDouble',
	#superclass : 'CooHistoryExperimentRunner',
	#instVars : [ 'benchmarkBlock' ],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'accessing' }
CooHistoryExperimentRunnerDouble >> benchmarkBlock: aBlock [

	benchmarkBlock := aBlock
]

{ #category : 'private' }
CooHistoryExperimentRunnerDouble >> loadFromOldToNewCommit: aBlock [

	aBlock value
]

{ #category : 'running' }
CooHistoryExperimentRunnerDouble >> run [

	benchmarkBlock value
]

{ #category : 'accessing' }
CooHistoryExperimentRunnerDouble >> statistics [

	^ statistics
]
