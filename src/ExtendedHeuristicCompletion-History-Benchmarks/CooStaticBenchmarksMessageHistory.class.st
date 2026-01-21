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
	^ (entries collect: [ :each | each contents ]) asSet
]

{ #category : 'running' }
CooStaticBenchmarksMessageHistory >> run [

	| cachedSelectors |
	cachedSelectors := self cachedSelectors.
	scope methodsDo: [ :method |
		method parseTree nodesDo: [ :node |
			(node isMessage and: [ cachedSelectors includes: node selector ])
				ifTrue: [
					self benchCallsite: node atPosition: node keywordsIntervals first ] ] ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> session [

	^ session ifNil: [ CooSession current ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> session: aSession [

	session := aSession
]
