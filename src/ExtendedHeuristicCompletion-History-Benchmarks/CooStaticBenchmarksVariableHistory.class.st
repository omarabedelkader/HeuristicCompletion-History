"
A benchmarks variable (class name) completions
for class names that are present in the current session cache. This restricts
the benchmark to cached class entries only.
"
Class {
	#name : 'CooStaticBenchmarksVariableHistory',
	#superclass : 'CooStaticBenchmarksVariables',
	#instVars : [
		'selectorCache',
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> cachedClassNames [

	| entries |
	entries := self session programEntityHandler classEntries
		           ifNil: [ #() ].
	^ (entries collect: [ :each | each contents ]) asSet
]

{ #category : 'running' }
CooStaticBenchmarksVariableHistory >> run [

	| cachedClassNames |
	cachedClassNames := self cachedClassNames.
	scope methodsDo: [ :method |
		method parseTree nodesDo: [ :node |
			(node isVariable
				and: [ node name first isUppercase
				and: [ cachedClassNames includes: node name ] ])
				ifTrue: [ self benchCallsite: node atPosition: node start ] ] ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> session [ 
	^ session ifNil: [ CooSession current ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> session: aSession [

	session := aSession
]
