"
HOW TO PERSIST RESULTS: exports a complete experiment to four artifacts.

history-benchmark-results/
  raw-results.csv            one row per completion query (primary artifact)
  summary-results.csv        one row per repository x window x configuration x target
  diagnostics.csv            counters and skipped-query reasons
  experiment-metadata.json   environment and experiment description

Raw CSV is the primary data: paper tables are derived from it, never the
other way around.
"
Class {
	#name : 'CooHistoryBenchmarkExporter',
	#superclass : 'Object',
	#instVars : [
		'directory'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Export',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Export'
}

{ #category : 'exporting' }
CooHistoryBenchmarkExporter class >> defaultDirectoryName [

	^ 'history-benchmark-results'
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter class >> export: anExperimentResult [

	^ self new export: anExperimentResult
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter class >> export: anExperimentResult toDirectory: aFileReference [

	^ (self forDirectory: aFileReference) export: anExperimentResult
]

{ #category : 'instance creation' }
CooHistoryBenchmarkExporter class >> forDirectory: aFileReference [

	^ self new
		  directory: aFileReference;
		  yourself
]

{ #category : 'csv' }
CooHistoryBenchmarkExporter >> csvEscape: anObject [
	"Minimal RFC-4180 style escaping; values are always quoted so commas and
	quotes inside metadata stay safe."

	| value |
	value := anObject isNil
		         ifTrue: [ '' ]
		         ifFalse: [ anObject asString ].
	^ '"' , (value copyReplaceAll: '"' with: '""') , '"'
]

{ #category : 'accessing' }
CooHistoryBenchmarkExporter >> directory [

	^ directory ifNil: [
		directory := FileLocator imageDirectory / self class defaultDirectoryName ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkExporter >> directory: aFileReference [

	directory := aFileReference
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter >> export: anExperimentResult [

	self directory ensureCreateDirectory.
	self exportRawResults: anExperimentResult.
	self exportSummaryResults: anExperimentResult.
	self exportDiagnostics: anExperimentResult.
	self exportMetadata: anExperimentResult.
	^ self directory
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter >> exportDiagnostics: anExperimentResult [

	| file diagnostic |
	file := self directory / 'diagnostics.csv'.
	diagnostic := anExperimentResult diagnostics.
	file writeStreamDo: [ :stream |
		stream nextPutAll: 'kind,name,value'; lf.
		diagnostic counters do: [ :association |
			stream
				nextPutAll: 'counter,';
				nextPutAll: association key asString;
				nextPutAll: ',';
				print: association value;
				lf ].
		diagnostic skipReasons do: [ :association |
			stream
				nextPutAll: 'skipReason,';
				nextPutAll: association key asString;
				nextPutAll: ',';
				print: association value;
				lf ] ]
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter >> exportMetadata: anExperimentResult [

	| file |
	file := self directory / 'experiment-metadata.json'.
	file writeStreamDo: [ :stream |
		stream nextPutAll:
			(STONJSON toString: anExperimentResult metadata) ]
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter >> exportRawResults: anExperimentResult [

	| file |
	file := self directory / 'raw-results.csv'.
	file writeStreamDo: [ :stream |
		self writeCsvFields: self rawHeaderFields on: stream.
		anExperimentResult queryResults do: [ :result |
			self writeCsvFields: (self rawRowFieldsFor: result) on: stream ] ]
]

{ #category : 'exporting' }
CooHistoryBenchmarkExporter >> exportSummaryResults: anExperimentResult [

	| file |
	file := self directory / 'summary-results.csv'.
	file writeStreamDo: [ :stream |
		self writeCsvFields: self summaryHeaderFields on: stream.
		anExperimentResult aggregateResults do: [ :aggregate |
			self writeCsvFields: (self summaryRowFieldsFor: aggregate) on: stream ] ]
]

{ #category : 'csv' }
CooHistoryBenchmarkExporter >> rawHeaderFields [

	^ #( repositoryName sourceCommit historyWindow configurationName targetKind className methodSelector expectedCandidate prefix prefixSize candidateGenerated candidateCount rank hitAt1 hitAt5 hitAt10 latencyMilliseconds memoryDelta methodHistorySize classHistorySize interactionHistorySize errorReason )
]

{ #category : 'csv' }
CooHistoryBenchmarkExporter >> rawRowFieldsFor: aQueryResult [

	^ {
		  aQueryResult repositoryName.
		  aQueryResult sourceCommit.
		  aQueryResult historyWindow.
		  aQueryResult configurationName.
		  aQueryResult targetKind.
		  aQueryResult className.
		  aQueryResult methodSelector.
		  aQueryResult expectedCandidate.
		  aQueryResult prefix.
		  aQueryResult prefixSize.
		  aQueryResult candidateGenerated.
		  aQueryResult candidateCount.
		  aQueryResult rank.
		  aQueryResult hitAt1.
		  aQueryResult hitAt5.
		  aQueryResult hitAt10.
		  aQueryResult latencyMilliseconds.
		  aQueryResult memoryDelta.
		  aQueryResult methodHistorySize.
		  aQueryResult classHistorySize.
		  aQueryResult interactionHistorySize.
		  aQueryResult errorReason }
]

{ #category : 'private - writing' }
CooHistoryBenchmarkExporter >> writeCsvFields: fields on: stream [

	fields doWithIndex: [ :field :index |
		index > 1 ifTrue: [ stream nextPutAll: ',' ].
		stream nextPutAll: (self csvEscape: field) ].
	stream lf
]

{ #category : 'csv' }
CooHistoryBenchmarkExporter >> summaryHeaderFields [

	^ #( repositoryName historyWindow configurationName targetKind queryCount coverage mrrAt10 hitAt1 hitAt5 hitAt10 medianRank medianLatency p95Latency )
]

{ #category : 'csv' }
CooHistoryBenchmarkExporter >> summaryRowFieldsFor: anAggregate [

	^ {
		  anAggregate repositoryName.
		  anAggregate historyWindow.
		  anAggregate configurationName.
		  anAggregate targetKind.
		  anAggregate queryCount.
		  anAggregate coverage roundTo: 4.
		  anAggregate mrrAt10 roundTo: 4.
		  anAggregate hitAt1 roundTo: 4.
		  anAggregate hitAt5 roundTo: 4.
		  anAggregate hitAt10 roundTo: 4.
		  anAggregate medianRank.
		  anAggregate medianLatency.
		  anAggregate p95Latency }
]
