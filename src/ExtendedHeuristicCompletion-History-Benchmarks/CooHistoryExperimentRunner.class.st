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
CooHistoryExperimentRunner >> completeDirectDependencyVariableBuilder [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoLocalScopeVariablesHeuristic new;
			 add: CoWorkspaceVariablesHeuristic new;
			 add: CoInstanceAccessibleVariablesHeuristic new;
			 add: (CoGlobalVariablesHeuristic new globalVariableFetcherClass: CoDependencyGlobalVariableFetcher);
			 add: CoGlobalVariablesHeuristic new;
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

{ #category : 'benchs' }
CooHistoryExperimentRunner >> completeSemanticsVariableBuilder [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoLocalScopeVariablesHeuristic new;
			 add: CoWorkspaceVariablesHeuristic new;
			 add: CoInstanceAccessibleVariablesHeuristic new;
			 add: CoGlobalVariablesHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
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

{ #category : 'benchs' }
CooHistoryExperimentRunner >> historyVariableBuilderWithSession: aSession [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
		add: CoLocalScopeVariablesHeuristic new;
		add: CoWorkspaceVariablesHeuristic new;
		add: CoInstanceAccessibleVariablesHeuristic new;
		add: (CooSessionVariableHeuristic new
			session: aSession;
			yourself);
		add: CoGlobalVariablesHeuristic new;
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

	| populator commits messageHistoryBenchmark messageDependencyBenchmark messageSemanticBenchmark variableHistoryBenchmark variableDependencyBenchmark variableSemanticBenchmark |
	populator := HistoryPopulatorForBench repositoryNamed: aConfiguration repository.
	commits := populator commitsForHead: aConfiguration numberOfCommits.

	messageHistoryBenchmark := CooStaticBenchmarksMessageHistory new
		                    name: 'History';
		                    session: aSession;
		                    builder: (self historyMessageBuilderWithSession: aSession);
		                    yourself.

	messageDependencyBenchmark := CooStaticBenchmarksMessageHistory new
		                       name: 'Dependency';
		                       session: aSession;
		                       builder: self completeDirectDependencyMessageBuilder;
		                       yourself.


	messageSemanticBenchmark := CooStaticBenchmarksMessageHistory new
		                     name: 'Semantic';
		                     session: aSession;
		                     builder: self completeSemanticMessageBuilder;
		                     yourself.

	variableHistoryBenchmark := CooStaticBenchmarksVariableHistory new
		                            name: 'History';
		                            session: aSession;
		                            builder:
			                            (self historyVariableBuilderWithSession: aSession);
		                            yourself.

	variableDependencyBenchmark := CooStaticBenchmarksVariableHistory new
		                               name: 'Dependency';
		                               session: aSession;
		                               builder:
			                               self completeDirectDependencyVariableBuilder;
		                               yourself.

	variableSemanticBenchmark := CooStaticBenchmarksVariableHistory new
		                             name: 'Semantic';
		                             session: aSession;
		                             builder: self completeSemanticsVariableBuilder;
		                             yourself.
		
		
 	"Load the oldest commit as the initial state.
	We do not benchmark it because there is no previous commit
	from which to obtain meaningful development changes."
	commits last checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.

	aSession resetProgramEntities. "Replay commits from old to new.
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
			[ self loadFromOldToNewCommit: commit ]
				on: Error
				do: [
						loadSuccess := false.
						Transcript
							cr;
							show: 'Error loading ' , commit printString ].
			loadSuccess ifTrue: [ "aSession resetDevelopmentItems"
					messageSemanticBenchmark run.
					messageHistoryBenchmark run.
					messageDependencyBenchmark run.
					variableSemanticBenchmark run.
					variableHistoryBenchmark run.
					variableDependencyBenchmark run.
					
					statistics collectHistoryStatisticsFrom: aSession ] ].

	^ {
		  commits .
		  messageSemanticBenchmark.
		  messageHistoryBenchmark.
		  messageDependencyBenchmark.
		  variableSemanticBenchmark.
		  variableHistoryBenchmark.
		  variableDependencyBenchmark }
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
	Transcript
		cr;
		show: 'Loading project for History experiment: ';
		show: aConfiguration name.
	aConfiguration loadProject.

	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.

	commitsAndBench := self analyzeHistoryAndBenchmarksFor: aConfiguration session: CooSession current.

	result := CooHistoryExperimentResult new.
	result
		projectName: aConfiguration name;
		repository: aConfiguration repository;
		commitCount: statistics historyCommitCount;
		statistics: statistics;
		dependencyConfigurationName: 'self dependencyConfigurationName';
		comparisonDescription:
			'Complete semantics vs Complete semantics + History vs Complete semantics + Direct Package Dependencies';
		messageSemanticBenchmark: commitsAndBench second;
		messageHistoryBenchmark: commitsAndBench third;
		messageDependencyBenchmark: commitsAndBench fourth;
		variableSemanticBenchmark: commitsAndBench fifth;
		variableHistoryBenchmark: commitsAndBench sixth;
		variableDependencyBenchmark: commitsAndBench seventh.

	CooHistoryBenchmarkPlotter new exportAllFor: result to: aConfiguration outputDirectory.
	CooHistoryLatexExporter new exportAllFor: result to: aConfiguration outputDirectory.
	self saveSTON: result to: aConfiguration outputDirectory.

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
