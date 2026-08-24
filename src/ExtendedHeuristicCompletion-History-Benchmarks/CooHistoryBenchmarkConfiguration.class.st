"
One experimental treatment (configuration) of the history benchmark.

A configuration declares which handlers and completion heuristics a treatment
uses. Names are stable identifiers: they appear in CSV files and paper tables,
so they must never be renamed casually.

The #default configuration is the critical baseline of the whole experiment:
it must execute standard Complishon with NO history heuristic in the
completion builder. Isolation is enforced at the builder level by
CooHistoryBenchmarkConfiguration >> messagesHeuristicsFor: and
variablesHeuristicsFor:, which strip every session history heuristic from the
default chains even when the production image globally installed them
(see CooSession installCompletionHeuristics).

Configurations requiring real interaction traces (selection or navigation
events) are excluded from repository-only offline experiments because Git
replay provides structural events only. Producing artificial selection data
from commits would invalidate the experiment.
"
Class {
	#name : 'CooHistoryBenchmarkConfiguration',
	#superclass : 'Object',
	#instVars : [
		'name',
		'programEntityHandlerClass',
		'userSelectionHandlerClass',
		'repositoryHistoryEnabled',
		'navigationHistoryEnabled',
		'selectionHistoryEnabled',
		'completionMode'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Model',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Model'
}

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> combinedLiveHistory [

	^ self new
		  name: #combinedLiveHistory;
		  programEntityHandlerClass: CooTemporalHandler;
		  userSelectionHandlerClass: CooMostRecentFrequencyHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: true;
		  navigationHistoryEnabled: true;
		  yourself
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> combinedStructuralHistory [
	"Reserved for a future configuration combining several structural signals.
	It is intentionally not part of the offline catalog yet: today it would be
	identical to #temporal, and adding it would duplicate a treatment without
	adding information to the comparison."

	^ self new
		  name: #combinedStructuralHistory;
		  programEntityHandlerClass: CooTemporalHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: false;
		  navigationHistoryEnabled: false;
		  yourself
]

{ #category : 'defaults' }
CooHistoryBenchmarkConfiguration class >> defaultCompletionMode [

	^ #astHeuristics
]

{ #category : 'defaults' }
CooHistoryBenchmarkConfiguration class >> defaultUserSelectionHandlerClass [

	^ CooNullUserSelectionHandler
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> default [
	"The baseline: standard completion without any history contribution."

	^ self new
		  name: #default;
		  repositoryHistoryEnabled: false;
		  selectionHistoryEnabled: false;
		  navigationHistoryEnabled: false;
		  yourself
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> navigation [

	^ self new
		  name: #navigation;
		  programEntityHandlerClass: CooTemporalHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: false;
		  navigationHistoryEnabled: true;
		  yourself
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> recentFrequencySelection [

	^ self new
		  name: #recentFrequencySelection;
		  programEntityHandlerClass: CooTemporalHandler;
		  userSelectionHandlerClass: CooMostRecentFrequencyHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: true;
		  navigationHistoryEnabled: false;
		  yourself
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> singleFrequency [

	^ self new
		  name: #singleFrequency;
		  programEntityHandlerClass: CooSingleFrequencyHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: false;
		  navigationHistoryEnabled: false;
		  yourself
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> temporal [

	^ self new
		  name: #temporal;
		  programEntityHandlerClass: CooTemporalHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: false;
		  navigationHistoryEnabled: false;
		  yourself
]

{ #category : 'predefined configurations' }
CooHistoryBenchmarkConfiguration class >> weightedClassFrequency [

	^ self new
		  name: #weightedClassFrequency;
		  programEntityHandlerClass: CooWeightedClassFrequencyHandler;
		  repositoryHistoryEnabled: true;
		  selectionHistoryEnabled: false;
		  navigationHistoryEnabled: false;
		  yourself
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> buildHeuristicChain: aCollection [
	"A chain built from an empty list would fail; the null fetcher keeps the
	builder protocol intact for degenerate cases."

	aCollection ifEmpty: [ ^ CoNullFetcherHeuristic new ].

	| chainBuilder |
	chainBuilder := CoHeuristicBuilder new.
	aCollection do: [ :each | chainBuilder add: each ].
	^ chainBuilder build
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> defaultMessageHeuristicsWithoutHistory [
	"Copies of the default heuristics: the chain building mutates next links,
	so sharing instances with the global configuration would corrupt it."

	^ (CoASTHeuristicsResultSetBuilder messagesHeuristic reject: [ :each |
			   each isKindOf: CooSessionMessagesHeuristic ]) collect: [ :each | each copy ]
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> defaultMethodNodeHeuristicsWithoutHistory [

	^ (CoASTHeuristicsResultSetBuilder methodNodesHeuristic collect: [ :each |
			   each copy ])
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> defaultVariableHeuristicsWithoutHistory [

	^ (CoASTHeuristicsResultSetBuilder variablesHeuristic reject: [ :each |
			   each isKindOf: CooSessionVariableHeuristic ]) collect: [ :each | each copy ]
]

{ #category : 'initialization' }
CooHistoryBenchmarkConfiguration >> initialize [

	super initialize.
	completionMode := self class defaultCompletionMode.
	repositoryHistoryEnabled := false.
	navigationHistoryEnabled := false.
	selectionHistoryEnabled := false.
	userSelectionHandlerClass := self class defaultUserSelectionHandlerClass
]

{ #category : 'testing' }
CooHistoryBenchmarkConfiguration >> isBaseline [

	^ self usesHistoryHeuristics not
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> messagesHeuristicClassesFor: aSession [

	^ self chainClassesOf: (self messagesHeuristicsFor: aSession)
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> messagesHeuristicsFor: aSession [

	^ self buildHeuristicChain: (self usesHistoryHeuristics
			  ifTrue: [
				  { (CooSessionMessagesHeuristic new
					   session: aSession;
					   yourself) }
					  , self defaultMessageHeuristicsWithoutHistory ]
			  ifFalse: [ self defaultMessageHeuristicsWithoutHistory ])
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> methodNodesHeuristicsFor: aSession [

	^ self buildHeuristicChain: (self usesHistoryHeuristics
			  ifTrue: [
				  { (CooSessionMessagesHeuristic new
					   session: aSession;
					   yourself) }
					  , self defaultMethodNodeHeuristicsWithoutHistory ]
			  ifFalse: [ self defaultMethodNodeHeuristicsWithoutHistory ])
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> name [

	^ name
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> name: aSymbol [

	name := aSymbol
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> navigationHistoryEnabled [

	^ navigationHistoryEnabled
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> navigationHistoryEnabled: aBoolean [

	navigationHistoryEnabled := aBoolean
]

{ #category : 'printing' }
CooHistoryBenchmarkConfiguration >> printOn: aStream [

	aStream nextPutAll: self class name.
	name ifNotNil: [ aStream print: name ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> programEntityHandlerClass [

	^ programEntityHandlerClass
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> programEntityHandlerClass: aClass [

	programEntityHandlerClass := aClass
]

{ #category : 'testing' }
CooHistoryBenchmarkConfiguration >> requiresInteractionTrace [

	"Repository replay yields structural events only. Treatments needing
	completion selections or navigation events require a recorded trace."

	^ selectionHistoryEnabled or: [ navigationHistoryEnabled ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> repositoryHistoryEnabled [

	^ repositoryHistoryEnabled
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> repositoryHistoryEnabled: aBoolean [

	repositoryHistoryEnabled := aBoolean
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> selectionHistoryEnabled [

	^ selectionHistoryEnabled
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> selectionHistoryEnabled: aBoolean [

	selectionHistoryEnabled := aBoolean
]

{ #category : 'chain introspection' }
CooHistoryBenchmarkConfiguration >> chainClassesOf: aChainHeuristic [

	| classes current |
	classes := OrderedCollection new.
	current := aChainHeuristic.
	[ current isNil ] whileFalse: [
		classes add: current class.
		current := current next ].
	^ classes
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> completionMode [

	^ completionMode
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> completionMode: aSymbol [

	completionMode := aSymbol
]

{ #category : 'testing' }
CooHistoryBenchmarkConfiguration >> usesHistoryHeuristics [

	^ repositoryHistoryEnabled
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> userSelectionHandlerClass [

	^ userSelectionHandlerClass
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> userSelectionHandlerClass: aClass [

	userSelectionHandlerClass := aClass
]

{ #category : 'accessing' }
CooHistoryBenchmarkConfiguration >> variableHeuristicClassesFor: aSession [

	^ self chainClassesOf: (self variablesHeuristicsFor: aSession)
]

{ #category : 'building' }
CooHistoryBenchmarkConfiguration >> variablesHeuristicsFor: aSession [

	^ self buildHeuristicChain: (self usesHistoryHeuristics
			  ifTrue: [
				  { (CooSessionVariableHeuristic new
					   session: aSession;
					   yourself) }
					  , self defaultVariableHeuristicsWithoutHistory ]
			  ifFalse: [ self defaultVariableHeuristicsWithoutHistory ])
]
