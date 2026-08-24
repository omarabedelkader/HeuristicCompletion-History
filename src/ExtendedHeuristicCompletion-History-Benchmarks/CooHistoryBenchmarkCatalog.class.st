"
Central place owning the predefined experimental subjects of the history
benchmark: repositories, commit-history windows, and configurations.

Repository strings must never be scattered through runner methods; they live
here only. All URLs are HTTPS so the benchmark does not require GitHub SSH
keys.

Commit windows include 0 on purpose: it is the cold condition with no
repository history replayed.
"
Class {
	#name : 'CooHistoryBenchmarkCatalog',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Model',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Model'
}

{ #category : 'configurations' }
CooHistoryBenchmarkCatalog class >> interactionConfigurations [
	"Treatments requiring a recorded field-study trace. They are never part of
	repository-only offline experiments because Git commits provide no real
	completion selections or navigation events."

	^ {
		  CooHistoryBenchmarkConfiguration recentFrequencySelection.
		  CooHistoryBenchmarkConfiguration navigation.
		  CooHistoryBenchmarkConfiguration combinedLiveHistory }
]

{ #category : 'repositories' }
CooHistoryBenchmarkCatalog class >> microdown [

	^ CooHistoryBenchmarkRepository
		  name: 'Microdown'
		  url: 'https://github.com/pillar-markup/Microdown.git'
		  loadBlock: [
			  Smalltalk globals at: #BaselineOfMicrodown ifPresent: [ :c | c removeFromSystem ].
			  Metacello new
				  baseline: 'Microdown';
				  repository: 'github://pillar-markup/Microdown:v2.9.3/src';
				  onConflict: [ :ex | ex useIncoming ];
				  onUpgrade: [ :ex | ex useIncoming ];
				  load: #( 'All' ) ]
]

{ #category : 'configurations' }
CooHistoryBenchmarkCatalog class >> offlineConfigurations [
	"Automatic offline treatments for the paper's repository experiment."

	^ {
		  CooHistoryBenchmarkConfiguration default.
		  CooHistoryBenchmarkConfiguration temporal.
		  CooHistoryBenchmarkConfiguration singleFrequency.
		  CooHistoryBenchmarkConfiguration weightedClassFrequency }
]

{ #category : 'windows' }
CooHistoryBenchmarkCatalog class >> quickCommitWindows [

	^ #( 0 5 )
]

{ #category : 'repositories' }
CooHistoryBenchmarkCatalog class >> roassal [

	^ CooHistoryBenchmarkRepository
		  name: 'Roassal'
		  url: 'https://github.com/pharo-graphics/Roassal.git'
		  loadBlock: [
			  Metacello new
				  baseline: 'Roassal';
				  repository:
					  'github://pharo-graphics/Roassal:Pharo'
					  , SystemVersion current major asString;
				  load: 'Full' ]
]

{ #category : 'repositories' }
CooHistoryBenchmarkCatalog class >> spec [

	^ CooHistoryBenchmarkRepository
		  name: 'Spec'
		  url: 'https://github.com/pharo-spec/spec.git'
]

{ #category : 'repositories' }
CooHistoryBenchmarkCatalog class >> comix [

	^ CooHistoryBenchmarkRepository
		  name: 'Comix2'
		  url: 'https://github.com/Ducasse/Comix2.git'
]

{ #category : 'windows' }
CooHistoryBenchmarkCatalog class >> defaultCommitWindows [

	^ #( 0 5 10 25 50 )
]

{ #category : 'repositories' }
CooHistoryBenchmarkCatalog class >> defaultRepositories [

	^ {
		  self comix.
		  self microdown.
		  self roassal.
		  self spec }
]

{ #category : 'configurations' }
CooHistoryBenchmarkCatalog class >> knownConfigurationNames [
	"All configuration names that must stay mutually unique because they end
	up as columns/labels in exported artifacts."

	^ (self offlineConfigurations , { CooHistoryBenchmarkConfiguration combinedStructuralHistory }
		   , self interactionConfigurations) collect: [ :each | each name ]
]

{ #category : 'windows' }
CooHistoryBenchmarkCatalog class >> fullCommitWindows [

	^ #( 0 5 10 25 50 100 )
]
