Class {
	#name : 'CooHistoryBenchRunner',
	#superclass : 'CooBenchRunner',
	#instVars : [
		'historyPopulator'
	],
	#category : 'ExtendedHeuristicCompletion-History-Bench',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Bench'
}

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runOnPackage: aPackageNameOrPackage [
	"Run benchmarks on the given package using existing history."
	
	^ self new
		package: (aPackageNameOrPackage isString
			ifTrue: [ PackageOrganizer default packageNamed: aPackageNameOrPackage ]
			ifFalse: [ aPackageNameOrPackage ]);
		baseline: #baselineNoHistory;
		others: { 
			#temporalMessages. 
			#frequencyMessages. 
			#temporalVariables. 
			#frequencyVariables. 
			#combinedHistory 
		};
		run;
		yourself
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runOnPackage: aPackageNameOrPackage withHistory: repoURL commits: commitCount [
	"Run benchmarks after populating history from a Git repository."
	
	| runner package |
	package := aPackageNameOrPackage isString
		ifTrue: [ PackageOrganizer default packageNamed: aPackageNameOrPackage ]
		ifFalse: [ aPackageNameOrPackage ].
	
	runner := self new
		package: package;
		baseline: #baselineNoHistory;
		others: { 
			#temporalMessages. 
			#frequencyMessages. 
			#temporalVariables. 
			#frequencyVariables. 
			#combinedHistory 
		};
		yourself.
	
	"Populate history from Git"
	Transcript show: 'Populating history from repository...'; cr.
	runner populateHistoryFrom: repoURL commits: commitCount.
	
	"Run benchmarks"
	^ runner run; yourself
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> spec [
	<script>
	^ (self runOnPackage: 'Spec2-Core') inspect
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> specWithHistory [
	<script>
	^ (self 
		runOnPackage: 'Spec2-Core' 
		withHistory: 'https://github.com/pharo-spec/Spec' 
		commits: 50) inspect
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> baselineNoHistory [
	"Baseline without any history heuristics."
	
	| builder benchmark |
	builder := CoASTHeuristicsResultSetBuilder new.
	
	"Only use standard heuristics"
	builder messageHeuristic: (builder newHeuristicBuilder
		add: CoUnknownMessageHeuristic new;
		build).
	
	builder variablesHeuristic: (builder newHeuristicBuilder
		add: CoGlobalVariablesHeuristic new;
		build).
	
	benchmark := self createBenchmarkNamed: 'Baseline (No History)' withBuilder: builder.
	^ benchmark
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> combinedHistory [
	"Use all history heuristics together."
	
	| builder benchmark |
	builder := CoASTHeuristicsResultSetBuilder new.
	
	"Message heuristics with history"
	builder messageHeuristic: (builder newHeuristicBuilder
		add: CooSessionTemporalMessagesHeuristic new;
		add: CooSessionFrequencyMessagesHeuristic new;
		add: CoUnknownMessageHeuristic new;
		build).
	
	"Variable heuristics with history"
	builder variablesHeuristic: (builder newHeuristicBuilder
		add: CooSessionTemporalVariableHeuristic new;
		add: CooSessionFrequencyVariableHeuristic new;
		add: CoLocalScopeVariablesHeuristic new;
		add: CoWorkspaceVariablesHeuristic new;
		add: CoInstanceAccessibleVariablesHeuristic new;
		add: CoGlobalVariablesHeuristic new;
		build).
	
	benchmark := self createBenchmarkNamed: 'Combined History (All)' withBuilder: builder.
	^ benchmark
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> createBenchmarkNamed: aName withBuilder: aBuilder [
	"Create and run a benchmark with the given configuration."
	
	| benchmark |
	benchmark := self isMessageBenchmark
		ifTrue: [ CooStaticBenchmarksMessage new ]
		ifFalse: [ CooStaticBenchmarksVariables new ].
	
	benchmark
		name: aName;
		scope: (CoBenchmarkPackage on: package);
		builder: aBuilder;
		run.
	
	^ benchmark
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> frequencyMessages [
	"Use frequency-based message history."
	
	| builder benchmark |
	builder := CoASTHeuristicsResultSetBuilder new.
	
	builder messageHeuristic: (builder newHeuristicBuilder
		add: CooSessionFrequencyMessagesHeuristic new;
		build).
	
	benchmark := self createBenchmarkNamed: 'Frequency Messages History' withBuilder: builder.
	^ benchmark
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> frequencyVariables [
	"Use frequency-based variable history."
	
	| builder benchmark |
	builder := CoASTHeuristicsResultSetBuilder new.
	
	builder variablesHeuristic: (builder newHeuristicBuilder
		add: CooSessionFrequencyVariableHeuristic new;
		build).
	
	benchmark := self createBenchmarkNamed: 'Frequency Variables History' withBuilder: builder.
	^ benchmark
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> initialize [

	super initialize.
	historyPopulator := nil
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> isMessageBenchmark [
	"Determine if we should run message or variable benchmarks based on package content."
	
	"Default to message benchmarks; can be overridden"
	^ true
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> populateHistoryFrom: repoURL commits: commitCount [
	"Populate history caches from a Git repository."
	
	historyPopulator := HistoryCachePopulator new
		scrapper: (HistoryScrapper new
			repositoryURL: repoURL;
			commitCount: commitCount;
			initializeRepository;
			yourself);
		populateCaches;
		yourself.
	
	Transcript 
		show: 'History populated: ';
		show: CooSessionTemporalMessages current size asString, ' temporal messages, ';
		show: CooSessionFrequencyMessages current size asString, ' frequency messages, ';
		show: CooSessionTemporalVariable current size asString, ' temporal variables, ';
		show: CooSessionFrequencyVariable current size asString, ' frequency variables';
		cr
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> resetHistory [
	"Reset all history caches."
	
	CooSessionTemporalMessages reset.
	CooSessionFrequencyMessages reset.
	CooSessionTemporalVariable reset.
	CooSessionFrequencyVariable reset.
	
	Transcript show: 'History caches reset.'; cr
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> temporalMessages [
	"Use temporal (recency-based) message history."
	
	| builder benchmark |
	builder := CoASTHeuristicsResultSetBuilder new.
	
	builder messageHeuristic: (builder newHeuristicBuilder
		add: CooSessionTemporalMessagesHeuristic new;
		build).
		
	benchmark := self createBenchmarkNamed: 'Temporal Messages History' withBuilder: builder.
	^ benchmark
]

{ #category : 'accessing' }
CooHistoryBenchRunner >> temporalVariables [
	"Use temporal (recency-based) variable history."
	
	| builder benchmark |
	builder := CoASTHeuristicsResultSetBuilder new.
	
	builder variablesHeuristic: (builder newHeuristicBuilder
		add: CooSessionTemporalVariableHeuristic new;
		build).
	
	benchmark := self createBenchmarkNamed: 'Temporal Variables History' withBuilder: builder.
	^ benchmark
]
