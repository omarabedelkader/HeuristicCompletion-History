"
I hold the complete in-memory outcome of one History experiment.
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
		'dependencyConfigurationName',
		'comparisonDescription'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
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
CooHistoryExperimentResult >> commitCount: anInteger [

	commitCount := anInteger
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> comparisonDescription [

	^ comparisonDescription
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> comparisonDescription: aString [

	comparisonDescription := aString
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> dependencyConfigurationName [

	^ dependencyConfigurationName
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> dependencyConfigurationName: aString [

	dependencyConfigurationName := aString
]

{ #category : 'private' }
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

{ #category : 'accessing' }
CooHistoryExperimentResult >> fileStem [

	^ projectName asLowercase copyReplaceAll: ' ' with: '-'
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyBenchmark [

	^ messageDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyBenchmark: aBenchmark [

	messageDependencyBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageDependencyValues [

	^ self valuesForBenchmark: messageDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHistoryBenchmark [

	^ messageHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHistoryBenchmark: aBenchmark [

	messageHistoryBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> messageHistoryValues [

	^ self valuesForBenchmark: messageHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> projectName [

	^ projectName
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> projectName: aString [

	projectName := aString
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> repository [

	^ repository
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> repository: aString [

	repository := aString
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> statistics [

	^ statistics
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> statistics: aCooHistoryProjectStatistics [

	statistics := aCooHistoryProjectStatistics
]

{ #category : 'private' }
CooHistoryExperimentResult >> valuesForBenchmark: aBenchmark [

	^ (2 to: 8) collect: [ :prefix |
		  aBenchmark mmrForPrefixSize: prefix ]
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyBenchmark [

	^ variableDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyBenchmark: aBenchmark [

	variableDependencyBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableDependencyValues [

	^ self valuesForBenchmark: variableDependencyBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryBenchmark [

	^ variableHistoryBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryBenchmark: aBenchmark [

	variableHistoryBenchmark := aBenchmark
]

{ #category : 'accessing' }
CooHistoryExperimentResult >> variableHistoryValues [

	^ self valuesForBenchmark: variableHistoryBenchmark
]
