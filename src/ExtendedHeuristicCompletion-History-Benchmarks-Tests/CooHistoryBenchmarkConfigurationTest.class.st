"
Tests for the benchmark configurations, with special attention to baseline
isolation: the #default configuration is the reference of every comparison
and must never contain a history heuristic.
"
Class {
	#name : 'CooHistoryBenchmarkConfigurationTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testConfigurationNamesAreUnique [

	| names |
	names := CooHistoryBenchmarkCatalog knownConfigurationNames.
	self assert: (names asSet size = names size) description: 'Configuration names must be unique because they label exported artifacts'.
	self assert: (names includes: #default).
	self assert: (names includes: #temporal).
	self assert: (names includes: #singleFrequency).
	self assert: (names includes: #weightedClassFrequency)
]

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testDefaultConfigurationHasNoHistoryHeuristics [
	"Validity of the Default vs History comparison relies on this property."

	| configuration messageClasses variableClasses methodNodeClasses |
	configuration := CooHistoryBenchmarkConfiguration default.

	messageClasses := configuration messagesHeuristicClassesFor: CooSession new.
	variableClasses := configuration variableHeuristicClassesFor: CooSession new.
	methodNodeClasses := self
		                     chainClassesOf:
		                     (configuration methodNodesHeuristicsFor: CooSession new).

	self deny: (messageClasses includesAnyOf: { CooSessionMessagesHeuristic. CooSessionVariableHeuristic }).
	self deny: (variableClasses includesAnyOf: { CooSessionMessagesHeuristic. CooSessionVariableHeuristic }).
	self deny: (methodNodeClasses includesAnyOf: { CooSessionMessagesHeuristic. CooSessionVariableHeuristic }).
	self assert: configuration isBaseline
]

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testDefaultConfigurationKeepsStandardHeuristics [
	"The baseline must not be an empty builder: it has to behave like standard
	Complishon without history."

	| configuration messageClasses |
	configuration := CooHistoryBenchmarkConfiguration default.
	messageClasses := configuration messagesHeuristicClassesFor: CooSession new.
	self deny: messageClasses isEmpty.
	self assert: (messageClasses includes: CoUnknownMessageHeuristic)
]

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testHistoryConfigurationsPrependSessionHeuristics [

	| session messageClasses variableClasses |
	session := CooSession new.

	messageClasses := (CooHistoryBenchmarkConfiguration temporal)
		                  messagesHeuristicClassesFor: session.
	variableClasses := (CooHistoryBenchmarkConfiguration weightedClassFrequency)
		                   variableHeuristicClassesFor: session.

	self assert: messageClasses first identicalTo: CooSessionMessagesHeuristic.
	self assert: variableClasses first identicalTo: CooSessionVariableHeuristic
]

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testOfflineConfigurationsRequireNoInteractionTrace [

	CooHistoryBenchmarkCatalog offlineConfigurations do: [ :each |
		self deny: each requiresInteractionTrace description: each name , ' must run offline' ]
]

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testRequiresInteractionTraceFlags [

	self assert: CooHistoryBenchmarkConfiguration recentFrequencySelection requiresInteractionTrace.
	self assert: CooHistoryBenchmarkConfiguration navigation requiresInteractionTrace.
	self assert: CooHistoryBenchmarkConfiguration combinedLiveHistory requiresInteractionTrace.
	self deny: CooHistoryBenchmarkConfiguration temporal requiresInteractionTrace
]

{ #category : 'tests' }
CooHistoryBenchmarkConfigurationTest >> testTemporalConfigurationWiring [

	| configuration |
	configuration := CooHistoryBenchmarkConfiguration temporal.
	self assert: configuration name equals: #temporal.
	self assert: configuration programEntityHandlerClass identicalTo: CooTemporalHandler.
	self assert: configuration repositoryHistoryEnabled.
	self deny: configuration selectionHistoryEnabled.
	self deny: configuration navigationHistoryEnabled
]

{ #category : 'private - utilities' }
CooHistoryBenchmarkConfigurationTest >> chainClassesOf: aChainHeuristic [

	| classes current |
	classes := OrderedCollection new.
	current := aChainHeuristic.
	[ current isNil ] whileFalse: [
		classes add: current class.
		current := current next ].
	^ classes
]
