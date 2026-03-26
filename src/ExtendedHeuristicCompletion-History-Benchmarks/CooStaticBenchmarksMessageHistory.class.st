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
	(scope respondsTo: #definedClasses)
		ifTrue: [ ^ scope definedClasses do: [ :class |
			class methodsDo: aBlock ] ].
	(scope respondsTo: #do:)
		ifTrue: [ ^ scope do: [ :each |
				(each respondsTo: #methodsDo:)
				ifTrue: [ each methodsDo: aBlock ]
				ifFalse: [ (each respondsTo: #definedClasses)
					ifTrue: [ each definedClasses do: [ :class | class methodsDo: aBlock ] ] ] ] ].
	self error:
		'Scope does not support method enumeration. Pass a package, class, or collection of them.'
]

{ #category : 'running' }
CooStaticBenchmarksMessageHistory >> run [

| cachedSelectors pos scannedMethods matchedCallsites |
	cachedSelectors := self cachedSelectors.
	scannedMethods := 0.
	matchedCallsites := 0.
	self methodsInScopeDo: [ :method |
		scannedMethods := scannedMethods + 1.
		method parseTree ifNotNil: [ :parseTree |
			parseTree nodesDo: [ :node |
				(node isMessage and: [ cachedSelectors includes: node selector ])
					ifTrue: [
						matchedCallsites := matchedCallsites + 1.
						pos := node selectorInterval
							ifNil: [ node start ]
							ifNotNil: [ :interval | interval first ].
						self benchCallsite: node atPosition: pos ] ] ] ].

	matchedCallsites = 0 ifTrue: [
		Transcript
			show: 'Message history benchmark found no matching callsites. Cached selectors: ';
			show: cachedSelectors size asString;
			show: ' - scanned methods: ';
			show: scannedMethods asString;
			show: '. Try a broader scope or run on modified methods.';
			cr ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> session [

	^ session ifNil: [ CooSession current ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksMessageHistory >> session: aSession [

	session := aSession
]
