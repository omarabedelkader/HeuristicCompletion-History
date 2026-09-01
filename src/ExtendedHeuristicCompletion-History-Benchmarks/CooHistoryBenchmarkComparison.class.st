"
I build the two benchmark strategies used by History experiments.

Dependency means Complete + Direct Package Dependencies. For the default
comparison, both strategies keep the same complete semantic base and differ only
in whether the additional source is the replayed history session or direct
package dependencies.
"
Class {
	#name : 'CooHistoryBenchmarkComparison',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'benchmarks' }
CooHistoryBenchmarkComparison >> completeDirectDependencyMessageBenchmarkFor: aScope session: aSession [

	| benchmark |
	benchmark := CooStaticBenchmarksMessageHistory new.
	benchmark
		name: 'Dependency';
		session: aSession;
		scope: aScope;
		builder: self completeDirectDependencyMessageBuilder.
	benchmark run.
	^ benchmark
]

{ #category : 'builders' }
CooHistoryBenchmarkComparison >> completeDirectDependencyMessageBuilder [

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

{ #category : 'benchmarks' }
CooHistoryBenchmarkComparison >> completeDirectDependencyVariableBenchmarkFor: aScope session: aSession [

	| benchmark |
	benchmark := CooStaticBenchmarksVariableHistory new.
	benchmark
		name: 'Dependency';
		session: aSession;
		scope: aScope;
		builder: self completeDirectDependencyVariableBuilder.
	benchmark run.
	^ benchmark
]

{ #category : 'builders' }
CooHistoryBenchmarkComparison >> completeDirectDependencyVariableBuilder [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoInstanceAccessibleVariablesHeuristic new;
			 add: (CoGlobalVariablesHeuristic new
					  globalVariableFetcherClass:
						  CoDependencyGlobalVariableFetcher);
			 build).
	^ builder
]

{ #category : 'accessing' }
CooHistoryBenchmarkComparison >> dependencyConfigurationName [

	^ 'Complete + Direct Package Dependencies'
]

{ #category : 'benchmarks' }
CooHistoryBenchmarkComparison >> historyMessageBenchmarkWithSession: aSession scope: aScope [

	| benchmark |
	benchmark := CooStaticBenchmarksMessageHistory new.
	benchmark
		name: 'History';
		session: aSession;
		scope: aScope;
		builder: (self historyMessageBuilderWithSession: aSession).
	benchmark run.
	^ benchmark
]

{ #category : 'builders' }
CooHistoryBenchmarkComparison >> historyMessageBuilderWithSession: aSession [

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
			 add: (CooSessionMessagesHeuristic new
					  session: aSession;
					  yourself);
			 add: CoUnknownMessageHeuristic new;
			 build).
	^ builder
]

{ #category : 'benchmarks' }
CooHistoryBenchmarkComparison >> historyVariableBenchmarkWithSession: aSession scope: aScope [

	| benchmark |
	benchmark := CooStaticBenchmarksVariableHistory new.
	benchmark
		name: 'History';
		session: aSession;
		scope: aScope;
		builder: (self historyVariableBuilderWithSession: aSession).
	benchmark run.
	^ benchmark
]

{ #category : 'builders' }
CooHistoryBenchmarkComparison >> historyVariableBuilderWithSession: aSession [

	| builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	builder variablesHeuristic: (builder newHeuristicBuilder
			 add: CoInstanceAccessibleVariablesHeuristic new;
			 add: (CooSessionVariableHeuristic new
					  session: aSession;
					  yourself);
			 build).
	^ builder
]

{ #category : 'running' }
CooHistoryBenchmarkComparison >> runForConfiguration: aConfiguration session: aSession commitCount: commitCount statistics: statistics [

	| scope result messageHistory messageDependency variableHistory variableDependency |
	scope := aConfiguration benchmarkScope.

	messageHistory := self
		                  historyMessageBenchmarkWithSession: aSession
		                  scope: scope.
	messageDependency := self
		                     completeDirectDependencyMessageBenchmarkFor: scope
		                     session: aSession.
	variableHistory := self
		                   historyVariableBenchmarkWithSession: aSession
		                   scope: scope.
	variableDependency := self
		                      completeDirectDependencyVariableBenchmarkFor: scope
		                      session: aSession.

	statistics
		recordBenchmarkPopulationFromMessageBenchmark: messageHistory
		variableBenchmark: variableHistory.

	result := CooHistoryExperimentResult new.
	result
		projectName: aConfiguration name;
		repository: aConfiguration repository;
		commitCount: commitCount;
		statistics: statistics;
		dependencyConfigurationName: self dependencyConfigurationName;
		comparisonDescription:
			'Complete semantics + History vs Complete semantics + Direct Package Dependencies';
		messageHistoryBenchmark: messageHistory;
		messageDependencyBenchmark: messageDependency;
		variableHistoryBenchmark: variableHistory;
		variableDependencyBenchmark: variableDependency.
	^ result
]
