"
I orchestrate a complete project-level History experiment and write its report artifacts.
"
Class {
	#name : 'CooHistoryExperimentRunner',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
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

{ #category : 'private' }
CooHistoryExperimentRunner >> analyzeHistoryAndBenchmarksFor: aConfiguration session: aSession [

	| statistics commits comparison |
	statistics := CooHistoryProjectStatistics new.
	statistics collectRepositoryStatisticsFrom: aConfiguration.

	commits := self
		           populateHistoryFor: aConfiguration
		           session: aSession.

	statistics historyCommitCount: commits size.
	statistics collectHistoryStatisticsFrom: aSession.

	comparison := CooHistoryBenchmarkComparison new.
	^ comparison
		  runForConfiguration: aConfiguration
		  session: aSession
		  commitCount: commits size
		  statistics: statistics
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

	| populator commits |
	populator := HistoryCachePopulator repo: aConfiguration repository.
	populator session: aSession.
	commits := populator commitsForHead: aConfiguration numberOfCommits.

	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit ].

	^ commits
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
