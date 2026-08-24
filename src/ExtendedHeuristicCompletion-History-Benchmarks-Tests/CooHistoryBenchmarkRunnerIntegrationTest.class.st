"
Integration tests running the complete experiment infrastructure on the
deterministic image-local fixture: no Git, no Iceberg, no network.

They verify the experimental protocol itself: clean state between
treatments, paired query sets across configurations, exact result counts,
window semantics and end-to-end export.
"
Class {
	#name : 'CooHistoryBenchmarkRunnerIntegrationTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'fixture' }
CooHistoryBenchmarkRunnerIntegrationTest >> fixtureExperimentWindows: aCollection replayRecorder: aRecorderOrNil [

	^ CooHistoryBenchmarkExperiment full
		  repositories: { self fixtureRepositoryReplayRecorder: aRecorderOrNil };
		  configurations: {
				  CooHistoryBenchmarkConfiguration default.
				  CooHistoryBenchmarkConfiguration temporal };
		  commitWindows: aCollection;
		  prefixSizes: #( 2 3 );
		  yourself
]

{ #category : 'fixture' }
CooHistoryBenchmarkRunnerIntegrationTest >> fixtureRepositoryReplayRecorder: aRecorderOrNil [

	^ CooFixtureHistory repositoryWithReplayBlock: [ :session :window |
		  aRecorderOrNil ifNotNil: [ aRecorderOrNil add: window ].
		  window > 0 ifTrue: [ CooFixtureHistory populateSession: session ] ]
]

{ #category : 'fixture' }
CooHistoryBenchmarkRunnerIntegrationTest >> runFixtureExperiment: anExperiment [

	| directory |
	directory := FileLocator temp / ('coo-benchmark-runner-test-' , UUID new asString36).
	^ (CooHistoryBenchmarkRunner new
		   experiment: anExperiment;
		   exportDirectory: directory) run -> directory
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testAllConfigurationsReceiveSameQuerySet [
	"Treatments are comparable only if they execute identical queries."

	| pairing defaultDescriptors temporalDescriptors |
	pairing := self
		           runFixtureExperiment:
			           (self fixtureExperimentWindows: #( 1 ) replayRecorder: nil).

	defaultDescriptors := ((pairing key queryResults select: [ :each |
		                        each configurationName = #default ])
		                       collect: [ :each | self queryDescriptorOf: each ])
		                      asArray
		                      sorted: [ :a :b | a printString < b printString ].

	temporalDescriptors := ((pairing key queryResults select: [ :each |
		                         each configurationName = #temporal ])
		                        collect: [ :each | self queryDescriptorOf: each ])
		                       asArray
		                       sorted: [ :a :b | a printString < b printString ].

	self assert: defaultDescriptors equals: temporalDescriptors.
	pairing value ensureDeleteAll
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testEveryExecutedQueryProducesOneResult [
	"rows = queries x configurations x windows x prefixSizes"

	| pair expectedCount |
	pair := self
		        runFixtureExperiment:
			        (self fixtureExperimentWindows: #( 0 1 ) replayRecorder: nil).

	expectedCount := self fixtureQueryCount * 2 * 2 * 2.
	self assert: pair key queryResults size equals: expectedCount.
	pair value ensureDeleteAll
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testExperimentProducesAggregatesForEveryTreatmentCell [

	| pair |
	pair := self
		        runFixtureExperiment:
			        (self fixtureExperimentWindows: #( 0 1 ) replayRecorder: nil).

	self assert: pair key aggregateResults size equals: 2 * 2 * 2. "windows x configs x targets"
	self assert: pair key diagnostics isNotNil.
	self assert: pair key metadata isNotNil.
	pair value ensureDeleteAll
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testExportedFilesExistAfterRun [

	| pair directory |
	pair := self
		        runFixtureExperiment:
			        (self fixtureExperimentWindows: #( 1 ) replayRecorder: nil).
	directory := pair value.

	#( 'raw-results.csv' 'summary-results.csv' 'diagnostics.csv' 'experiment-metadata.json' )
		do: [ :fileName |
			self assert: (directory / fileName) exists description: fileName , ' must be exported automatically' ].
	directory ensureDeleteAll
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testFixtureQueriesAreDiscovered [

	| experiment runner session extractor queries |
	experiment := self fixtureExperimentWindows: #( 1 ) replayRecorder: nil.
	runner := CooHistoryBenchmarkRunner new
		          experiment: experiment;
		          resetExperimentState.
	session := runner session.

	CooFixtureHistory populateSession: session.
	queries := (CooHistoryBenchmarkQueryExtractor new
		            session: session;
		            targets: experiment targets;
		            yourself) extract.

	self assert: (queries select: [ :each | each targetKind = #selector ]) size >= 3.
	self assert: (queries select: [ :each | each targetKind = #className ]) size >= 1.
	self assert: (queries anySatisfy: [ :each | each expectedCandidate = #drawBox ])
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testHistoryWindowFiveReplaysAtMostFiveCommits [
	"The repository replay contract: custom replay blocks receive exactly the
	requested bound; the default populator replays at most that many commits.
	The bound is requested twice: once with the maximum window for the
	canonical query extraction, once per treatment."

	| recorder pair |
	recorder := OrderedCollection new.
	pair := self
		        runFixtureExperiment:
			        (self fixtureExperimentWindows: #( 5 ) replayRecorder: recorder).

	self assert: recorder asArray equals: #( 5 5 ).
	self deny: pair key queryResults isEmpty.
	pair value ensureDeleteAll
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testHistoryWindowZeroReplaysNoCommits [
	"Window 0 is the cold condition: nothing may be replayed, not even during
	the canonical extraction whose bound is also 0 here."

	| recorder pair |
	recorder := OrderedCollection new.
	pair := self
		        runFixtureExperiment:
			        (self fixtureExperimentWindows: #( 0 ) replayRecorder: recorder).

	self assert: recorder asArray equals: #( 0 0 ).
	self assert: (recorder allSatisfy: [ :window | window isZero ]).
	pair value ensureDeleteAll
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testResetClearsPreviousTreatmentState [

	| runner firstSession secondSession |
	runner := CooHistoryBenchmarkRunner new
		          experiment: (self fixtureExperimentWindows: #( 1 ) replayRecorder: nil);
		          yourself.

	runner resetExperimentState.
	firstSession := runner session.
	CooFixtureHistory populateSession: firstSession.
	self deny: firstSession methodDescriptions isEmpty.

	runner resetExperimentState.
	secondSession := runner session.

	self deny: secondSession identicalTo: firstSession.
	self assert: secondSession methodDescriptions isEmpty.
	self assert: secondSession classDescriptions isEmpty.
	self assert: secondSession navigationItems isEmpty.
	self assert: secondSession interactionItemsSize isZero
]

{ #category : 'tests' }
CooHistoryBenchmarkRunnerIntegrationTest >> testSelectorsAndVariableNamesRestoredAfterFullRun [
	"The whole experiment mutates AST copies; compiled methods must be untouched."

	| pair before after |
	before := (CooFixtureCanvas >> #refreshAll) sourceCode.
	pair := self
		        runFixtureExperiment:
			        (self fixtureExperimentWindows: #( 1 ) replayRecorder: nil).
	after := (CooFixtureCanvas >> #refreshAll) sourceCode.

	self assert: after equals: before.
	pair value ensureDeleteAll
]

{ #category : 'private - fixtures' }
CooHistoryBenchmarkRunnerIntegrationTest >> fixtureQueryCount [

	| runner session queries |
	runner := CooHistoryBenchmarkRunner new
		          experiment: (self fixtureExperimentWindows: #( 1 ) replayRecorder: nil);
		          yourself.
	runner resetExperimentState.
	session := runner session.
	CooFixtureHistory populateSession: session.
	queries := (CooHistoryBenchmarkQueryExtractor new
		            session: session;
		            targets: #( #selector #className );
		            yourself) extract.
	^ queries size
]

{ #category : 'private - utilities' }
CooHistoryBenchmarkRunnerIntegrationTest >> queryDescriptorOf: aResult [

	^ {
		  aResult targetKind.
		  aResult className.
		  aResult methodSelector.
		  aResult expectedCandidate.
		  aResult prefixSize }
]
