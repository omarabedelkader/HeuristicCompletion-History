"
I capture the outcome of one project-level History experiment.

I hold the ten benchmarks produced by CooHistoryExperimentRunner — message and
variable completion, each under the Baseline, Semantic, History, Dependency and Hybrid
configurations — together with the project metadata and the statistics
collected while replaying the history.

I am the source of truth consumed by:
- CooHistoryBenchmarkPlotter (figures),
- CooHistoryLatexExporter (LaTeX tables),
- #saveSTON in the runner (machine-readable summary).
"
Class {
	#name : 'CooHistoryExperimentResult',
	#superclass : 'Object',
	#instVars : [
		'projectName',
		'repository',
		'statistics',
		'messageHistoryBenchmark',
		'messageDependencyBenchmark',
		'variableHistoryBenchmark',
		'variableDependencyBenchmark',
		'commitCount',
		'comparisonDescription',
		'messageSemanticBenchmark',
		'variableSemanticBenchmark',
		'messageBaselineBenchmark',
		'variableBaselineBenchmark',
		'messageHybridBenchmark',
		'variableHybridBenchmark'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'converting' }
CooHistoryExperimentResult >> asSTONDictionary [

	^ Dictionary newFrom: {
		  #project -> projectName.
		  #repository -> repository.
		  #commitsAnalyzed -> commitCount.
		  #comparison -> comparisonDescription.
		  #statistics -> statistics asDictionary.
		  #messages -> (Dictionary newFrom: {
				   #baseline -> (self dictionaryForBenchmark: messageBaselineBenchmark).
				   #semantic -> (self dictionaryForBenchmark: messageSemanticBenchmark).
				   #history -> (self dictionaryForBenchmark: messageHistoryBenchmark).
				   #completeDirectDependency -> (self dictionaryForBenchmark:
						    messageDependencyBenchmark).
				   #hybrid -> (self dictionaryForBenchmark: messageHybridBenchmark) }).
		  #variables -> (Dictionary newFrom: {
				   #baseline -> (self dictionaryForBenchmark: variableBaselineBenchmark).
				   #semantic -> (self dictionaryForBenchmark: variableSemanticBenchmark).
				   #history -> (self dictionaryForBenchmark: variableHistoryBenchmark).
				   #completeDirectDependency -> (self dictionaryForBenchmark:
						    variableDependencyBenchmark).
				   #hybrid -> (self dictionaryForBenchmark: variableHybridBenchmark) }) }

]

{ #category : 'accessing' }
CooHistoryExperimentResult >> commitCount [

	^ commitCount
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> commitCount: anObject [

	commitCount := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> comparisonDescription [

	^ comparisonDescription
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> comparisonDescription: anObject [

	comparisonDescription := anObject
]

{ #category : 'converting' }
CooHistoryExperimentResult >> dictionaryForBenchmark: aBenchmark [

	aBenchmark ifNil: [ ^ nil ].
	^ Dictionary newFrom: {
		  #name -> aBenchmark name.
		  #mrr -> aBenchmark mmr.
		  #prefixes -> (Dictionary newFrom:
				   ((2 to: 8) collect: [ :prefix |
					    prefix -> (aBenchmark mmrForPrefixSize: prefix) ])).
		  #matchedCallsites -> ((aBenchmark respondsTo: #matchedCallsites)
				   ifTrue: [ aBenchmark matchedCallsites ]
				   ifFalse: [ nil ]).
		  #scannedMethods -> ((aBenchmark respondsTo: #scannedMethods)
				   ifTrue: [ aBenchmark scannedMethods ]
				   ifFalse: [ nil ]) }
]

{ #category : 'converting' }
CooHistoryExperimentResult >> filename [

	^ projectName asLowercase copyReplaceAll: ' ' with: '-'
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageBaselineBenchmark [

	^ messageBaselineBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageBaselineBenchmark: aBenchmark [

	messageBaselineBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageBaselineValues [

	^ self valuesForBenchmark: messageBaselineBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyBenchmark [

	^ messageDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyBenchmark: anObject [

	messageDependencyBenchmark := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyValues [

	messageDependencyBenchmark ifNil: [ ^ #() ].
	^ self valuesForBenchmark: messageDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHistoryBenchmark [

	^ messageHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHistoryBenchmark: anObject [

	messageHistoryBenchmark := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHistoryValues [

	^ self valuesForBenchmark: messageHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHybridBenchmark [

	^ messageHybridBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHybridBenchmark: aBenchmark [

	messageHybridBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHybridValues [

	^ self valuesForBenchmark: messageHybridBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHybridBenchmark [

	^ messageHybridBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHybridBenchmark: aBenchmark [

	messageHybridBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHybridValues [

	^ self valuesForBenchmark: messageHybridBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageSemanticBenchmark [

    ^ messageSemanticBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageSemanticBenchmark: aBenchmark [

    messageSemanticBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageSemanticValues [

    messageSemanticBenchmark ifNil: [ ^ #() ].

    ^ self valuesForBenchmark: messageSemanticBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> projectName [

	^ projectName
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> projectName: anObject [

	projectName := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> repository [

	^ repository
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> repository: anObject [

	repository := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> statistics [

	^ statistics
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> statistics: anObject [

	statistics := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> valuesForBenchmark: aBenchmark [

	aBenchmark ifNil: [ ^ #() ].
	^ (2 to: 8) collect: [ :prefix |
		  aBenchmark mmrForPrefixSize: prefix ]
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableBaselineBenchmark [

	^ variableBaselineBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableBaselineBenchmark: aBenchmark [

	variableBaselineBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableBaselineValues [

	^ self valuesForBenchmark: variableBaselineBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyBenchmark [

	^ variableDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyBenchmark: anObject [

	variableDependencyBenchmark := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyValues [

	variableDependencyBenchmark ifNil: [ ^ #() ].
	^ self valuesForBenchmark: variableDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryBenchmark [

	^ variableHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryBenchmark: anObject [

	variableHistoryBenchmark := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryValues [

	variableHistoryBenchmark ifNil: [ ^ #() ].
	^ self valuesForBenchmark: variableHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHybridBenchmark [

	^ variableHybridBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHybridBenchmark: aBenchmark [

	variableHybridBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHybridValues [

	^ self valuesForBenchmark: variableHybridBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableSemanticBenchmark [

	^ variableSemanticBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableSemanticBenchmark: aBenchmark [

	variableSemanticBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableSemanticValues [

	variableSemanticBenchmark ifNil: [ ^ #() ].
	^ self valuesForBenchmark: variableSemanticBenchmark
]
