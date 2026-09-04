"
I export LaTeX tables from a CooHistoryExperimentResult.
"
Class {
	#name : 'CooHistoryLatexExporter',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Tools',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Tools'
}

{ #category : 'private' }
CooHistoryLatexExporter >> addMetric: label value: value on: aStream [

	aStream
		nextPutAll: (self latexEscape: label);
		nextPutAll: ' & ';
		nextPutAll: value asString;
		nextPutAll: ' \\';
		cr
]

{ #category : 'exporting' }
CooHistoryLatexExporter >> exportAllFor: anExperimentResult to: aDirectory [

	| directory |
	directory := aDirectory asFileReference.
	directory ensureCreateDirectory.

	self
		write: (self latexStatisticsFor: anExperimentResult)
		to: directory / (anExperimentResult filename , '-statistics.tex').
	self
		write: (self latexMessagesMRRFor: anExperimentResult)
		to: directory / (anExperimentResult filename , '-messages-mrr.tex').
	self
		write: (self latexVariablesMRRFor: anExperimentResult)
		to: directory / (anExperimentResult filename , '-variables-mrr.tex')
]

{ #category : 'private' }
CooHistoryLatexExporter >> formatMRR: aNumber [

	^ aNumber asFloat printShowingDecimalPlaces: 4
]

{ #category : 'latex' }
CooHistoryLatexExporter >> latexEscape: aString [

	| escaped |
	escaped := aString asString.
	escaped := escaped copyReplaceAll: '\' with: '\textbackslash{}'.
	escaped := escaped copyReplaceAll: '_' with: '\_'.
	escaped := escaped copyReplaceAll: '&' with: '\&'.
	escaped := escaped copyReplaceAll: '%' with: '\%'.
	^ escaped
]

{ #category : 'latex' }
CooHistoryLatexExporter >> latexMRRForProject: projectName benchmarkKind: benchmarkKind historyBenchmark: historyBenchmark dependencyBenchmark: dependencyBenchmark label: label [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: '\begin{table}[ht]';
			  cr;
			  nextPutAll: '\centering';
			  cr;
			  nextPutAll: '\begin{tabular}{lrrrrrrrr}';
			  cr;
			  nextPutAll: '\toprule';
			  cr;
			  nextPutAll: 'Strategy & Overall & 2 & 3 & 4 & 5 & 6 & 7 & 8 \\';
			  cr;
			  nextPutAll: '\midrule';
			  cr.
		  self
			  writeMRRRowNamed: 'History'
			  benchmark: historyBenchmark
			  on: stream.
		  self
			  writeMRRRowNamed: 'Dependency'
			  benchmark: dependencyBenchmark
			  on: stream.
		  stream
			  nextPutAll: '\bottomrule';
			  cr;
			  nextPutAll: '\end{tabular}';
			  cr;
			  nextPutAll: '\caption{';
			  nextPutAll:
				  (self latexEscape: projectName , ' ' , benchmarkKind
					   , ' MRR. Dependency denotes Complete + Direct Package Dependencies.');
			  nextPutAll: '}';
			  cr;
			  nextPutAll: '\label{';
			  nextPutAll: label;
			  nextPutAll: '}';
			  cr;
			  nextPutAll: '\end{table}';
			  cr ]
]

{ #category : 'latex' }
CooHistoryLatexExporter >> latexMessagesMRRFor: anExperimentResult [

	^ self
		  latexMRRForProject: anExperimentResult projectName
		  benchmarkKind: 'message completion'
		  historyBenchmark: anExperimentResult messageHistoryBenchmark
		  dependencyBenchmark: anExperimentResult messageDependencyBenchmark
		  label: 'tab:' , anExperimentResult filename , '-messages-mrr'
]

{ #category : 'latex' }
CooHistoryLatexExporter >> latexStatisticsFor: anExperimentResult [

	| stats |
	stats := anExperimentResult statistics.
	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: '\begin{table}[ht]';
			  cr;
			  nextPutAll: '\centering';
			  cr;
			  nextPutAll: '\begin{tabular}{lr}';
			  cr;
			  nextPutAll: '\toprule';
			  cr;
			  nextPutAll: 'Metric & ';
			  nextPutAll: (self latexEscape: anExperimentResult projectName);
			  nextPutAll: ' \\';
			  cr;
			  nextPutAll: '\midrule';
			  cr.
		  self addMetric: 'Packages' value: stats packageCount on: stream.
		  self addMetric: 'Classes' value: stats classCount on: stream.
		  self addMetric: 'Methods' value: stats methodCount on: stream.
		  self
			  addMetric: 'Analyzed commits'
			  value: stats historyCommitCount
			  on: stream.
		  self
			  addMetric: 'History classes'
			  value: stats historyClassCount
			  on: stream.
		  self
			  addMetric: 'History methods'
			  value: stats historyMethodCount
			  on: stream.
		  self
			  addMetric: 'Added methods'
			  value: stats addedMethods
			  on: stream.
		  self
			  addMetric: 'Modified methods'
			  value: stats modifiedMethods
			  on: stream.
		  self
			  addMetric: 'Removed methods'
			  value: stats removedMethods
			  on: stream.
		  self
			  addMetric: 'Added classes'
			  value: stats addedClasses
			  on: stream.
		  self
			  addMetric: 'Modified classes'
			  value: stats modifiedClasses
			  on: stream.
		  self
			  addMetric: 'Removed classes'
			  value: stats removedClasses
			  on: stream.
		  self
			  addMetric: 'Message callsites'
			  value: stats messageCallsites
			  on: stream.
		  self
			  addMetric: 'Variable callsites'
			  value: stats variableCallsites
			  on: stream.
		  self
			  addMetric: 'Unique history selectors'
			  value: stats uniqueHistorySelectors
			  on: stream.
		  self
			  addMetric: 'Unique history classes'
			  value: stats uniqueHistoryClasses
			  on: stream.
		  stream
			  nextPutAll: '\bottomrule';
			  cr;
			  nextPutAll: '\end{tabular}';
			  cr;
			  nextPutAll: '\caption{';
			  nextPutAll:
				  (self latexEscape:
					   anExperimentResult projectName
					   , ' project and analyzed history statistics.');
			  nextPutAll: '}';
			  cr;
			  nextPutAll: '\label{tab:';
			  nextPutAll: anExperimentResult filename;
			  nextPutAll: '-statistics}';
			  cr;
			  nextPutAll: '\end{table}';
			  cr ]
]

{ #category : 'latex' }
CooHistoryLatexExporter >> latexVariablesMRRFor: anExperimentResult [

	^ self
		  latexMRRForProject: anExperimentResult projectName
		  benchmarkKind: 'variable completion'
		  historyBenchmark: anExperimentResult variableHistoryBenchmark
		  dependencyBenchmark: anExperimentResult variableDependencyBenchmark
		  label: 'tab:' , anExperimentResult filename , '-variables-mrr'
]

{ #category : 'exporting' }
CooHistoryLatexExporter >> write: aString to: aFileReference [

	aFileReference parent ensureCreateDirectory.
	aFileReference writeStreamDo: [ :stream |
		stream nextPutAll: aString ].
	^ aFileReference
]

{ #category : 'private' }
CooHistoryLatexExporter >> writeMRRRowNamed: aString benchmark: aBenchmark on: aStream [

	aStream
		nextPutAll: (self latexEscape: aString);
		nextPutAll: ' & ';
		nextPutAll: (self formatMRR: aBenchmark mmr).
	(2 to: 8) do: [ :prefix |
		aStream
			nextPutAll: ' & ';
			nextPutAll: (self formatMRR:
					 (aBenchmark mmrForPrefixSize: prefix)) ].
	aStream
		nextPutAll: ' \\';
		cr
]
