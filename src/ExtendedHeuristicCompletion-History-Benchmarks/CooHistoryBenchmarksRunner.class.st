Class {
	#name : 'CooHistoryBenchmarksRunner',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> run [

	^ self runWithSession: CooSession current
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runBenchmarks [

	^ self runBenchmarksWithSession: CooSession current
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runBenchmarksWithSession: aSession [
	| scope |
	(aSession isNil or: [ aSession size = 0 ]) ifTrue: [
		Transcript
			show: 'History cache is empty. Populate caches before running benchmarks.';
			cr.
		^ self ].

	scope := PackageOrganizer default packages.

^ self runWithSession: aSession scope: scope

]

{ #category : 'as yet unclassified' }
CooHistoryBenchmarksRunner class >> runOnModifiedMethods [
	"Run benchmarks only on methods that were modified in the populated commits.
	Example: CooHistoryBenchmarksRunner runOnModifiedMethods"

	^ self runOnModifiedMethodsWithSession: CooSession current
]

{ #category : 'as yet unclassified' }
CooHistoryBenchmarksRunner class >> runOnModifiedMethodsWithSession: aSession [
	"Run benchmarks only on methods that were modified in the populated commits.
	Example: CooHistoryBenchmarksRunner runOnModifiedMethodsWithSession: CooSession current"

	| scope |
	(aSession isNil or: [ aSession size = 0 ]) ifTrue: [
		Transcript
			show: 'History cache is empty. Populate caches before running benchmarks.';
			cr.
		^ self ].

	scope := CoBenchmarkModifiedMethods fromSession: aSession.
	^ self runWithSession: aSession scope: scope
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runWithSession: aSession [

	(aSession isNil or: [ aSession size = 0 ]) ifTrue: [
		Transcript
			show: 'History cache is empty. Populate caches before running benchmarks.';
			cr.
		^ self ].

	^ self runBenchmarksWithSession: aSession
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runWithSession: aSession scope: aScope [
	"Run benchmarks with a specific session and scope.
	Example: CooHistoryBenchmarksRunner runWithSession: CooSession current scope: (RPackage named: 'Kernel')"

	| messageBenchmark variableBenchmark scopeName |
	(aSession isNil or: [ aSession size = 0 ]) ifTrue: [
			Transcript
				show: 'History cache is empty. Populate caches before running benchmarks.';
				cr.
			^ self ].

	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession;
		                    scope: aScope;
		                    yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession;
		                     scope: aScope;
		                     yourself.

	scopeName := self scopeNameFor: aScope.
	messageBenchmark run.
	variableBenchmark run.

	^ {
		  messageBenchmark.
		  variableBenchmark }
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> scopeNameFor: aScope [

	(aScope isCollection)
		ifTrue: [ ^ aScope size asString, ' items' ].
	(aScope class canUnderstand: #name)
		ifTrue: [ ^ aScope name ].
	(aScope respondsTo: #size)
		ifTrue: [ ^ aScope size asString, ' scoped elements' ].
	^ aScope class name
]
