"
I orchestrate a complete project-level History experiment and write its report artifacts.

During the replay of a repository history I run, for every commit, message and variable
completion benchmarks over the modified and added methods of the current session, one per
configuration (see #benchmarksForSession:): Baseline, Semantic, History, Dependency,
HistoryAfterSelf, Hybrid, HybridHD (history after self, then dependencies) and HybridDH
(dependencies, then history). Every call site is logged by CooCallsiteLog for the external analysis.

The benchmarks of the first five configurations, together with the project statistics, end up in a
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
		'statistics',
		'projectPackageNames',
		'historySnapshot',
		'log'
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
CooHistoryExperimentRunner class >> runConfigurationNamed: aSelector outputDirectory: aDirectory [
	"Entry point for unattended runs (see scripts/run-history-benchmarks.sh).
	aSelector is one of the CooHistoryExperimentConfiguration class-side constructors, e.g. #microdown.
	Warnings (e.g. Monticello asking to override dirty packages) are resumed because no one can answer them headless."

	| configuration |
	configuration := CooHistoryExperimentConfiguration perform: aSelector asSymbol.
	configuration outputDirectory: aDirectory asFileReference.
	^ [ self run: configuration ]
		  on: Warning
		  do: [ :warning |
			  Transcript
				  cr;
				  show: 'Warning resumed: ';
				  show: warning messageText asString.
			  warning resume: true ]
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

{ #category : 'private' }
CooHistoryExperimentRunner >> checkout: aCommit [
	"Only the project packages loaded at the start are checked out, as long as the commit has them.
	IceCheckoutAlreadyLoadedPackages would instead stop loading for good a package that one commit lacks.

	Iceberg computes the patch against what it believes is loaded. When a project is loaded
	from a different version than the replayed history, the patch can remove a method that the
	image does not have, and the KeyNotFound aborts the whole checkout. The method is already
	absent, so that removal is skipped and the checkout goes on."

	| strategy |
	strategy := IceCheckoutSelectedPackages new
		            packages: (self projectPackageNamesIn: aCommit);
		            yourself.
	^ [ aCommit checkoutWithStrategy: strategy ]
		  on: KeyNotFound
		  do: [ :error |
			  (error signalerContext findContextSuchThat: [ :context |
				   context selector = #removeSelector:fromClass: ])
				  ifNil: [ error pass ]
				  ifNotNil: [ :removal |
					  Transcript
						  cr;
						  show: 'Skipped removal of a method absent from the image: ';
						  show: error key printString.
					  removal return: nil ] ]
]

{ #category : 'private' }
CooHistoryExperimentRunner >> checkoutInitialCommit: aCommit [
	"Answer whether aCommit could be checked out as the starting state of the replay."

	^ [
	  self checkout: aCommit.
	  true ]
		  on: Error
		  do: [ :error |
			  statistics recordFailedCommit.
			  Transcript
				  cr;
				  show: 'Error loading initial ' , aCommit printString;
				  show: ': ' , error messageText.
			  false ]
]

{ #category : 'private' }
CooHistoryExperimentRunner >> commitsContainingProjectPackages: commits [
	"commits are newest first. Going back in time, I stop before the first commit that has none
	of the project packages (the initial empty commit of a repository, or a commit from before the
	packages were renamed): checking it out would unload the whole project and the following
	commits would replay nothing."

	| index |
	index := commits findFirst: [ :commit | (self projectPackageNamesIn: commit) isEmpty ].
	^ index = 0
		  ifTrue: [ commits ]
		  ifFalse: [ commits first: index - 1 ]
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> completeBaselineMessageBuilder [
	"Same baseline as CooBenchRunnerMessage>>#completeBaseline: no semantics, only the global selector list."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> completeBaselineVariableBuilder [
	"Flat namespace: only the global variables, without local, workspace or instance scopes.
	CooBenchRunnerVariables>>#completeBaseline uses CoGlobalSorterResultSetBuilder, which no longer exists."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoGlobalVariablesHeuristic new;
			 build).
	^ builder
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
			 add: CooDependencyMessageHeuristic new;
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
			 add: (CoGlobalVariablesHeuristic new globalVariableFetcherClass: CooDependencyGlobalVariableFetcher);
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
CooHistoryExperimentRunner >> historyAfterSelfMessageBuilderWithSession: aHistory [
	"A variant of the History builder: the session history comes right after the self and super
	heuristics instead of first. These two heuristics only apply to sends to self and super, which they
	rank well; for every other send the history still comes first. Class-name completion is unchanged."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
		add: CoSelfMessageHeuristic new;
		add: CoSuperMessageHeuristic new;
		add: (CooSessionMessagesHeuristic new
			session: aHistory;
			yourself);
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
CooHistoryExperimentRunner >> historyMessageBuilderWithSession: aSession [

	"The session heuristic comes first. Placed after the semantic heuristics it can never
	change a rank: the selectors it knows are those defined during the session, and they are
	mostly sent to self or super, so the self/super heuristics already propose them earlier
	and the history entries are dropped as repetitions."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
		add: (CooSessionMessagesHeuristic new
			session: aSession;
			yourself);
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

{ #category : 'benchs' }
CooHistoryExperimentRunner >> hybridMessageBuilderWithSession: aHistory [
	"History first, as in the History builder, and the direct package dependencies before the
	global fallback, as in the Dependency builder."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
			 add: (CooSessionMessagesHeuristic new
					  session: aHistory;
					  yourself);
			 add: CoSelfMessageHeuristic new;
			 add: CoSuperMessageHeuristic new;
			 add: CoTypedReceiverMessageHeuristic new;
			 add: CoInitializeInferencedMessageHeuristic new;
			 add: CoLiteralMessageHeuristic new;
			 add: CoGlobalVariableMessageHeuristic new;
			 add: CoVariableWithTypeNameMessageHeuristic new;
			 add: CooDependencyMessageHeuristic new;
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> hybridVariableBuilderWithSession: aHistory [
	"The history classes, then the classes of the direct package dependencies, then all globals."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoLocalScopeVariablesHeuristic new;
			 add: CoWorkspaceVariablesHeuristic new;
			 add: CoInstanceAccessibleVariablesHeuristic new;
			 add: (CooSessionVariableHeuristic new
					  session: aHistory;
					  yourself);
			 add: (CoGlobalVariablesHeuristic new globalVariableFetcherClass:
					  CooDependencyGlobalVariableFetcher);
			 add: CoGlobalVariablesHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> hybridHDMessageBuilderWithSession: aHistory [
	"Hybrid H->D: HistoryAfterSelf plus the direct package dependencies. The history comes right after
	the self and super heuristics, the dependencies right before the global fallback."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder messagesHeuristic: (builder newHeuristicBuilder
			 add: CoSelfMessageHeuristic new;
			 add: CoSuperMessageHeuristic new;
			 add: (CooSessionMessagesHeuristic new
					  session: aHistory;
					  yourself);
			 add: CoTypedReceiverMessageHeuristic new;
			 add: CoInitializeInferencedMessageHeuristic new;
			 add: CoLiteralMessageHeuristic new;
			 add: CoGlobalVariableMessageHeuristic new;
			 add: CoVariableWithTypeNameMessageHeuristic new;
			 add: CooDependencyMessageHeuristic new;
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> hybridDHMessageBuilderWithSession: aHistory [
	"Hybrid D->H: the Dependency chain, then the history, then the global fallback. The history only
	adds the selectors that neither the semantic heuristics nor the dependencies propose."

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
			 add: CooDependencyMessageHeuristic new;
			 add: (CooSessionMessagesHeuristic new
					  session: aHistory;
					  yourself);
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchs' }
CooHistoryExperimentRunner >> hybridDHVariableBuilderWithSession: aHistory [
	"The classes of the direct package dependencies, then the history classes, then all globals."

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoLocalScopeVariablesHeuristic new;
			 add: CoWorkspaceVariablesHeuristic new;
			 add: CoInstanceAccessibleVariablesHeuristic new;
			 add: (CoGlobalVariablesHeuristic new globalVariableFetcherClass:
					  CooDependencyGlobalVariableFetcher);
			 add: (CooSessionVariableHeuristic new
					  session: aHistory;
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
CooHistoryExperimentRunner >> benchmark: aBenchmarkClass named: aName builder: aBuilder session: aSession [

	^ aBenchmarkClass new
		  name: aName;
		  session: aSession;
		  builder: aBuilder;
		  log: log;
		  yourself
]

{ #category : 'private' }
CooHistoryExperimentRunner >> benchmarksForSession: aSession [
	"Every strategy answers the same call sites. The history strategies read the snapshot, not the
	session: while a commit is benchmarked they only know the history of the previous commits."

	| benchmarks |
	benchmarks := OrderedDictionary new.
	{
		#Baseline -> { self completeBaselineMessageBuilder. self completeBaselineVariableBuilder }.
		#Semantic -> { self completeSemanticsMessageBuilder. self completeSemanticsVariableBuilder }.
		#History -> {
			(self historyMessageBuilderWithSession: historySnapshot).
			(self historyVariableBuilderWithSession: historySnapshot) }.
		#Dependency -> {
			self completeDirectDependencyMessageBuilder.
			self completeDirectDependencyVariableBuilder }.
		#HistoryAfterSelf -> {
			(self historyAfterSelfMessageBuilderWithSession: historySnapshot).
			(self historyVariableBuilderWithSession: historySnapshot) }.
		#Hybrid -> {
			(self hybridMessageBuilderWithSession: historySnapshot).
			(self hybridVariableBuilderWithSession: historySnapshot) }.
		#HybridHD -> {
			(self hybridHDMessageBuilderWithSession: historySnapshot).
			(self hybridVariableBuilderWithSession: historySnapshot) }.
		#HybridDH -> {
			(self hybridDHMessageBuilderWithSession: historySnapshot).
			(self hybridDHVariableBuilderWithSession: historySnapshot) } } do: [ :strategy |
		benchmarks
			at: #message -> strategy key
			put: (self
					 benchmark: CooStaticBenchmarksMessageHistory
					 named: strategy key
					 builder: strategy value first
					 session: aSession);
			at: #variable -> strategy key
			put: (self
					 benchmark: CooStaticBenchmarksVariableHistory
					 named: strategy key
					 builder: strategy value second
					 session: aSession) ].
	^ benchmarks
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadCommitsAndBench: aConfiguration session: aSession [
	"Answer the replayed commits and the benchmarks, keyed by kind -> strategy (e.g. #message -> #History)."

	| populator commits benchmarks |
	populator := HistoryPopulatorForBench repositoryNamed: aConfiguration repository.
	commits := populator commitsForHead: aConfiguration numberOfCommits.
	projectPackageNames := self loadedPackageNamesIn: commits first repository.
	commits := self commitsContainingProjectPackages: commits.
	Transcript
		cr;
		show: 'Replaying ' , commits size printString , ' commits on packages ';
		show: projectPackageNames printString.

	benchmarks := self benchmarksForSession: aSession.

	"The oldest commit is the initial state; it is not benchmarked since no previous commit gives
	development changes. Old commits may not load against today's dependencies. A half-loaded initial
	state would make the first replayed commit look huge, so the replay starts from the oldest commit that loads."
	[ commits size > 1 and: [ (self checkoutInitialCommit: commits last) not ] ]
		whileTrue: [ commits := commits allButLast ].

	aSession resetProgramEntities.
	self replayCommits: commits allButLast session: aSession benchmarks: benchmarks values.
	^ commits -> benchmarks
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadedPackageNamesIn: aRepository [
	"The project packages the configuration loaded, baselines excepted."

	^ (aRepository workingCopy packages
		   select: [ :package | package isLoaded ]
		   thenCollect: [ :package | package name ]) reject: [ :name |
		  name beginsWith: 'BaselineOf' ]
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadFromOldToNewCommit: commit [

	Transcript cr;cr; show: 'Loading and importing '; show: commit printString.	
	self checkout: commit
]

{ #category : 'private' }
CooHistoryExperimentRunner >> replayCommits: commits session: aSession benchmarks: benchmarks [
	"The commits are newest first and exclude the initial baseline checkout.
	The history is captured before a commit is loaded: its own changes join the history only for the
	following commits, after every strategy answered its call sites."

	commits reversed withIndexDo: [ :commit :index |
		| loadSuccess |
		historySnapshot updateFrom: aSession.
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
				log commit: commit index: index.
				benchmarks do: [ :benchmark | benchmark run ].
				statistics collectHistoryStatisticsFrom: aSession.
				statistics recordSuccessfulCommit ]
		] ensure: [
			"Clear per-commit events even after a partial checkout or benchmark error.
			The history handlers continue to accumulate across commits."
			aSession resetDevelopmentItems ] ]
]

{ #category : 'private' }
CooHistoryExperimentRunner >> projectPackageNamesIn: aCommit [

	| present |
	present := (aCommit packages collect: [ :package | package name ]) asSet.
	^ projectPackageNames select: [ :name | present includes: name ]
]

{ #category : 'running' }
CooHistoryExperimentRunner >> run: aConfiguration [

	| result commitsAndBench benchmarks |
	statistics := CooHistoryProjectStatistics new.
	aConfiguration outputDirectory ensureCreateDirectory.
	Transcript
		cr;
		show: 'Loading project for History experiment: ';
		show: aConfiguration name.
	aConfiguration loadProject.

	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.

	log := CooCallsiteLog new
		       openOn: aConfiguration outputDirectory asFileReference
		       project: (aConfiguration name asLowercase copyReplaceAll: ' ' with: '-').
	[
	historySnapshot := CooHistorySnapshot new.
	log history: historySnapshot.
	commitsAndBench := self analyzeHistoryAndBenchmarksFor: aConfiguration session: CooSession current ]
		ensure: [ log close ].
	benchmarks := commitsAndBench value.
	statistics
		recordBenchmarkPopulationFromMessageBenchmark: (benchmarks at: #message -> #Semantic)
		variableBenchmark: (benchmarks at: #variable -> #Semantic).

	result := CooHistoryExperimentResult new.
	result
		projectName: aConfiguration name;
		repository: aConfiguration repository;
		commitCount: statistics historyCommitCount;
		statistics: statistics;
		comparisonDescription:
			'Baseline vs Complete semantics vs + History vs + Direct Package Dependencies vs + History and Dependencies';
		messageBaselineBenchmark: (benchmarks at: #message -> #Baseline);
		messageSemanticBenchmark: (benchmarks at: #message -> #Semantic);
		messageHistoryBenchmark: (benchmarks at: #message -> #History);
		messageDependencyBenchmark: (benchmarks at: #message -> #Dependency);
		messageHybridBenchmark: (benchmarks at: #message -> #Hybrid);
		variableBaselineBenchmark: (benchmarks at: #variable -> #Baseline);
		variableSemanticBenchmark: (benchmarks at: #variable -> #Semantic);
		variableHistoryBenchmark: (benchmarks at: #variable -> #History);
		variableDependencyBenchmark: (benchmarks at: #variable -> #Dependency);
		variableHybridBenchmark: (benchmarks at: #variable -> #Hybrid).

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
