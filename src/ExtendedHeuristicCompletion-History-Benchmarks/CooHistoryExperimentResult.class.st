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
		'dependencyConfigurationName',
		'comparisonDescription'
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
		  #dependencyConfiguration -> dependencyConfigurationName.
		  #comparison -> comparisonDescription.
		  #statistics -> statistics asDictionary.
		  #messages -> (Dictionary newFrom: {
				   #history -> (self dictionaryForBenchmark: messageHistoryBenchmark).
				   #completeDirectDependency -> (self dictionaryForBenchmark:
						    messageDependencyBenchmark) }).
		  #variables -> (Dictionary newFrom: {
				   #history -> (self dictionaryForBenchmark: variableHistoryBenchmark).
				   #completeDirectDependency -> (self dictionaryForBenchmark:
						    variableDependencyBenchmark) }) }

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

{ #category : 'accessing' }
CooHistoryExperimentResult >> dependencyConfigurationName [

	^ dependencyConfigurationName
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> dependencyConfigurationName: anObject [

	dependencyConfigurationName := anObject
]

{ #category : 'converting' }
CooHistoryExperimentResult >> dictionaryForBenchmark: aBenchmark [

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
CooHistoryExperimentResult >> messageDependencyBenchmark [

	^ messageDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyBenchmark: anObject [

	messageDependencyBenchmark := anObject
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
CooHistoryExperimentResult >> variableDependencyBenchmark [

	^ variableDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyBenchmark: anObject [

	variableDependencyBenchmark := anObject
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryBenchmark [

	^ variableHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryBenchmark: anObject [

	variableHistoryBenchmark := anObject
]
