"
I write the raw observations of a History experiment, one line per observation, so that the
analysis can be done outside of Pharo (see scripts/analyze_history_benchmarks.py).

- <project>-callsites.csv: one line per benchmarked call site, with where its expected token
  could come from: the history snapshot, the package of the call site, or one of the packages
  it depends on.
- <project>-ranks.csv: one line per call site, strategy and prefix size, with the rank of the
  expected token in the first ten proposals (0 when absent) and the completion time.

The benchmarks of every strategy scan the same call sites in the same order, so a call site is
identified by its commit, method, position and expected token and described the first time it is seen.
"
Class {
	#name : 'CooCallsiteLog',
	#superclass : 'Object',
	#instVars : [
		'callsitesStream',
		'ranksStream',
		'history',
		'commitId',
		'commitIndex',
		'method',
		'describedCallsites',
		'packageSelectors',
		'packageClassNames'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'instance creation' }
CooCallsiteLog class >> on: aDirectory project: aFilename history: aHistorySnapshot [

	^ self new
		  openOn: aDirectory asFileReference project: aFilename;
		  history: aHistorySnapshot;
		  yourself
]

{ #category : 'private' }
CooCallsiteLog >> classNamesOfPackageNamed: aPackageName [

	^ packageClassNames at: aPackageName ifAbsentPut: [
		  (self packageOrganizer packageNamed: aPackageName ifAbsent: [ nil ])
			  ifNil: [ Set new ]
			  ifNotNil: [ :package | (package definedClasses collect: [ :each | each name ]) asSet ] ]
]

{ #category : 'closing' }
CooCallsiteLog >> close [

	callsitesStream ifNotNil: [ :stream | stream close ].
	ranksStream ifNotNil: [ :stream | stream close ].
	callsitesStream := ranksStream := nil
]

{ #category : 'accessing' }
CooCallsiteLog >> commit: aCommit index: anInteger [
	"The packages change with every commit: what they define must be computed again."

	commitId := aCommit shortId.
	commitIndex := anInteger.
	describedCallsites := Set new.
	packageSelectors := Dictionary new.
	packageClassNames := Dictionary new
]

{ #category : 'private' }
CooCallsiteLog >> dependenciesOfPackageNamed: aPackageName [

	^ [ CoAbstractPackageDependencyFetcher dependenciesOf: aPackageName ]
		  on: Error
		  do: [ #(  ) ]
]

{ #category : 'recording' }
CooCallsiteLog >> describeCallsite: anId kind: aKind node: aNode target: aSymbol [

	| packageName inHistory inOwnPackage inDependency |
	packageName := method package ifNotNil: [ :package | package name ].
	aKind = #message
		ifTrue: [
			inHistory := history includesSelector: aSymbol.
			inOwnPackage := packageName notNil and: [
				                (self selectorsOfPackageNamed: packageName) includes: aSymbol ].
			inDependency := packageName notNil and: [
				                (self dependenciesOfPackageNamed: packageName) anySatisfy: [ :each |
					                (self selectorsOfPackageNamed: each) includes: aSymbol ] ] ]
		ifFalse: [
			inHistory := history includesClassName: aSymbol.
			inOwnPackage := packageName notNil and: [
				                (self classNamesOfPackageNamed: packageName) includes: aSymbol ].
			inDependency := packageName notNil and: [
				                (self dependenciesOfPackageNamed: packageName) anySatisfy: [ :each |
					                (self classNamesOfPackageNamed: each) includes: aSymbol ] ] ].
	self
		writeRow: {
				aKind.
				anId.
				commitIndex.
				commitId.
				(packageName ifNil: [ '' ]).
				method methodClass name.
				method selector.
				aSymbol.
				(self receiverKindOf: aNode kind: aKind).
				inHistory.
				inOwnPackage.
				inDependency.
				history selectors size.
				history classNames size }
		on: callsitesStream
]

{ #category : 'accessing' }
CooCallsiteLog >> history: aHistorySnapshot [

	history := aHistorySnapshot
]

{ #category : 'recording' }
CooCallsiteLog >> idFor: aNode target: aSymbol [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: commitId;
			  nextPut: $|;
			  nextPutAll: method methodClass name;
			  nextPutAll: '>>';
			  nextPutAll: method selector;
			  nextPut: $@;
			  print: aNode start;
			  nextPut: $|;
			  nextPutAll: aSymbol ]
]

{ #category : 'accessing' }
CooCallsiteLog >> method: aCompiledMethod [

	method := aCompiledMethod
]

{ #category : 'initialization' }
CooCallsiteLog >> openOn: aDirectory project: aFilename [

	| callsitesFile ranksFile |
	aDirectory ensureCreateDirectory.
	callsitesFile := aDirectory / (aFilename , '-callsites.csv').
	ranksFile := aDirectory / (aFilename , '-ranks.csv').
	callsitesFile ensureDelete.
	ranksFile ensureDelete.
	callsitesStream := callsitesFile writeStream.
	ranksStream := ranksFile writeStream.
	self
		writeRow: #( kind id commit_index commit package class method target receiver in_history in_own_package in_dependency history_selectors history_classes )
		on: callsitesStream.
	self writeRow: #( kind strategy id prefix rank ms ) on: ranksStream
]

{ #category : 'private' }
CooCallsiteLog >> packageOrganizer [

	^ self class environment organization
]

{ #category : 'private' }
CooCallsiteLog >> receiverKindOf: aNode kind: aKind [

	| receiver |
	aKind = #message ifFalse: [ ^ #global ].
	receiver := aNode receiver.
	receiver isSelfVariable ifTrue: [ ^ #self ].
	receiver isSuperVariable ifTrue: [ ^ #super ].
	receiver isLiteralNode ifTrue: [ ^ #literal ].
	receiver isVariable ifTrue: [
		^ receiver name first isUppercase
			  ifTrue: [ #global ]
			  ifFalse: [ #variable ] ].
	^ #expression
]

{ #category : 'recording' }
CooCallsiteLog >> recordKind: aKind strategy: aStrategyName node: aNode target: aSymbol prefix: aPrefixSize rank: aRank milliseconds: aDuration [

	| id |
	id := self idFor: aNode target: aSymbol.
	(describedCallsites includes: id) ifFalse: [
		describedCallsites add: id.
		self describeCallsite: id kind: aKind node: aNode target: aSymbol ].
	self
		writeRow: {
				aKind.
				aStrategyName.
				id.
				aPrefixSize.
				aRank.
				aDuration }
		on: ranksStream
]

{ #category : 'private' }
CooCallsiteLog >> selectorsOfPackageNamed: aPackageName [

	^ packageSelectors at: aPackageName ifAbsentPut: [
		  (self packageOrganizer packageNamed: aPackageName ifAbsent: [ nil ])
			  ifNil: [ Set new ]
			  ifNotNil: [ :package | (package methods collect: [ :each | each selector ]) asSet ] ]
]

{ #category : 'private' }
CooCallsiteLog >> writeRow: aCollection on: aStream [

	aCollection
		do: [ :each |
			| string |
			string := each asString.
			((string includes: $,) or: [ (string includes: $") or: [ string includes: Character lf ] ])
				ifTrue: [
					aStream
						nextPut: $";
						nextPutAll: (string copyReplaceAll: '"' with: '""');
						nextPut: $" ]
				ifFalse: [ aStream nextPutAll: string ] ]
		separatedBy: [ aStream nextPut: $, ].
	aStream lf
]
