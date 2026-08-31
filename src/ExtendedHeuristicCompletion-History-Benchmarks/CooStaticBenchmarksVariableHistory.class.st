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
		'session',
		'scannedMethods',
		'matchedCallsites'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> cachedClassNames [

	| entries |
	entries := self session programEntityHandler classEntries ifNil: [ #(  ) ].
	^ (entries collect: [ :each | each contents ]) asSet
]

{ #category : 'running' }
CooStaticBenchmarksVariableHistory >> methodsInScopeDo: aBlock [

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
CooStaticBenchmarksVariableHistory >> run [

	| cachedClassNames |
	cachedClassNames := self cachedClassNames.
	scannedMethods := 0.
	matchedCallsites := 0.

	Transcript
		cr;
		show: '# Running Variable Benchmark';
		cr.
	self session existingMethods do: [ :method |
			scannedMethods := scannedMethods + 1.
			method parseTree ifNotNil: [ :parseTree |
					parseTree nodesDo: [ :node |
							(node isVariable and: [ node name first isUppercase and: [ cachedClassNames includes: node name ] ]) ifTrue: [
									Transcript
										cr;
										show: '## Benched class: ';
										show: node name;
										cr.

									matchedCallsites := matchedCallsites + 1.
									self benchCallsite: node atPosition: node start ] ] ] ]
	.
	^ self
]

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> session [ 
	^ session ifNil: [ CooSession current ]
]

{ #category : 'benchmarks' }
CooStaticBenchmarksVariableHistory >> session: aSession [

	session := aSession
]

{ #category : 'accessing' }
CooStaticBenchmarksVariableHistory >> matchedCallsites [

	^ matchedCallsites ifNil: [ 0 ]
]

{ #category : 'accessing' }
CooStaticBenchmarksVariableHistory >> scannedMethods [

	^ scannedMethods ifNil: [ 0 ]
]
