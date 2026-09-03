"
```
CooHistoryBenchmarksRunner
  runWithSession: CooSession current
  scope: (Package named: 'Spec2').
```


```
CooHistoryBenchmarksRunner run.
```
"
Class {
	#name : 'OLDCooHistoryBenchmarksRunner',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Limbo',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Limbo'
}

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> dryRunLoadingWithSession: aSession repositoryString: aString numberOfAnalyzedCommits: anInteger [

	| populator commits messageBenchmark variableBenchmark |
	"fill up the history"
	populator := HistoryCachePopulator repositoryNamed: aString .
	populator session: aSession.
	commits := populator commitsForHead: anInteger.


	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession; yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession; yourself.

	
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit
	].

	messageBenchmark run.
	variableBenchmark run.

^ {

        messageBenchmark.

        variableBenchmark

    }

]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> dryRunMicrodown [

	<script>
	Smalltalk globals at: #BaselineOfMicrodown ifPresent: [ :c | c removeFromSystem ].

	Metacello new
		baseline: 'Microdown';
		repository: 'github://pillar-markup/Microdown:v2.9.3/src';
		onConflict: [ :ex | ex useIncoming ];
		onUpgrade: [ :ex | ex useIncoming ];
		load: #( 'All' ).

	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	Transcript show: CooSession current reportString.

	self
		dryRunLoadingWithSession: CooSession current
		repositoryString: 'git@github.com:pillar-markup/Microdown.git'
		numberOfAnalyzedCommits: 15.

	Transcript show: CooSession current reportString
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> newRunWithSession: aSession [ 
	"Run benchmarks with a specific session and scope.
	Example: CooHistoryBenchmarksRunner runWithSession: CooSession current scope: (RPackage named: 'Kernel')"

	"CooHistoryBenchmarksRunner 
		newRunWithSession: CooSession current )"

	| populator messageBenchmark variableBenchmark commits |
	"fill up the history"
	populator := HistoryCachePopulator repositoryNamed: 'git@github.com:Ducasse/Comix2.git'.
	populator session: aSession.
	commits := populator commitsForHead: 10.

	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession; yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession; yourself.
	
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit
	].

	messageBenchmark run.
	variableBenchmark run.

	^ {
		  messageBenchmark.
		  variableBenchmark } inspect
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> newRunWithSession: aSession repositoryString: aString numberOfAnalyzedCommits: anInteger [

	| populator messageBenchmark variableBenchmark commits |
	"fill up the history"
	populator := HistoryCachePopulator repositoryNamed: aString .
	populator session: aSession.
	commits := populator commitsForHead: anInteger.

	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession; yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession; yourself.
	
	commits reverseDo: [ :commit |
		populator loadFromOldToNewCommit: commit
	].

	messageBenchmark run.
	variableBenchmark run.

	^ {
		  messageBenchmark.
		  variableBenchmark } inspect
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> run [
	
	^ self newRunWithSession: CooSession current
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> runComix [
	<script>
	
	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	Transcript show: CooSession current reportString.
	(self newRunWithSession: CooSession current repositoryString:  'git@github.com:Ducasse/Comix2.git' numberOfAnalyzedCommits: 10) inspect.
	Transcript show: CooSession current reportString
	
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> runMicrodown [
	<script>
	
	
	
	Smalltalk globals
	at: #BaselineOfMicrodown 
	ifPresent: [ :c | c removeFromSystem ].

	Metacello new
		baseline: 'Microdown';
		repository: 'github://pillar-markup/Microdown:v2.9.3/src';
		onConflict: [ :ex | ex useIncoming ];
		onUpgrade: [ :ex | ex useIncoming ];
		load: #('All').
	
	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	Transcript show: CooSession current reportString.
	
	
	(self newRunWithSession: CooSession current repositoryString:  'git@github.com:pillar-markup/Microdown.git' numberOfAnalyzedCommits: 15).
	
	Transcript show: CooSession current reportString
	
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> runMicrodownExperiment [

	<script>
	^ CooHistoryExperimentRunner runMicrodown
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> runRoassal [
	<script>
	
	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	Metacello new
			baseline: 'Roassal';
			repository: 'github://pharo-graphics/Roassal:Pharo' , SystemVersion current major asString;
			load: 'Full'.
	(self newRunWithSession: CooSession current repositoryString:  'git@github.com:pharo-graphics/Roassal.git' numberOfAnalyzedCommits: 1) inspect
]

{ #category : 'running' }
OLDCooHistoryBenchmarksRunner class >> runSpc [
	<script>
	
	CooSession resetProgramEntities.
	CooSession current noUserSelectionHandling.
	Transcript show: CooSession current reportString.
	self newRunWithSession: CooSession current repositoryString:  'git@github.com:pharo-spec/spec.git' numberOfAnalyzedCommits: 10.
	Transcript show: CooSession current reportString
	
]
