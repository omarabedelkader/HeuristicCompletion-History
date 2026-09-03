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
CooHistoryExperimentRunner class >> runTestRepoForHistory [

	<script>
	^ self run: CooHistoryExperimentConfiguration testRepoForHistory
]

{ #category : 'private' }
CooHistoryExperimentRunner >> analyzeHistoryAndBenchmarksFor: aConfiguration session: aSession [

	| commits  |
	statistics collectRepositoryStatisticsFrom: aConfiguration.

	commits := self
		loadCommitsAndBench: aConfiguration
		session: aSession.
		
	statistics historyCommitCount: commits first size.
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

{ #category : 'running' }
CooHistoryExperimentRunner >> initialize [

	super initialize.
	statistics := CooHistoryProjectStatistics new.
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadCommitsAndBench: aConfiguration session: aSession [

	| populator commits benchmark |
	populator := HistoryPopulatorForBench repositoryNamed: aConfiguration repository.
	commits := populator commitsForHead: aConfiguration numberOfCommits.

	benchmark := CooStaticBenchmarksMessageHistory new.
	benchmark
		name: 'Dependency';
		session: aSession;
		builder: self completeDirectDependencyMessageBuilder.

	"We load the last of all commits without extraction information to avoid to have diff from most recent to old."
	
	commits last checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.
	"note that the handler internal structures are reset but not the kind of handler."
	aSession resetProgramEntities.
	
	"Then now we can reload from old-1 to recent"
	commits allButLast reverseDo: [ :commit |
		self loadFromOldToNewCommit: commit.
		"We ignore the oldest one because we loaded the code and then we go in the past.
		so the system computes the diff while loading old code and generate noise in the session"
		benchmark run.
		statistics collectHistoryStatisticsFrom: aSession. 
		"Flush items but not the handlers to make sure the next loading 
		will only contain new elements but without clearing the handler previously computer logic"
		aSession resetDevelopmentItems ].

	^ { commits . benchmark }
]

{ #category : 'private' }
CooHistoryExperimentRunner >> loadFromOldToNewCommit: commit [

	Transcript cr;cr; show: 'Loading and importing '; show: commit printString.	
	commit checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.			
		
]

{ #category : 'running' }
CooHistoryExperimentRunner >> run: aConfiguration [

	| result |
	aConfiguration outputDirectory ensureCreateDirectory.
	Transcript cr; show: 'Loading project for History experiment: '; show: aConfiguration name.
	aConfiguration loadProject.

	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.

	result := self
		   analyzeHistoryAndBenchmarksFor: aConfiguration
			session: CooSession current.

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
	        / (anExperimentResult fileStem , '-results.ston').
	file parent ensureCreateDirectory.
	file writeStreamDo: [ :stream |
		stream nextPutAll:
			(STON toString: anExperimentResult asSTONDictionary) ].
	^ file
]
