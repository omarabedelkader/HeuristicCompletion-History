"
A benchmarks message completions for selectors
that are present in the current session cache. This narrows the benchmark scope
so it only evaluates completions for selectors that have been modified and
stored in the cache.
"
Class {
	#name : 'CooStaticBenchmarksMessageHistory',
	#superclass : 'CooStaticBenchmarksMessage',
	#instVars : [
		'selectorCache',
		'session',
		'scannedMethods',
		'matchedCallsites'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> deltaMessageSelectors [

	| entries |
	self halt.
	entries := self session programEntityHandler selectorEntries ifNil: [ #(  ) ].
	^ ((entries flatCollect: [ :each | each deltaMessages ])
		   select: [ :each | self shouldBenchmarkMessageSelector: each ]) asSet
]

{ #category : 'accessing' }
CooStaticBenchmarksMessageHistory >> matchedCallsites [

	^ matchedCallsites ifNil: [ 0 ]
]

{ #category : 'running' }
CooStaticBenchmarksMessageHistory >> run [

	| pos |
	scannedMethods := 0.
	matchedCallsites := 0.
	
	"we should look for the methods that are in the history and not in the package.
	Because the bench is simulating a dev behavior. We are only interested in added, modified methods. 
	More precisely
		for modified methods;
			we should bench only sites that got modified (this is to simulate the dev behavior)
		for added methods:
			we should bench all call sites
	"

	Transcript
		cr;
		show: '# Running Message Benchmark'; cr.

	self session modifiedMethods do: [ :method |
			scannedMethods := scannedMethods + 1.
			method parseTree ifNotNil: [ :parseTree |
					parseTree nodesDo: [ :node |
							(node isMessage and: [
								 (self deltaMessageSelectors includes: node selector) and: [
									 self shouldBenchmarkMessageSelector: node selector ] ]) ifTrue: [
									Transcript
										cr;
										show: '## Benched modified messages: ';
										show: node selector;
										space.
									matchedCallsites := matchedCallsites + 1.
									pos := node selectorInterval ifNil: [ node start ] ifNotNil: [ :interval | interval first ].
									self benchCallsite: node atPosition: pos ] ] ] ].
	self session addedMethods do: [ :method |
			scannedMethods := scannedMethods + 1.
			method parseTree ifNotNil: [ :parseTree |
					parseTree nodesDo: [ :node |
							(node isMessage and: [ self shouldBenchmarkMessageSelector: node selector ]) ifTrue: [
									Transcript
										cr;
										show: '## Bench added messages: ';
										show: node selector;
										space.
									matchedCallsites := matchedCallsites + 1.
									pos := node selectorInterval ifNil: [ node start ] ifNotNil: [ :interval | interval first ].
									self benchCallsite: node atPosition: pos ] ] ] ]				
	.
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
