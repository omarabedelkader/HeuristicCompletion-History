"
I orchestrate a complete project-level History experiment and write its report artifacts.
"
Class {
	#name : 'CooHistoryExperimentRunner',
	#superclass : 'Object',
	#instVars : [
		'statistics'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'running' }
CooHistoryExperimentRunner class >> run: aConfiguration [

	^ self new run: aConfiguration
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runMicrodown [

	<script>
	^ self run: CooHistoryExperimentConfiguration microdown
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runRoassal [

	<script>
	^ self run: CooHistoryExperimentConfiguration roassal
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runTestRepoForHistory [

	<script>
	^ self run: CooHistoryExperimentConfiguration testRepoForHistory
]

{ #category : 'private' }
CooHistoryExperimentRunner >> analyzeHistoryAndBenchmarksFor: aConfiguration session: aSession [

	| commitsAndBench  |
	statistics collectRepositoryStatisticsFrom: aConfiguration.

	commitsAndBench := self
		loadCommitsAndBench: aConfiguration
		session: aSession.
		
	statistics historyCommitCount: commitsAndBench first size.
	^ commitsAndBench
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> completeDirectDependencyMessageBuilder [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
			 add: CoSelfMessageHeuristic new;
			 add: CoSuperMessageHeuristic new;
			 add: CoTypedReceiverMessageHeuristic new;
			 add: CoInitializeInferencedMessageHeuristic new;
			 add: CoLiteralMessageHeuristic new;
			 add: CoGlobalVariableMessageHeuristic new;
			 add: CoVariableWithTypeNameMessageHeuristic new;
			 add: CoDependencyMessageHeuristics new;
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> completeSemanticMessageBuilder [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
			 add: CoSelfMessageHeuristic new;
			 add: CoSuperMessageHeuristic new;
			 add: CoTypedReceiverMessageHeuristic new;
			 add: CoInitializeInferencedMessageHeuristic new;
			 add: CoLiteralMessageHeuristic new;
			 add: CoGlobalVariableMessageHeuristic new;
			 add: CoVariableWithTypeNameMessageHeuristic new;
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'private' }
CooHistoryExperimentRunner >> historyMessageBuilderWithSession: aSession [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
		add: CoSelfMessageHeuristic new;
		add: CoSuperMessageHeuristic new;
		add: CoTypedReceiverMessageHeuristic new;
		add: CoInitializeInferencedMessageHeuristic new;
		add: CoLiteralMessageHeuristic new;
		add: CoGlobalVariableMessageHeuristic new;
		add: CoVariableWithTypeNameMessageHeuristic new;
		add: (CooSessionMessagesHeuristic new
			session: aSession;
			yourself);
		add: CoUnknownMessageHeuristic new;
		build).
	^ builder
]

{ #category : 'running' }
CooHistoryExperimentRunner >> initialize [

	super initialize.
	statistics := CooHistoryProjectStatistics new.
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadCommitsAndBench: aConfiguration session: aSession [ 

	| populator commits historyBenchmark dependencyBenchmark |
	populator := HistoryPopulatorForBench
		repositoryNamed: aConfiguration repository.
	commits := populator commitsForHead: aConfiguration numberOfCommits.

	historyBenchmark := CooStaticBenchmarksMessageHistory new
		name: 'History';
		session: aSession;
		builder: (self historyMessageBuilderWithSession: aSession);
		yourself.

	dependencyBenchmark := CooStaticBenchmarksMessageHistory new
		name: 'Dependency';
		session: aSession;
		builder: self completeDirectDependencyMessageBuilder;
		yourself.

	"Load the oldest commit as the initial state.
	We do not benchmark it because there is no previous commit
	from which to obtain meaningful development changes."
	commits last
		checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.

	aSession resetProgramEntities.

	"Replay commits from old to new.
	For EACH commit:
	  1. install it
	  2. extract its changes
	  3. benchmark History
	  4. benchmark Dependency
	  5. collect statistics
	  6. clear development items"
	commits allButLast reverseDo: [ :commit |
		| loadSuccess |
		loadSuccess := true. 
		[ 
		self loadFromOldToNewCommit: commit.
		] 
			on: Error 
			do: [ loadSuccess := false. 
				Transcript cr; show: 'Error loading ', commit printString ].
		loadSuccess ifTrue: [ 	
			historyBenchmark run.
			dependencyBenchmark run.
			statistics collectHistoryStatisticsFrom: aSession.
			].	
		"aSession resetDevelopmentItems" 	
	].

	^ {
		commits.
		historyBenchmark.
		dependencyBenchmark
	}
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadFromOldToNewCommit: commit [

	Transcript cr;cr; show: 'Loading and importing '; show: commit printString.	
	commit checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.			
		
]

{ #category : 'running' }
CooHistoryExperimentRunner >> run: aConfiguration [

	| result commitsAndBench |
	aConfiguration outputDirectory ensureCreateDirectory.
	Transcript cr; show: 'Loading project for History experiment: '; show: aConfiguration name.
	aConfiguration loadProject.

	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.

	commitsAndBench := self
		   analyzeHistoryAndBenchmarksFor: aConfiguration
			session: CooSession current.

	result := CooHistoryExperimentResult new.
	result
		projectName: aConfiguration name;
		repository: aConfiguration repository;
		commitCount: statistics historyCommitCount;
		statistics: statistics;
		dependencyConfigurationName: 'self dependencyConfigurationName';
		comparisonDescription:
			'Complete semantics + History vs Complete semantics + Direct Package Dependencies';
		messageHistoryBenchmark: commitsAndBench second;
		messageDependencyBenchmark: commitsAndBench third
		"messageDependencyBenchmark: messageDependency;
		variableHistoryBenchmark: variableHistory;
		variableDependencyBenchmark: variableDependency".

	CooHistoryBenchmarkPlotter new
		exportAllFor: result
		to: aConfiguration outputDirectory.
	CooHistoryLatexExporter new
		exportAllFor: result
		to: aConfiguration outputDirectory.
	self
		saveSTON: result
		to: aConfiguration outputDirectory.

	^ result
]

{ #category : 'private' }
CooHistoryExperimentRunner >> saveSTON: anExperimentResult to: aDirectory [

	| file |
	file := aDirectory asFileReference
	        / (anExperimentResult filename , '-results.ston').
	file parent ensureCreateDirectory.
	file writeStreamDo: [ :stream |
		stream nextPutAll:
			(STON toString: anExperimentResult asSTONDictionary) ].
	^ file
]
