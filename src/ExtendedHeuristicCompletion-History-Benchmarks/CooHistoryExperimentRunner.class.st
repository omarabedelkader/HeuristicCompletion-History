"
I orchestrate a complete project-level History experiment and write its report artifacts.

During the replay of a repository history I run, for every commit, six
benchmarks over the modified and added methods of the current session:
    - message completion:   semantic, history, direct-package-dependency
    - variable completion:  semantic, history, direct-package-dependency

The six benchmarks, together with the project statistics, end up in a
CooHistoryExperimentResult which is exported as:
    - comparison figures:   <project>-messages.{svg,png},
                            <project>-variables.{svg,png}
    - LaTeX tables:         <project>-{statistics,messages-mrr,variables-mrr}.tex
    - a STON summary:       <project>-results.ston

Use the class-side #run: script entries (or #runMicrodown, #runRoassal,
#runTestRepoForHistory) to start an experiment.
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

{ #category : 'running' }
CooHistoryExperimentRunner class >> runMooseCI [

	<script>
	^ self run: CooHistoryExperimentConfiguration mooseCI
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runDruid [

	<script>
	^ self run: CooHistoryExperimentConfiguration druid
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runFamix [

	<script>
	^ self run: CooHistoryExperimentConfiguration famix
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runFASTPython [

	<script>
	^ self run: CooHistoryExperimentConfiguration fastPython
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runFASTTypescript [

	<script>
	^ self run: CooHistoryExperimentConfiguration fastTypescript
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runFame [

	<script>
	^ self run: CooHistoryExperimentConfiguration fame
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runGitProjectHealth [

	<script>
	^ self run: CooHistoryExperimentConfiguration gitProjectHealth
]

{ #category : 'running' }
CooHistoryExperimentRunner class >> runTinyLogger [

	<script>
	^ self run: CooHistoryExperimentConfiguration tinyLogger
]

{ #category : 'private' }
CooHistoryExperimentRunner >> analyzeHistoryAndBenchmarksFor: aConfiguration session: aSession [

	| commitsAndBench  |
	statistics collectRepositoryStatisticsFrom: aConfiguration.

	commitsAndBench := self
		loadCommitsAndBench: aConfiguration
		session: aSession.
		
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
CooHistoryExperimentRunner >> completeSemanticsMessageBuilder [

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

	| populator commits messageHistoryBenchmark messageDependencyBenchmark messageSemanticBenchmark variableHistoryBenchmark variableDependencyBenchmark variableSemanticBenchmark semanticsVariableBenchmark dependencyVariableBenchmark historyVariableBenchmark |
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
		                     builder: self completeSemanticsMessageBuilder;
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
		
	semanticsVariableBenchmark := CooStaticBenchmarksVariableHistory new
		                     name: 'Semantic Variables';
		                     session: aSession;
		                     builder: self completeSemanticsVariableBuilder;
		                     yourself. 
		
	dependencyVariableBenchmark := CooStaticBenchmarksVariableHistory new
		                     name: 'Semantic Variables';
		                     session: aSession;
		                     builder: self completeSemanticsVariableBuilder ;
		                     yourself. 
	
	historyVariableBenchmark := CooStaticBenchmarksVariableHistory new
		                     name: 'Semantic Variables';
		                     session: aSession;
		                     builder: (self historyVariableBuilderWithSession: aSession) ;
		                     yourself. 
	
		
 	"Load the oldest commit as the initial state.
	We do not benchmark it because there is no previous commit
	from which to obtain meaningful development changes."
	commits last checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.

	aSession resetProgramEntities.
	self
		replayCommits: commits allButLast
		session: aSession
		benchmarks: {
			messageSemanticBenchmark.
			messageHistoryBenchmark.
			messageDependencyBenchmark.
			variableSemanticBenchmark.
			variableHistoryBenchmark.
			variableDependencyBenchmark }.

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

{ #category : 'private' }
CooHistoryExperimentRunner >> replayCommits: commits session: aSession benchmarks: benchmarks [
	"The commits are newest first and exclude the initial baseline checkout."

	commits reverseDo: [ :commit |
		| loadSuccess |
		loadSuccess := true.
		[ self loadFromOldToNewCommit: commit ]
			on: Error
			do: [ :error |
				loadSuccess := false.
				statistics recordFailedCommit.
				Transcript
					cr;
					show: 'Error loading ' , commit printString;
					show: ': ' , error messageText ].
		[
			loadSuccess ifTrue: [
				benchmarks do: [ :benchmark | benchmark run ].
				statistics collectHistoryStatisticsFrom: aSession.
				statistics recordSuccessfulCommit ]
		] ensure: [
			"Clear per-commit events even after a partial checkout or benchmark error.
			The history handlers continue to accumulate across commits."
			aSession resetDevelopmentItems ] ]
]

{ #category : 'running' }
CooHistoryExperimentRunner >> run: aConfiguration [

	| result commitsAndBench |
	statistics := CooHistoryProjectStatistics new.
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
