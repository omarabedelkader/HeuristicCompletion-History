"
I collect repository, replayed history, and benchmark-population counts for an experiment.
"
Class {
	#name : 'CooHistoryProjectStatistics',
	#superclass : 'Object',
	#instVars : [
		'projectName',
		'packageCount',
		'classCount',
		'methodCount',
		'historyCommitCount',
		'historyMethodCount',
		'historyClassCount',
		'addedMethods',
		'modifiedMethods',
		'removedMethods',
		'addedClasses',
		'modifiedClasses',
		'removedClasses',
		'messageCallsites',
		'variableCallsites',
		'uniqueHistorySelectors',
		'uniqueHistoryClasses'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'accessing' }
CooHistoryProjectStatistics >> addedClasses [

	^ addedClasses
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> addedClasses: anInteger [

	addedClasses := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> addedMethods [

	^ addedMethods
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> addedMethods: anInteger [

	addedMethods := anInteger
]

{ #category : 'converting' }
CooHistoryProjectStatistics >> asDictionary [

	^ Dictionary newFrom: {
		  #project -> projectName.
		  #packages -> packageCount.
		  #classes -> classCount.
		  #methods -> methodCount.
		  #historyCommits -> historyCommitCount.
		  #historyMethods -> historyMethodCount.
		  #historyClasses -> historyClassCount.
		  #addedMethods -> addedMethods.
		  #modifiedMethods -> modifiedMethods.
		  #removedMethods -> removedMethods.
		  #addedClasses -> addedClasses.
		  #modifiedClasses -> modifiedClasses.
		  #removedClasses -> removedClasses.
		  #messageCallsites -> messageCallsites.
		  #variableCallsites -> variableCallsites.
		  #uniqueHistorySelectors -> uniqueHistorySelectors.
		  #uniqueHistoryClasses -> uniqueHistoryClasses }
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> classCount [

	^ classCount
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> classCount: anInteger [

	classCount := anInteger
]

{ #category : 'private' }
CooHistoryProjectStatistics >> classesIn: aPackage [

	(aPackage respondsTo: #definedClasses)
		ifTrue: [ ^ aPackage definedClasses ].
	^ #(  )
]

{ #category : 'collecting' }
CooHistoryProjectStatistics >> collectHistoryStatisticsFrom: aSession [

	| methodItems classItems classNames selectors |
	methodItems := aSession methodDescriptions.
	classItems := aSession classDescriptions.

	historyMethodCount := methodItems size.
	historyClassCount := classItems size.

	addedMethods := self countEvent: #added in: methodItems.
	modifiedMethods := self countEvent: #modified in: methodItems.
	removedMethods := self countEvent: #removed in: methodItems.

	addedClasses := self countEvent: #added in: classItems.
	modifiedClasses := self countEvent: #modified in: classItems.
	removedClasses := self countEvent: #removed in: classItems.

	selectors := (methodItems collect: [ :each | each selector ])
		             select: [ :each | each notNil ].
	uniqueHistorySelectors := selectors asSet size.

	classNames := OrderedCollection new.
	methodItems do: [ :each |
		each nameOfClass ifNotNil: [ :className |
			classNames add: className ] ].
	classItems do: [ :each |
		each nameOfClass ifNotNil: [ :className |
			classNames add: className ] ].
	uniqueHistoryClasses := classNames asSet size
]

{ #category : 'collecting' }
CooHistoryProjectStatistics >> collectRepositoryStatisticsFrom: aConfiguration [

	| packages classes methods |
	projectName := aConfiguration name.
	packages := aConfiguration packages.
	classes := (packages flatCollect: [ :package | self classesIn: package ]) asSet.
	methods := (packages flatCollect: [ :package | self methodsIn: package ]) asSet.

	packageCount := packages size.
	classCount := classes size.
	methodCount := methods size
]

{ #category : 'private' }
CooHistoryProjectStatistics >> countEvent: aSymbol in: aCollection [

	^ (aCollection select: [ :each |
		   (each respondsTo: #event) and: [ each event = aSymbol ] ]) size
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> historyClassCount [

	^ historyClassCount
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> historyClassCount: anInteger [

	historyClassCount := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> historyCommitCount [

	^ historyCommitCount
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> historyCommitCount: anInteger [

	historyCommitCount := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> historyMethodCount [

	^ historyMethodCount
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> historyMethodCount: anInteger [

	historyMethodCount := anInteger
]

{ #category : 'initialization' }
CooHistoryProjectStatistics >> initialize [

	super initialize.
	packageCount := 0.
	classCount := 0.
	methodCount := 0.
	historyCommitCount := 0.
	historyMethodCount := 0.
	historyClassCount := 0.
	addedMethods := 0.
	modifiedMethods := 0.
	removedMethods := 0.
	addedClasses := 0.
	modifiedClasses := 0.
	removedClasses := 0.
	messageCallsites := 0.
	variableCallsites := 0.
	uniqueHistorySelectors := 0.
	uniqueHistoryClasses := 0
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> messageCallsites [

	^ messageCallsites
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> messageCallsites: anInteger [

	messageCallsites := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> methodCount [

	^ methodCount
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> methodCount: anInteger [

	methodCount := anInteger
]

{ #category : 'private' }
CooHistoryProjectStatistics >> methodsIn: aPackage [

	| methods |
	(aPackage respondsTo: #methods)
		ifTrue: [ ^ aPackage methods ].

	methods := OrderedCollection new.
	(aPackage respondsTo: #methodsDo:)
		ifTrue: [
			aPackage methodsDo: [ :method |
				methods add: method ] ].
	^ methods
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> modifiedClasses [

	^ modifiedClasses
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> modifiedClasses: anInteger [

	modifiedClasses := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> modifiedMethods [

	^ modifiedMethods
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> modifiedMethods: anInteger [

	modifiedMethods := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> packageCount [

	^ packageCount
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> packageCount: anInteger [

	packageCount := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> projectName [

	^ projectName
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> projectName: aString [

	projectName := aString
]

{ #category : 'collecting' }
CooHistoryProjectStatistics >> recordBenchmarkPopulationFromMessageBenchmark: messageBenchmark variableBenchmark: variableBenchmark [

	(messageBenchmark notNil and: [
		 messageBenchmark respondsTo: #matchedCallsites ])
		ifTrue: [ messageCallsites := messageBenchmark matchedCallsites ].

	(variableBenchmark notNil and: [
		 variableBenchmark respondsTo: #matchedCallsites ])
		ifTrue: [ variableCallsites := variableBenchmark matchedCallsites ]
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> removedClasses [

	^ removedClasses
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> removedClasses: anInteger [

	removedClasses := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> removedMethods [

	^ removedMethods
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> removedMethods: anInteger [

	removedMethods := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> uniqueHistoryClasses [

	^ uniqueHistoryClasses
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> uniqueHistoryClasses: anInteger [

	uniqueHistoryClasses := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> uniqueHistorySelectors [

	^ uniqueHistorySelectors
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> uniqueHistorySelectors: anInteger [

	uniqueHistorySelectors := anInteger
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> variableCallsites [

	^ variableCallsites
]

{ #category : 'accessing' }
CooHistoryProjectStatistics >> variableCallsites: anInteger [

	variableCallsites := anInteger
]
