"
Session ownership tests: every experimental component must target the
explicit experiment session and never silently fall back to CooSession
current.
"
Class {
	#name : 'CooHistoryBenchmarkSessionOwnershipTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'tests' }
CooHistoryBenchmarkSessionOwnershipTest >> testMessageFetcherUsesExperimentSession [

	| experimentSession heuristic fetcher |
	experimentSession := CooSession new.
	heuristic := CooSessionMessagesHeuristic new
		             session: experimentSession;
		             yourself.

	fetcher := heuristic
		           buildFetcherFor: OCMessageNode new
		           inContext: nil.

	self assert: fetcher class identicalTo: CooMessageSessionFetcher.
	self assert: fetcher session identicalTo: experimentSession.
	self deny: fetcher session identicalTo: CooSession current
]

{ #category : 'tests' }
CooHistoryBenchmarkSessionOwnershipTest >> testPopulatorUsesExperimentSession [
	"Construction must not touch Git or Iceberg: only populateCaches does.
	The test injects an experiment session and verifies ownership."

	| populator experimentSession |
	populator := HistoryCachePopulator new.
	experimentSession := CooSession new.

	populator session: experimentSession.

	self assert: populator session identicalTo: experimentSession.
	self deny: populator session identicalTo: CooSession current
]

{ #category : 'tests' }
CooHistoryBenchmarkSessionOwnershipTest >> testRunnerCreatesSessionIndependentOfCurrent [
	"Even if CooSession current is the default production session, a fresh
	experiment state must be a distinct object."

	| runner |
	runner := CooHistoryBenchmarkRunner new.
	runner resetExperimentState.

	self deny: runner session identicalTo: CooSession current
]

{ #category : 'tests' }
CooHistoryBenchmarkSessionOwnershipTest >> testVariableFetcherUsesExperimentSession [

	| experimentSession heuristic fetcher |
	experimentSession := CooSession new.
	heuristic := CooSessionVariableHeuristic new
		             session: experimentSession;
		             yourself.

	fetcher := heuristic
		           buildFetcherFor: OCVariableNode new
		           inContext: nil.

	self assert: fetcher class identicalTo: CooVariableSessionFetcher.
	self assert: fetcher session identicalTo: experimentSession.
	self deny: fetcher session identicalTo: CooSession current
]
