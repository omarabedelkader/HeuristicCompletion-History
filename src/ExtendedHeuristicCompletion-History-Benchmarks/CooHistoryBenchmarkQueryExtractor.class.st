"
Query extraction separated from query execution.

I discover the benchmark callsites in the methods recorded by a session
history. Extraction happens once per repository (after replaying the largest
history window) and produces the canonical immutable query set shared by
every configuration and window, which keeps all treatment comparisons paired.

Benchmarkable selectors are restricted to the delta messages introduced by
history events, mirroring the scope of the original hand-run benchmark:
we simulate a developer session, so completions of interest are the
selectors and class names touched by history.

Extraction also feeds CooHistoryBenchmarkDiagnostic with everything it could
not measure: methods unresolved in the image and AST parse failures.
"
Class {
	#name : 'CooHistoryBenchmarkQueryExtractor',
	#superclass : 'Object',
	#instVars : [
		'session',
		'targets',
		'diagnostics',
		'sourceCommit',
		'cachedSelectors',
		'cachedClassNames'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Query',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Query'
}

{ #category : 'private - caches' }
CooHistoryBenchmarkQueryExtractor >> cachedClassNames [

	^ cachedClassNames
]

{ #category : 'private - caches' }
CooHistoryBenchmarkQueryExtractor >> cachedSelectorCandidates [
	"Selectors worth benchmarking: delta messages introduced by history
	events, filtered like the original hand-run benchmark."

	| entries |
	entries := session programEntityHandler selectorEntries ifNil: [ #(  ) ].
	^ ((entries flatCollect: [ :each | each deltaMessages ])
		   select: [ :each | self isValidMessageSelector: each ]) asSet
]

{ #category : 'private - caches' }
CooHistoryBenchmarkQueryExtractor >> classNamesInCache [

	| entries |
	entries := session programEntityHandler classEntries ifNil: [ #(  ) ].
	^ (entries collect: [ :each | each contents ]) asSet
]

{ #category : 'private - diagnostics' }
CooHistoryBenchmarkQueryExtractor >> countUnresolvedMethods [
	"existingMethods silently ignores history entries whose classes are not
	loaded; make that loss visible instead of losing half a dataset silently."

	| described resolved |
	described := session existingMethodDescriptions size.
	resolved := session existingMethods size.
	described > resolved ifTrue: [
		self diagnostics
			increment: #methodsUnresolvedInImage
			by: described - resolved.
		self diagnostics recordSkipReason: #methodNotLoaded ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> diagnostics [

	^ diagnostics ifNil: [ diagnostics := CooHistoryBenchmarkDiagnostic new ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> diagnostics: aDiagnostic [

	diagnostics := aDiagnostic
]

{ #category : 'extraction' }
CooHistoryBenchmarkQueryExtractor >> extract [

	| queries |
	cachedSelectors := self cachedSelectorCandidates.
	cachedClassNames := self classNamesInCache.
	queries := OrderedCollection new.
	self countUnresolvedMethods.
	session existingMethods do: [ :method |
		self extractQueriesFromMethod: method into: queries ].
	^ queries
]

{ #category : 'extraction' }
CooHistoryBenchmarkQueryExtractor >> extractFromClassNode: aNode method: aCompiledMethod into: aCollection [

	aCollection add: ((self newQueryFor: aCompiledMethod)
			 targetKind: #className;
			 expectedCandidate: aNode name;
			 astNode: aNode;
			 position: aNode start;
			 yourself)
]

{ #category : 'extraction' }
CooHistoryBenchmarkQueryExtractor >> extractFromMessageNode: aNode method: aCompiledMethod into: aCollection [

	aCollection add: ((self newQueryFor: aCompiledMethod)
			 targetKind: #selector;
			 expectedCandidate: aNode selector;
			 astNode: aNode;
			 position: (aNode selectorInterval
					  ifNil: [ aNode start ]
					  ifNotNil: [ :interval | interval first ]);
			 yourself)
]

{ #category : 'extraction' }
CooHistoryBenchmarkQueryExtractor >> extractQueriesFromMethod: aCompiledMethod into: aCollection [

	| parseTree |
	parseTree := self tryParseTreeOf: aCompiledMethod.
	parseTree ifNil: [
		self diagnostics increment: #astParseFailures.
		self diagnostics recordSkipReason: #astParseFailed.
		^ self ].
	self diagnostics increment: #astParseSuccesses.

	parseTree nodesDo: [ :node |
		self diagnostics increment: #diffNodesVisited.
		(node isMessage and: [ targets includes: #selector ]) ifTrue: [
			(cachedSelectors includes: node selector) ifTrue: [
				self extractFromMessageNode: node method: aCompiledMethod into: aCollection ] ].
		(node isVariable and: [ targets includes: #className ]) ifTrue: [
			(node name first isUppercase and: [
				 cachedClassNames includes: node name ]) ifTrue: [
				self extractFromClassNode: node method: aCompiledMethod into: aCollection ] ] ]
]

{ #category : 'initialization' }
CooHistoryBenchmarkQueryExtractor >> initialize [

	super initialize.
	targets := #( #selector #className )
]

{ #category : 'testing' }
CooHistoryBenchmarkQueryExtractor >> isValidMessageSelector: aSelector [

	^ (CooMethodHistoryItem isMessageCompletionSelector: aSelector)
		  and: [ aSelector asString size >= 2 ]
]

{ #category : 'instance creation' }
CooHistoryBenchmarkQueryExtractor >> newQueryFor: aCompiledMethod [

	^ CooHistoryBenchmarkQuery new
		  className: aCompiledMethod methodClass name;
		  methodSelector: aCompiledMethod selector;
		  sourceCommit: sourceCommit;
		  yourself
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> session [

	^ session
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> session: aSession [

	session := aSession
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> sourceCommit: aString [

	sourceCommit := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> targets [

	^ targets
]

{ #category : 'accessing' }
CooHistoryBenchmarkQueryExtractor >> targets: aCollection [

	targets := aCollection
]

{ #category : 'private - parsing' }
CooHistoryBenchmarkQueryExtractor >> tryParseTreeOf: aCompiledMethod [

	^ [ aCompiledMethod parseTree ]
		  on: Error
		  do: [ :ex | nil ]
]
