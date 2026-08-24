"
Execution-level tests: the AST of a query must always be restored (even on
completion failure), and each executed query produces exactly one raw result
per prefix size.
"
Class {
	#name : 'CooHistoryBenchmarkQueryRunnerTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'running' }
CooHistoryBenchmarkQueryRunnerTest >> newRunnerWithBuilder: aBuilder prefixSizes: aCollection [

	^ CooHistoryBenchmarkQueryRunner new
		  session: CooSession new;
		  builder: aBuilder;
		  topK: 10;
		  prefixSizes: aCollection;
		  repositoryName: 'Fixture';
		  historyWindow: 1;
		  configurationName: #test;
		  yourself
]

{ #category : 'tests' }
CooHistoryBenchmarkQueryRunnerTest >> testBenchmarkQueryProducesOneResultPerPrefix [

	| node results |
	node := (CooFixtureCanvas >> #renderWidget) parseTree allChildren detect: [ :n | n isMessage ].

	results := (self
		            newRunnerWithBuilder: CoASTHeuristicsResultSetBuilder new
		            prefixSizes: #( 2 3 4 5 ))
		           runAll: { (self selectorQueryFor: node) }.

	self assert: results size equals: 4.
	self assert: (results collect: [ :each | each prefixSize ]) asArray sorted equals: #( 2 3 4 5 )
]

{ #category : 'tests' }
CooHistoryBenchmarkQueryRunnerTest >> testBenchmarkQueryRestoresOriginalSelector [

	| node runner |
	node := (CooFixtureCanvas >> #renderWidget) parseTree allChildren detect: [ :n | n isMessage ].
	self assert: node selectorNode value equals: #drawBox.

	runner := self
		          newRunnerWithBuilder: CoASTHeuristicsResultSetBuilder new
		          prefixSizes: #( 2 3 ).
	runner runAll: { (self selectorQueryFor: node) }.

	self assert: node selectorNode value equals: #drawBox
]

{ #category : 'tests' }
CooHistoryBenchmarkQueryRunnerTest >> testBenchmarkQueryRestoresOriginalVariableName [

	| node runner |
	node := (CooFixtureCanvas >> #paintUsing) parseTree allChildren detect: [ :n | n isVariable and: [ n name first isUppercase ] ].
	self assert: node name equals: 'CooFixturePalette'.

	runner := self
		          newRunnerWithBuilder: CoASTHeuristicsResultSetBuilder new
		          prefixSizes: #( 2 3 4 ).
	runner runAll: { (self variableQueryFor: node inMethod: #paintUsing) }.

	self assert: node name equals: 'CooFixturePalette'
]

{ #category : 'tests' }
CooHistoryBenchmarkQueryRunnerTest >> testPrefixLargerThanCandidateIsClampedNotExecuted [

	| node results |
	node := (CooFixtureCanvas >> #renderWidget) parseTree allChildren detect: [ :n | n isMessage ].

	results := (self
		            newRunnerWithBuilder: CoASTHeuristicsResultSetBuilder new
		            prefixSizes: #( 2 99 ))
		           runAll: { (self selectorQueryFor: node) }.

	self assert: results size equals: 1.
	self assert: results first prefixSize equals: 2
]

{ #category : 'tests' }
CooHistoryBenchmarkQueryRunnerTest >> testRestoresOriginalSelectorEvenWhenCompletionFails [
	"A broken builder raises during completion; the AST must still be restored
	and the failure must be recorded instead of propagating."

	| node results diagnostics |
	node := (CooFixtureCanvas >> #renderWidget) parseTree allChildren detect: [ :n | n isMessage ].

	diagnostics := CooHistoryBenchmarkDiagnostic new.
	results := (self newRunnerWithBuilder: Object new prefixSizes: #( 2 ))
		           diagnostics: diagnostics;
		           runAll: { (self selectorQueryFor: node) }.

	self assert: results size equals: 1.
	self assert: results first errored.
	self assert: results first errorReason equals: #completionFailure.
	self assert: node selectorNode value equals: #drawBox.
	self assert: (diagnostics counterAt: #completionErrors) equals: 1
]

{ #category : 'fixture' }
CooHistoryBenchmarkQueryRunnerTest >> selectorQueryFor: aMessageNode [

	^ CooHistoryBenchmarkQuery new
		  targetKind: #selector;
		  className: 'CooFixtureCanvas';
		  methodSelector: #renderWidget;
		  expectedCandidate: aMessageNode selector;
		  astNode: aMessageNode;
		  position: aMessageNode selectorInterval first;
		  sourceCommit: 'test';
		  yourself
]

{ #category : 'fixture' }
CooHistoryBenchmarkQueryRunnerTest >> variableQueryFor: aVariableNode inMethod: aSelector [

	^ CooHistoryBenchmarkQuery new
		  targetKind: #className;
		  className: 'CooFixtureCanvas';
		  methodSelector: aSelector;
		  expectedCandidate: aVariableNode name;
		  astNode: aVariableNode;
		  position: aVariableNode start;
		  sourceCommit: 'test';
		  yourself
]
