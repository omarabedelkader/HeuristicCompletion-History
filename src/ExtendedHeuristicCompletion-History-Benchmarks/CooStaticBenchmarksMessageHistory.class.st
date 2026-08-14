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
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> deltaMessageSelectors [

	| entries |
	entries := self session programEntityHandler selectorEntries ifNil: [ #(  ) ].
	^ ((entries flatCollect: [ :each | each deltaMessages ])
		   select: [ :each | self shouldBenchmarkMessageSelector: each ]) asSet
]

{ #category : 'running' }
CooStaticBenchmarksMessageHistory >> run [

	| cachedSelectors pos scannedMethods matchedCallsites |
	cachedSelectors := self deltaMessageSelectors.
	scannedMethods := 0.
	matchedCallsites := 0. "we should look for the methods that are in the history and not in the package.
	Because the bench is simulating a dev behavior. We are only interested in added, modified methods. "

	Transcript
		cr;
		show: '# Running Message Benchmark'; cr.

	self session existingMethods do: [ :method |
			scannedMethods := scannedMethods + 1.
			method parseTree ifNotNil: [ :parseTree |
					parseTree nodesDo: [ :node |
							(node isMessage and: [
								 (cachedSelectors includes: node selector) and: [
									 self shouldBenchmarkMessageSelector: node selector ] ]) ifTrue: [
									Transcript
										cr;
										show: '## Benched messages: ';
										show: node selector;
										space.
									matchedCallsites := matchedCallsites + 1.
									pos := node selectorInterval ifNil: [ node start ] ifNotNil: [ :interval | interval first ].
									self benchCallsite: node atPosition: pos ] ] ] ]
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
