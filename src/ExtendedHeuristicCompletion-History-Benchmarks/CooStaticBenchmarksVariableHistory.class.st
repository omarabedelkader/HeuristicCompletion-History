"
I benchmark variable (capitalized class name) completions while replaying a
repository history.

I scan the current session methods and bench the uppercase variable nodes whose
name is present in the session cache (the classes already seen by the
programEntityHandler). This restricts the benchmark to the studied globals,
mirroring the message benchmark which only targets modified and added methods.
"
Class {
	#name : 'CooStaticBenchmarksVariableHistory',
	#superclass : 'CooStaticBenchmarksVariables',
	#instVars : [
		'selectorCache',
		'session',
		'scannedMethods',
		'matchedCallsites',
		'log'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> benchCallsite: aVariable atPosition: aPosition [
	"As in my superclass, and every completion is also written to the call site log."

	| oldName |
	oldName := aVariable name.
	2 to: (self maxPrefixSizeFor: aVariable) do: [ :index |
		| prefix startTime startMemory completion candidates completionIndex |
		startTime := self startTimeMeasurement.
		startMemory := self startMemoryMeasurement.
		prefix := self extractPrefixFrom: oldName at: index.
		aVariable name: prefix.
		completion := self buildCompletionFor: aVariable atPosition: aPosition.
		candidates := self fetchTopCandidatesFrom: completion usingPrefix: prefix.
		completionIndex := self findCompletionIndexFor: oldName inCandidates: candidates.
		self trackCompletionResultsFor: oldName atIndex: completionIndex withPrefix: prefix.
		log ifNotNil: [
			log
				recordKind: #variable
				strategy: self name
				node: aVariable
				target: oldName asSymbol
				prefix: prefix size
				rank: completionIndex
				milliseconds: Time millisecondClockValue - startTime ].
		self logMemoryUsageSince: startMemory forPrefixSize: prefix size.
		self logExecutionTimeSince: startTime forPrefixSize: prefix size ].
	aVariable name: oldName
]

{ #category : 'accessing' }
CooStaticBenchmarksVariableHistory >> log: aCallsiteLog [

	log := aCallsiteLog
]

{ #category : 'accessing' }
CooStaticBenchmarksVariableHistory >> matchedCallsites [

	^ matchedCallsites ifNil: [ 0 ]
]

{ #category : 'running' }
CooStaticBenchmarksVariableHistory >> run [

	"Counters accumulate over all the replayed commits."
	scannedMethods := self scannedMethods.
	matchedCallsites := self matchedCallsites.

	Transcript 
		cr; cr;
		show: '# Running Variable Benchmark '; 
		show: self session addedAndModifiedMethods size printString; cr.
		
		self session addedAndModifiedMethods do: [ :method |
		
			scannedMethods := scannedMethods + 1.
			log ifNotNil: [ log method: method ].
			method parseTree ifNotNil: [ :parseTree |
				parseTree nodesDo: [ :node |
							(node isVariable and: [ node name first isUppercase ]) 
								ifTrue: [
									Transcript
										cr;
										show: '## Benched class: ';	 show: node name;
										cr.

									matchedCallsites := matchedCallsites + 1.
									self benchCallsite: node atPosition: node start ] ] ] ].
	^ self
]

{ #category : 'accessing' }
CooStaticBenchmarksVariableHistory >> scannedMethods [

	^ scannedMethods ifNil: [ 0 ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> session [ 
	^ session ifNil: [ CooSession current ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> session: aSession [

	session := aSession
]
