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
CooHistoryBenchRunner class >> configuredRunnerForPackage: aPackageNameOrPackage [
    ^ self new
            package: (self packageFrom: aPackageNameOrPackage);
            baseline: #baselineNoHistory;
            others: self historyBenchmarkSelectors;
            yourself
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> historyBenchmarkSelectors [
    ^ {
            #temporalMessages.
            #frequencyMessages.
            #temporalVariables.
            #frequencyVariables.
            #combinedHistory }
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> packageFrom: aPackageNameOrPackage [
    ^ aPackageNameOrPackage isString
            ifTrue: [ PackageOrganizer default packageNamed: aPackageNameOrPackage ]
            ifFalse: [ aPackageNameOrPackage ]
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> populateHistoryFrom: repoURL commits: commitCount [
    Transcript show: 'Populating history from repository...'; cr.
    self new populateHistoryFrom: repoURL commits: commitCount
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> resultsForPackages: packageNamesOrPackages [
    | packageNames |
    packageNames := packageNamesOrPackages collect: [ :each |
            each isString
                    ifTrue: [ each ]
                    ifFalse: [ each name ] ].
    ^ self allResultsFor: packageNames
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> resultsForPackages: packageNamesOrPackages withHistory: repoURL commits: commitCount [
    self populateHistoryFrom: repoURL commits: commitCount.
    ^ self resultsForPackages: packageNamesOrPackages
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runComparisonForPackages: aCol [
    | packages runners |
    packages := aCol collect: [ :each | self packageFrom: each ].
    runners := OrderedCollection new.
    packages do: [ :each |
            | runner |
            runner := self configuredRunnerForPackage: each.
            runner run.
            runners add: runner ].
    ^ runners
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runOnPackage: aPackageNameOrPackage [
	^ (self runComparisonForPackages: { aPackageNameOrPackage }) first
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runOnPackage: aPackageNameOrPackage withHistory: repoURL commits: commitCount [
	"Run benchmarks after populating history from a Git repository."

    self populateHistoryFrom: repoURL commits: commitCount.
    ^ self runOnPackage: aPackageNameOrPackage
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runOnPackages: packageNamesOrPackages [
^ self runComparisonForPackages: packageNamesOrPackages
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> runOnPackages: packageNamesOrPackages withHistory: repoURL commits: commitCount [
    "Populate history once and run benchmarks for multiple packages."

    self populateHistoryFrom: repoURL commits: commitCount.
    ^ self runOnPackages: packageNamesOrPackages

]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> spec [
	<script>
	^ (self runOnPackage: 'Spec2-Core') inspect
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> specPackageNames [
        ^ #(
                'Spec2-Adapters-Morphic'
                'Spec2-Adapters-Morphic-ListView'
                'Spec2-Adapters-Stub'
                'Spec2-Code'
                'Spec2-Code-Commands'
                'Spec2-Code-Diff'
                'Spec2-Code-Diff-Morphic'
                'Spec2-Code-Morphic'
                'Spec2-CommandLine'
                'Spec2-Commander2'
                'Spec2-Commands'
                'Spec2-CommonWidgets'
                'Spec2-Core'
                'Spec2-Dialogs'
                'Spec2-Examples'
                'Spec2-Interactions'
                'Spec2-Layout'
                'Spec2-ListView'
                'Spec2-Microdown'
                'Spec2-Morphic'
                'Spec2-Morphic-Examples'
                'Spec2-Transmission')
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> specWithHistory [

	<script>
        ^ (self
                runOnPackages: self specPackageNames
                withHistory: 'https://github.com/pharo-spec/Spec'
                commits: 50) inspect
]

{ #category : 'accessing' }
CooHistoryBenchRunner class >> specWithHistoryResults [

        <script>
        ^ (self
                resultsForPackages: self specPackageNames
                withHistory: 'https://github.com/pharo-spec/Spec'
                commits: 600) inspect
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
