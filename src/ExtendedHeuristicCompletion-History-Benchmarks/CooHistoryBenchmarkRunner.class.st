"
HOW TO ORCHESTRATE EVERYTHING: executes a CooHistoryBenchmarkExperiment
declaratively and answers one CooHistoryBenchmarkExperimentResult.

Public API:

  CooHistoryBenchmarkRunner run            complete predefined experiment
  CooHistoryBenchmarkRunner runFull        same as run
  CooHistoryBenchmarkRunner runQuick       small development experiment
  CooHistoryBenchmarkRunner dryRun         print the matrix without executing
  CooHistoryBenchmarkRunner
      runRepositoryNamed: 'Microdown'      one repository, all windows
      runRepositoryNamed: 'Microdown'
      commits: 10                          one repository, one window

Protocol per repository:
1. load the project version (loadBlock of the repository descriptor);
2. replay the largest window once and extract the canonical query set, so
   every configuration and window is evaluated on the SAME queries;
3. for each window: reset the state, replay that many commits;
4. for each configuration: rebuild handlers from the replayed items, build a
   dedicated completion builder, execute the canonical queries.

Every treatment starts from an equivalent fresh state (resetExperimentState)
and uses exactly one explicit session; nothing falls back to
CooSession current. run itself never calls inspect.
"
Class {
	#name : 'CooHistoryBenchmarkRunner',
	#superclass : 'Object',
	#instVars : [
		'experiment',
		'session',
		'diagnostics',
		'queryResults',
		'exportDirectory',
		'testedShas'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Runner',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Runner'
}

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> dryRun [

	^ self new
		  experiment: CooHistoryBenchmarkExperiment full;
		  dryRun
]

{ #category : 'instance creation' }
CooHistoryBenchmarkRunner class >> experiment: aCooHistoryBenchmarkExperiment [

	^ self new
		  experiment: aCooHistoryBenchmarkExperiment;
		  yourself
]

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> run [

	^ self runFull
]

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> runExperiment: anExperiment [

	^ (self experiment: anExperiment) run
]

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> runFull [

	^ self runExperiment: CooHistoryBenchmarkExperiment full
]

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> runQuick [

	^ self runExperiment: CooHistoryBenchmarkExperiment quick
]

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> runRepositoryNamed: aString [

	^ self runExperiment: (CooHistoryBenchmarkExperiment full
			   repositories: { self repositoryNamed: aString };
			   yourself)
]

{ #category : 'running' }
CooHistoryBenchmarkRunner class >> runRepositoryNamed: aString commits: anInteger [

	^ self runExperiment: ((CooHistoryBenchmarkExperiment full
			   repositories: { self repositoryNamed: aString })
			  commitWindows: { anInteger };
			  yourself)
]

{ #category : 'private - utilities' }
CooHistoryBenchmarkRunner class >> repositoryNamed: aString [

	| repository |
	repository := CooHistoryBenchmarkCatalog defaultRepositories detect: [
		              :each | each name = aString ] ifNone: [ nil ].
	repository ifNil: [
		Error signal:
			'Unknown repository: ' , aString printString
			, '. Known repositories: '
			, ((CooHistoryBenchmarkCatalog defaultRepositories collect: [ :each | each name ])
				 asArray printString) ].
	^ repository
]

{ #category : 'accessing' }
CooHistoryBenchmarkRunner >> exportDirectory: aFileReference [

	exportDirectory := aFileReference
]

{ #category : 'accessing' }
CooHistoryBenchmarkRunner >> experiment [

	^ experiment
]

{ #category : 'accessing' }
CooHistoryBenchmarkRunner >> experiment: aCooHistoryBenchmarkExperiment [

	experiment := aCooHistoryBenchmarkExperiment
]

{ #category : 'private - building' }
CooHistoryBenchmarkRunner >> newBuilderForConfiguration: aConfiguration [
	"Each treatment gets its own builder with explicitly configured heuristic
	chains; the global class-level configuration of the image is never relied
	upon."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (aConfiguration messagesHeuristicsFor: session).
	builder variablesHeuristic: (aConfiguration variablesHeuristicsFor: session).
	builder methodNodesHeuristic: (aConfiguration methodNodesHeuristicsFor: session).
	^ builder
]

{ #category : 'printing' }
CooHistoryBenchmarkRunner >> printBanner [

	Transcript
		cr;
		show: '=================================================='; cr;
		show: 'History Completion Benchmark'; cr;
		show: '=================================================='; cr
]

{ #category : 'printing' }
CooHistoryBenchmarkRunner >> printRepositoryHeader: aRepository [

	Transcript
		show: 'Repository: ';
		show: aRepository name;
		cr
]

{ #category : 'printing' }
CooHistoryBenchmarkRunner >> printSummaryOf: anExperimentResult [

	Transcript
		cr;
		show: '=================================================='; cr;
		show: 'Experiment complete'; cr;
		show: 'Repositories: '; print: experiment repositories size; cr;
		show: 'Treatments: '; print: experiment treatmentCombinationsCount; cr;
		show: 'Queries: '; print: anExperimentResult queryResults size; cr;
		show: 'Skipped queries: ';
			print: (diagnostics counterAt: #queriesSkipped); cr;
		show: 'Results exported to: ';
			show: self resultExportDirectory pathString; cr;
		show: '=================================================='; cr
]

{ #category : 'printing' }
CooHistoryBenchmarkRunner >> printTreatmentSummary: aCollectionOfQueryResults window: anInteger configurationName: aSymbol [

	experiment targets do: [ :target |
		| aggregate |
		aggregate := self aggregateFor: aCollectionOfQueryResults repositoryName: nil historyWindow: anInteger configurationName: aSymbol targetKind: target.
		aggregate ifNotNil: [
			Transcript
				show: '    ';
				show: target asString capitalized;
				show: ':    '.
			self printTreatmentSummaryLine: aggregate ] ]
]

{ #category : 'printing' }
CooHistoryBenchmarkRunner >> printTreatmentSummaryLine: anAggregate [

	Transcript
		print: anAggregate queryCount;
		show: ' queries | MRR@10 ';
		show: ((anAggregate mrrAt10 * 100) roundTo: 1) asString;
		show: '% | Hit@1 ';
		show: ((anAggregate hitAt1 * 100) roundTo: 1) asString;
		show: '%';
		cr
]

{ #category : 'private - aggregation' }
CooHistoryBenchmarkRunner >> aggregateFor: aCollectionOfQueryResults repositoryName: aRepositoryNameOrNil historyWindow: anInteger configurationName: aSymbol targetKind: aTargetKind [

	| selected |
	selected := aCollectionOfQueryResults select: [ :each |
		            each targetKind = aTargetKind and: [
			            each historyWindow = anInteger and: [
				            each configurationName = aSymbol ] ] ].
	selected ifEmpty: [ ^ nil ].
	^ CooHistoryBenchmarkResult
		  aggregating: selected
		  repositoryName: (aRepositoryNameOrNil ifNil: [ '' ])
		  historyWindow: anInteger
		  configurationName: aSymbol
		  targetKind: aTargetKind
]

{ #category : 'private - aggregation' }
CooHistoryBenchmarkRunner >> computeAggregateResults [

	| aggregates |
	aggregates := OrderedCollection new.
	experiment repositories do: [ :repository |
		experiment commitWindows do: [ :window |
			experiment configurations do: [ :configuration |
				experiment targets do: [ :target |
					| group |
					group := queryResults select: [ :each |
						         each repositoryName = repository name and: [
							         each historyWindow = window and: [
								         each configurationName = configuration name and: [
									         each targetKind = target ] ] ] ].
					group ifNotEmpty: [
						aggregates add: (CooHistoryBenchmarkResult
								 aggregating: group
								 repositoryName: repository name
								 historyWindow: window
								 configurationName: configuration name
								 targetKind: target) ] ] ] ] ].
	^ aggregates
]

{ #category : 'private - orchestration' }
CooHistoryBenchmarkRunner >> canonicalQueriesFor: aRepository [
	"Extracting once per repository guarantees all configurations and windows
	run on the same immutable query set (paired comparisons)."

	| extractor queries |
	self resetExperimentState.
	aRepository
		replayOntoSession: session
		window: experiment maxCommitWindow
		diagnostic: diagnostics.
	testedShas
		at: aRepository name
		put: aRepository headShortId.
	extractor := CooHistoryBenchmarkQueryExtractor new
		             session: session;
		             targets: experiment targets;
		             diagnostics: diagnostics;
		             sourceCommit: aRepository headShortId;
		             yourself.
	queries := extractor extract.
	diagnostics
		increment: #candidateQueriesDiscovered
		by: queries size.
	Transcript
		show: 'Queries prepared: ';
		print: queries size;
		cr.
	^ queries
]

{ #category : 'private - orchestration' }
CooHistoryBenchmarkRunner >> configureSessionFor: aConfiguration [
	"Treatment-specific session wiring. shiftHandlerTo: replays the stored
	history items into the handler class of this configuration, so every
	treatment observes the same events through its own strategy."

	aConfiguration programEntityHandlerClass ifNotNil: [ :handlerClass |
		session shiftHandlerTo: handlerClass new ].
	aConfiguration selectionHistoryEnabled
		ifFalse: [ session resetInteractionItems ].
	session userSelectionHandler:
		aConfiguration userSelectionHandlerClass new.
	aConfiguration navigationHistoryEnabled
		ifFalse: [ session resetNavigationItems ]
]

{ #category : 'running' }
CooHistoryBenchmarkRunner >> dryRun [
	"Prints the complete experiment matrix without executing anything."

	experiment validate.
	self printBanner.
	Transcript
		print: experiment repositories size;
		show: ' repositories';
		cr;
		print: experiment commitWindows size;
		show: ' history windows: ';
		show: experiment commitWindows asArray printString;
		cr;
		print: experiment configurations size;
		show: ' configurations: ';
		show: ((experiment configurations collect: [ :each | each name ]) asArray printString);
		cr;
		print: experiment targets size;
		show: ' targets';
		cr;
		show: 'Total treatment combinations: ';
		print: experiment treatmentCombinationsCount;
		cr
]

{ #category : 'accessing' }
CooHistoryBenchmarkRunner >> session [

	^ session
]

{ #category : 'private - export' }
CooHistoryBenchmarkRunner >> resultExportDirectory [

	^ exportDirectory
		  ifNil: [
			  FileLocator imageDirectory / CooHistoryBenchmarkExporter defaultDirectoryName ]
		  ifNotNil: [ exportDirectory ]
]

{ #category : 'running' }
CooHistoryBenchmarkRunner >> resetExperimentState [
	"Every treatment must behave as though it was started in a fresh
	equivalent state: no program entity history, no interaction history, no
	navigation history may leak from the previous treatment."

	session := CooSession new.
	session noUserSelectionHandling.
	session recorder: CooNullHistoryEventRecorder uniqueInstance.

	self assert: session methodDescriptions isEmpty description: 'Method history leaked across treatments'.
	self assert: session classDescriptions isEmpty description: 'Class history leaked across treatments'.
	self assert: session navigationItems isEmpty description: 'Navigation history leaked across treatments'.
	self assert: session interactionItemsSize isZero description: 'Interaction history leaked across treatments'.
	self assert: session ~~ CooSession current description: 'The experiment must not mutate CooSession current'
]

{ #category : 'running' }
CooHistoryBenchmarkRunner >> run [

	experiment validate.
	diagnostics := CooHistoryBenchmarkDiagnostic new.
	queryResults := OrderedCollection new.
	testedShas := Dictionary new.
	self printBanner.

	experiment repositories do: [ :repository |
		self runRepository: repository ].

	^ self finalizeWithResult: self buildExperimentResult
]

{ #category : 'private - orchestration' }
CooHistoryBenchmarkRunner >> runRepository: aRepository [

	| canonicalQueries |
	self printRepositoryHeader: aRepository.
	aRepository load.
	canonicalQueries := self canonicalQueriesFor: aRepository.

	experiment commitWindows do: [ :window |
		Transcript
			show: '[', window asString, ' commits]'; cr.
		self resetExperimentState.
		aRepository
			replayOntoSession: session
			window: window
			diagnostic: diagnostics.
		experiment configurations do: [ :configuration |
			self runTreatment: configuration
				  window: window
				  repository: aRepository
				  queries: canonicalQueries ] ].

	Transcript
		show: '--------------------------------------------------'; cr;
		show: 'Repository complete: ';
		show: aRepository name; cr;
		show: '--------------------------------------------------'; cr
]

{ #category : 'private - orchestration' }
CooHistoryBenchmarkRunner >> runTreatment: aConfiguration window: anInteger repository: aRepository queries: aCollectionOfQueries [

	| runner treatmentResults |
	Transcript
		show: '  ';
		show: aConfiguration name asString;
		cr.
	self configureSessionFor: aConfiguration.

	runner := CooHistoryBenchmarkQueryRunner new
		          session: session;
		          builder: (self newBuilderForConfiguration: aConfiguration);
		          topK: experiment topK;
		          prefixSizes: experiment prefixSizes;
		          repositoryName: aRepository name;
		          historyWindow: anInteger;
		          configurationName: aConfiguration name;
		          diagnostics: diagnostics;
		          yourself.
	treatmentResults := runner runAll: aCollectionOfQueries.
	queryResults addAll: treatmentResults.

	self printTreatmentSummary: treatmentResults
		 window: anInteger
		 configurationName: aConfiguration name
]

{ #category : 'private - finalization' }
CooHistoryBenchmarkRunner >> buildExperimentResult [

	^ CooHistoryBenchmarkExperimentResult new
		  queryResults: queryResults;
		  aggregateResults: self computeAggregateResults;
		  diagnostics: diagnostics;
		  metadata: self buildMetadata;
		  yourself
]

{ #category : 'private - finalization' }
CooHistoryBenchmarkRunner >> buildMetadata [

	^ {
		  ('pharoVersion' -> SystemVersion current type , '.' , SystemVersion current major asString , '.' , SystemVersion current minor asString).
		  ('vmVersion' -> Smalltalk vm version).
		  ('platform' -> Smalltalk os name , ' / ' , Smalltalk os version).
		  ('timestamp' -> DateAndTime now printString).
		  ('repositories' -> (experiment repositories collect: [ :repository |
				   Dictionary new
					   at: 'name' put: repository name;
					   at: 'url' put: repository url;
					   at: 'testedSha' put: (testedShas at: repository name ifAbsent: [ nil ]);
					   yourself ]) asArray).
		  ('configurations' -> ((experiment configurations collect: [ :each | each name ]) collect: [ :each | each asString ]) asArray).
		  ('commitWindows' -> experiment commitWindows asArray).
		  ('targets' -> ((experiment targets collect: [ :each | each asString ]) asArray)).
		  ('prefixSizes' -> experiment prefixSizes asArray).
		  ('topK' -> experiment topK) } asDictionary
]

{ #category : 'private - finalization' }
CooHistoryBenchmarkRunner >> finalizeWithResult: anExperimentResult [

	CooHistoryBenchmarkExporter new
		directory: self resultExportDirectory;
		export: anExperimentResult.
	self printSummaryOf: anExperimentResult.
	^ anExperimentResult
]
