"
WHAT TO RUN: the declarative specification of one experiment.

An experiment lists the repositories, the configurations (treatments), the
commit-history windows, the completion targets, and the measurement
parameters. The runner executes exactly what the specification says; nothing
about the experiment is encoded in the runner's control flow.

#full is the complete paper experiment, #quick is a small development variant.
"
Class {
	#name : 'CooHistoryBenchmarkExperiment',
	#superclass : 'Object',
	#instVars : [
		'repositories',
		'configurations',
		'commitWindows',
		'targets',
		'topK',
		'prefixSizes'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Model',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Model'
}

{ #category : 'defaults' }
CooHistoryBenchmarkExperiment class >> defaultTargets [

	^ #( #selector #className )
]

{ #category : 'specifications' }
CooHistoryBenchmarkExperiment class >> full [

	^ self new
		  repositories: CooHistoryBenchmarkCatalog defaultRepositories;
		  configurations: CooHistoryBenchmarkCatalog offlineConfigurations;
		  commitWindows: CooHistoryBenchmarkCatalog defaultCommitWindows;
		  targets: self defaultTargets;
		  topK: 10;
		  prefixSizes: #( 2 3 4 5 6 7 8 );
		  yourself
]

{ #category : 'specifications' }
CooHistoryBenchmarkExperiment class >> quick [

	^ self new
		  repositories: { CooHistoryBenchmarkCatalog microdown };
		  configurations: CooHistoryBenchmarkCatalog offlineConfigurations;
		  commitWindows: CooHistoryBenchmarkCatalog quickCommitWindows;
		  targets: self defaultTargets;
		  topK: 10;
		  prefixSizes: #( 2 3 4 );
		  yourself
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> commitWindows [

	^ commitWindows
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> commitWindows: aCollection [

	commitWindows := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> configurations [

	^ configurations
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> configurations: aCollection [

	configurations := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> maxCommitWindow [

	^ commitWindows max
]

{ #category : 'printing' }
CooHistoryBenchmarkExperiment >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: '(';
		print: repositories size;
		nextPutAll: ' repositories x ';
		print: commitWindows size;
		nextPutAll: ' windows x ';
		print: configurations size;
		nextPutAll: ' configurations)';
		cr
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> prefixSizes [

	^ prefixSizes
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> prefixSizes: aCollection [

	prefixSizes := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> repositories [

	^ repositories
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> repositories: aCollection [

	repositories := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> targets [

	^ targets
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> targets: aCollection [

	targets := aCollection
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> topK [

	^ topK
]

{ #category : 'accessing' }
CooHistoryBenchmarkExperiment >> topK: anInteger [

	topK := anInteger
]

{ #category : 'testing' }
CooHistoryBenchmarkExperiment >> treatmentCombinationsCount [
	"Number of repository x window x configuration cells; each cell runs one
	benchmark per target."

	^ repositories size * commitWindows size * configurations size
	  * targets size
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validate [
	"Fails early with understandable errors before thousands of queries run."

	self validateRepositories.
	self validateConfigurations.
	self validateCommitWindows.
	self validateTargetsAndParameters.
	self validateRequiredClasses.
	self validateBaselineIsolation
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validateBaselineIsolation [
	"The Default vs History comparison is only valid if the baseline builder
	contains no history heuristic."

	| baseline baselineMessageClasses |
	baseline := configurations detect: [ :each | each name = #default ] ifNone: [
		            ^ Error signal:
			              'The experiment must contain the #default configuration: it is the baseline of every comparison.' ].
	baselineMessageClasses := baseline messagesHeuristicClassesFor: CooSession new.
	(baselineMessageClasses includesAnyOf: {
			 CooSessionMessagesHeuristic.
			 CooSessionVariableHeuristic }) ifTrue: [
		Error signal: 'Baseline isolation broken: #default configuration contains history heuristics.' ]
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validateCommitWindows [

	commitWindows isEmpty ifTrue: [
		Error signal: 'The experiment needs at least one history window.' ].
	commitWindows do: [ :window |
		window isInteger and: [ window >= 0 ] ifFalse: [
			Error signal: 'Invalid history window: ' , window printString ] ].
	(commitWindows asSet size = commitWindows size) ifFalse: [
		Error signal: 'History windows must be unique.' ]
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validateConfigurations [

	| names |
	configurations isEmpty ifTrue: [
		Error signal: 'The experiment needs at least one configuration.' ].
	names := configurations collect: [ :each | each name ].
	names size = names asSet size ifFalse: [
		Error signal:
			'Configuration names must be unique, got: ' , names asArray printString ].
	configurations do: [ :configuration |
		configuration requiresInteractionTrace ifTrue: [
			Error signal:
				'Configuration ' , configuration name printString
				, ' requires an interaction trace and cannot be part of a repository-only offline experiment.' ] ]
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validateRequiredClasses [
	"Compatibility boundary: check that the experiment machinery is loaded."

	#( CoASTHeuristicsResultSetBuilder HistoryCachePopulator CoCaseSensitiveBeginsWithFilter )
		do: [ :symbol |
			(self class environment includesKey: symbol) ifFalse: [
				Error signal:
					'Required class not loaded in the image: ' , symbol printString ] ]
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validateRepositories [

	repositories isEmpty ifTrue: [
		Error signal: 'The experiment needs at least one repository.' ].
	repositories do: [ :repository |
		repository name ifNil: [ Error signal: 'A repository has no name.' ].
		repository url ifNil: [ Error signal: 'Repository has no URL: ' , repository name ] ].
	(repositories collect: [ :each | each name ]) asSet size
	< repositories size ifTrue: [
		Error signal: 'Repository names must be unique.' ]
]

{ #category : 'validation' }
CooHistoryBenchmarkExperiment >> validateTargetsAndParameters [

	targets isEmpty ifTrue: [ Error signal: 'At least one target is needed.' ].
	targets do: [ :target |
		(#( #selector #className ) includes: target) ifFalse: [
			Error signal: 'Unknown target kind: ' , target printString ] ].
	topK isInteger and: [ topK > 0 ] ifFalse: [
		Error signal: 'topK must be a positive integer.' ].
	prefixSizes do: [ :size |
		size isInteger and: [ size >= 1 ] ifFalse: [
			Error signal: 'Invalid prefix size: ' , size printString ] ]
]
