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
		'matchedCallsites'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'accessing' }
CooStaticBenchmarksVariableHistory >> matchedCallsites [

	^ matchedCallsites ifNil: [ 0 ]
]

{ #category : 'running' }
CooStaticBenchmarksVariableHistory >> run [

	scannedMethods := 0.
	matchedCallsites := 0.

	Transcript 
		cr; cr;
		show: '# Running Variable Benchmark '; 
		show: self session addedAndModifiedMethods size printString; cr.
		
		self session addedAndModifiedMethods do: [ :method |
		
			scannedMethods := scannedMethods + 1.
			method parseTree ifNotNil: [ :parseTree |
				parseTree nodesDo: [ :node |
							(node isVariable and: [ node name first isUppercase ]) 
								ifTrue: [
									node name = 'Dictionary' ifTrue: [ self halt. ].
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
