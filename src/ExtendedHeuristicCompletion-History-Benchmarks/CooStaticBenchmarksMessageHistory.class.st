"
I benchmark message completions while replaying a repository history.

I evaluate only the dev-relevant callsites exposed by the session (CooSession):
	- methods modified by the current commit contribute their changed call sites,
	- methods added by the current commit contribute all their message sends.
Selectors are filtered against the session history (see
#shouldBenchmarkMessageSelector:).
"
Class {
	#name : 'CooStaticBenchmarksMessageHistory',
	#superclass : 'CooStaticBenchmarksMessage',
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
CooStaticBenchmarksMessageHistory >> benchCallsite: aMessageNode atPosition: aPosition [
	"As in my superclass, and every completion is also written to the call site log."

	| originalSelector |
	originalSelector := aMessageNode selectorNode value.
	2 to: (self maxPrefixSizeFor: originalSelector) do: [ :index |
		| prefix startTime startMemory completion candidates completionIndex |
		startTime := self startTimeMeasurement.
		startMemory := self startMemoryMeasurement.
		prefix := self extractPrefixFrom: originalSelector at: index.
		aMessageNode selectorNode value: prefix.
		completion := self buildCompletionFor: aMessageNode atPosition: aPosition.
		candidates := self fetchTopCandidatesFrom: completion usingPrefix: prefix.
		completionIndex := self findCompletionIndexFor: originalSelector inCandidates: candidates.
		self trackCompletionResultsFor: originalSelector atIndex: completionIndex withPrefix: prefix.
		log ifNotNil: [
			log
				recordKind: #message
				strategy: self name
				node: aMessageNode
				target: originalSelector
				prefix: prefix size
				rank: completionIndex
				milliseconds: Time millisecondClockValue - startTime ].
		self logMemoryUsageSince: startMemory forPrefixSize: prefix size.
		self logExecutionTimeSince: startTime forPrefixSize: prefix size ].
	aMessageNode selectorNode value: originalSelector
]

{ #category : 'accessing' }
CooStaticBenchmarksMessageHistory >> log: aCallsiteLog [

	log := aCallsiteLog
]

{ #category : 'accessing' }
CooStaticBenchmarksMessageHistory >> matchedCallsites [

	^ matchedCallsites ifNil: [ 0 ]
]

{ #category : 'running' }
CooStaticBenchmarksMessageHistory >> run [
	
	"we should look for the methods that are in the history and not in the package.
	Because the bench is simulating a dev behavior. We are only interested in added, modified methods. 
	More precisely
		for modified methods;
			we should bench only sites that got modified (this is to simulate the dev behavior)
		for added methods:
			we should bench all call sites"
	
	| pos |
	"Counters accumulate over all the replayed commits."
	scannedMethods := self scannedMethods.
	matchedCallsites := self matchedCallsites.
	
	Transcript cr; show: '# Running Message Benchmark ', self class name.
	
	self session modifiedMethodsAndDescriptions do: [ :methodAndDescription |
			| method description |
			method := methodAndDescription key.
			description := methodAndDescription value.
			
			scannedMethods := scannedMethods + 1.
			log ifNotNil: [ log method: method ].
			method parseTree ifNotNil: [ :parseTree |
					parseTree nodesDo: [ :node |
							(node isMessage and: [
								 (description deltaMessages includes: node selector) and: [
									 self shouldBenchmarkMessageSelector: node selector ] ]) ifTrue: [
									Transcript
										cr; show: '## Benched modified method: ', method selector, ' for message: ';
										show: node selector; space.
									matchedCallsites := matchedCallsites + 1.
									
									pos := node selectorInterval 
										ifNil: [ node start ] ifNotNil: [ :interval | interval first ].
									self benchCallsite: node atPosition: pos ] ] ] ].
					
	"Here we do not need the descriptions because we should scan all the nodes"	
	self session addedMethods do: [ :method |
			scannedMethods := scannedMethods + 1.
			log ifNotNil: [ log method: method ].
			method parseTree ifNotNil: [ :parseTree |
					parseTree nodesDo: [ :node |
							(node isMessage and: [ self shouldBenchmarkMessageSelector: node selector ]) ifTrue: [
									Transcript
										cr; show: '## Bench added method: ', method selector, 'for message: ';
										show: node selector; space.
									matchedCallsites := matchedCallsites + 1.
									pos := node selectorInterval ifNil: [ node start ] ifNotNil: [ :interval | interval first ].
									self benchCallsite: node atPosition: pos ] ] ] ].
	^ self
]

{ #category : 'accessing' }
CooStaticBenchmarksMessageHistory >> scannedMethods [

	^ scannedMethods ifNil: [ 0 ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> session [

	^ session ifNil: [ CooSession current ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> session: aSession [

	session := aSession
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> shouldBenchmarkMessageSelector: aSelector [

	^ (CooMethodHistoryItem isMessageCompletionSelector: aSelector)
		  and: [ aSelector asString size >= 2 ]
]
