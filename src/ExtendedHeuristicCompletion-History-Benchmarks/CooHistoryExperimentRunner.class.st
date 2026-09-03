"
I orchestrate a complete project-level History experiment and write its report artifacts.
"
Class {
	#name : 'CooHistoryExperimentRunner',
	#superclass : 'Object',
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

	| statistics commits  |
	statistics := CooHistoryProjectStatistics new.
	statistics collectRepositoryStatisticsFrom: aConfiguration.

	commits := self
		           populateHistoryFor: aConfiguration
		           session: aSession.

	statistics historyCommitCount: commits size.
	statistics collectHistoryStatisticsFrom: aSession.


"	comparison := CooHistoryBenchmarkComparison new.
	^ comparison
		  runForConfiguration: aConfiguration
		  session: aSession
		  commitCount: commits size
		  statistics: statistics"
]

{ #category : 'builders' }
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

{ #category : 'private' }
CooHistoryExperimentRunner >> loadProjectFrom: aConfiguration [

	Transcript
		cr;
		show: 'Loading project for History experiment: ';
		show: aConfiguration name.
	^ aConfiguration loadProject
]

{ #category : 'private' }
CooHistoryExperimentRunner >> populateHistoryFor: aConfiguration session: aSession [

	| populator commits benchmark |
	populator := HistoryCachePopulator repo: aConfiguration repository.
	populator session: aSession.
	commits := populator commitsForHead: aConfiguration numberOfCommits.


	benchmark := CooStaticBenchmarksMessageHistory new.
	benchmark
		name: 'Dependency';
		session: aSession;
		builder: self completeDirectDependencyMessageBuilder.

	
	"We load the last of all commits without extraction information to avoid to have diff
	from most recent to old."
	commits last checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.
	aSession resetProgramEntities.
	self flag: #SD.
	"here we flush the handler. May be we should reset the current handler because reinitialize it may flush the kind of handler"
	
	"then now we can reload from old to old -1"
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit.
		"I would ignore the first one because we loaded the code and then we go in the past.
		so the system will compute the diff while loading old code and generate
		bad "
		benchmark run.
		"we should flush items to make sure the next loading will only contain new elements"
		aSession resetDevelopmentItems ].

	^ { commits . benchmark }
]

{ #category : 'private' }
CooHistoryExperimentRunner >> prepareOutputDirectoryFor: aConfiguration [

	aConfiguration outputDirectory ensureCreateDirectory
]

{ #category : 'running' }
CooHistoryExperimentRunner >> run: aConfiguration [

	| result |
	self prepareOutputDirectoryFor: aConfiguration.
	self loadProjectFrom: aConfiguration.

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
