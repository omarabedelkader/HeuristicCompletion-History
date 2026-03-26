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
CooStaticBenchmarksMessageHistory >> cachedSelectors [

	| entries |
entries := self session programEntityHandler selectorEntries
		           ifNil: [ #() ].
	^ (entries collect: [ :each | each contents asSymbol ]) asSet
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> methodsInScopeDo: aBlock [

	(scope respondsTo: #methodsDo:)
		ifTrue: [ ^ scope methodsDo: aBlock ].
	(scope respondsTo: #do:)
		ifTrue: [ ^ scope do: [ :each |
			(each respondsTo: #methodsDo:) ifTrue: [ each methodsDo: aBlock ] ] ].
	self error: 'Scope does not support method enumeration'
]

{ #category : 'running' }
CooStaticBenchmarksMessageHistory >> run [
| cachedSelectors pos |
cachedSelectors := self cachedSelectors.
self methodsInScopeDo: [ :method |
		method parseTree ifNotNil: [ :parseTree |
			parseTree nodesDo: [ :node |
				(node isMessage and: [ cachedSelectors includes: node selector ])
					ifTrue: [
						pos := node selectorInterval
							ifNil: [ node start ]
							ifNotNil: [ :interval | interval first ].
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
