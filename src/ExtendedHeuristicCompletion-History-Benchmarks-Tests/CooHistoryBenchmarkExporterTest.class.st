"
Exporter tests run fully offline on a tiny synthetic experiment result
written to a temporary directory.
"
Class {
	#name : 'CooHistoryBenchmarkExporterTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
}

{ #category : 'fixture' }
CooHistoryBenchmarkExporterTest >> exportSampleResult [

	| result directory |
	directory := FileLocator temp / ('coo-benchmark-export-test-' , UUID new asString36).
	result := self sampleExperimentResult.
	CooHistoryBenchmarkExporter new
		directory: directory;
		export: result.
	^ directory
]

{ #category : 'running' }
CooHistoryBenchmarkExporterTest >> sampleExperimentResult [

	| rows aggregate diagnostics |
	rows := {
		        (CooHistoryBenchmarkQueryResult new
			         repositoryName: 'Fixture';
			         historyWindow: 1;
			         configurationName: #temporal;
			         targetKind: #selector;
			         className: 'CooFixtureCanvas';
			         methodSelector: #renderWidget;
			         expectedCandidate: #drawBox;
			         prefix: 'dr';
			         prefixSize: 2;
			         rank: 1;
			         candidateCount: 5;
			         latencyMilliseconds: 12;
			         yourself).
		        (CooHistoryBenchmarkQueryResult new
			         repositoryName: 'Fixture';
			         historyWindow: 1;
			         configurationName: #temporal;
			         targetKind: #selector;
			         className: 'CooFixtureCanvas';
			         methodSelector: #renderWidget;
			         expectedCandidate: #drawBox;
			         prefix: 'dra';
			         prefixSize: 3;
			         rank: nil;
			         candidateCount: 2;
			         latencyMilliseconds: 30;
			         yourself) } asOrderedCollection.

	aggregate := CooHistoryBenchmarkResult
		             aggregating: rows
		             repositoryName: 'Fixture'
		             historyWindow: 1
		             configurationName: #temporal
		             targetKind: #selector.

	diagnostics := CooHistoryBenchmarkDiagnostic new.
	diagnostics increment: #queriesExecuted by: 2.
	diagnostics recordSkipReason: #astParseFailed.

	^ CooHistoryBenchmarkExperimentResult new
		  queryResults: rows;
		  aggregateResults: { aggregate };
		  diagnostics: diagnostics;
		  metadata: { ('pharoVersion' -> 'test') } asDictionary;
		  yourself
]

{ #category : 'tests' }
CooHistoryBenchmarkExporterTest >> testExporterWritesDiagnostics [

	| directory content |
	directory := self exportSampleResult.
	content := (directory / 'diagnostics.csv') contents.
	self assert: ((content lines select: [ :line | line beginsWith: 'counter' ]) size) equals: 1.
	self assert: (content includesSubstring: 'skipReason,astParseFailed,1')
]

{ #category : 'tests' }
CooHistoryBenchmarkExporterTest >> testExporterWritesMetadata [

	| directory metadata |
	directory := self exportSampleResult.
	metadata := STONJSON fromString: (directory / 'experiment-metadata.json') contents.
	self assert: (metadata at: 'pharoVersion') equals: 'test'
]

{ #category : 'tests' }
CooHistoryBenchmarkExporterTest >> testExporterWritesRawResults [
	"One row per query, plus header."

	| directory lines |
	directory := self exportSampleResult.
	lines := (directory / 'raw-results.csv') contents lines.
	self assert: lines size equals: 3.
	self assert: ((lines at: 1) beginsWith: '"repositoryName"').
	self assert: ((lines at: 2) includesSubstring: '"Fixture"').
	self assert: ((lines at: 3) includesSubstring: 'drawBox')
]

{ #category : 'tests' }
CooHistoryBenchmarkExporterTest >> testExporterWritesSummaryResults [

	| directory lines |
	directory := self exportSampleResult.
	lines := (directory / 'summary-results.csv') contents lines.
	self assert: lines size equals: 2.
	self assert: ((lines at: 2) includesSubstring: '"temporal"')
]
