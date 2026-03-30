"
```
CooHistoryBenchmarksRunner
  runWithSession: CooSession current
  scope: (Package named: 'Spec2').
```


```
CooHistoryBenchmarksRunner run.
```
"
Class {
	#name : 'CooHistoryBenchmarksRunner',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> newRunWithSession: aSession [ 
	"Run benchmarks with a specific session and scope.
	Example: CooHistoryBenchmarksRunner runWithSession: CooSession current scope: (RPackage named: 'Kernel')"

	"CooHistoryBenchmarksRunner 
		newRunWithSession: CooSession current )"

	| populator messageBenchmark variableBenchmark |
	"fill up the history"
	populator := HistoryCachePopulator repo: 'git@github.com:Ducasse/Comix2.git'.
	populator populateForBenchmarkCommit: 10.


	messageBenchmark := CooStaticBenchmarksMessageHistory new
		                    session: aSession;
		                    yourself.
	variableBenchmark := CooStaticBenchmarksVariableHistory new
		                     session: aSession;
		                     yourself.
	messageBenchmark run.
	variableBenchmark run.

	^ {
		  messageBenchmark.
		  variableBenchmark } inspect
]

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
	scope := CoBenchmarkModifiedMethods fromSession: aSession.
	^ self runWithSession: aSession scope: scope
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runWithSession: aSession [

	^ self runBenchmarksWithSession: aSession
]

{ #category : 'running' }
CooHistoryBenchmarksRunner class >> runWithSession: aSession scope: aScope [
	"Run benchmarks with a specific session and scope.
	Example: CooHistoryBenchmarksRunner runWithSession: CooSession current scope: (RPackage named: 'Kernel')"

	"CooHistoryBenchmarksRunner 
		runWithSession: CooSession current 
		scope: (PackageOrganizer default packageNamed: 'Comix')"

	| populator messageBenchmark variableBenchmark scopeName |
	"fill up the history"
	populator := HistoryCachePopulator repo: 'git@github.com:Ducasse/Comix2.git'.
	populator populateForBenchmarkCommit: 10.


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
		  variableBenchmark } inspect
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
