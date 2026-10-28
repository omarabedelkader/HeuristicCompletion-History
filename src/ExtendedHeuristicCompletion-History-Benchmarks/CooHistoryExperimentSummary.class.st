"
I aggregate the results of several History experiments into one summary.

I read every `*-results.ston` file written by CooHistoryExperimentRunner below a directory
and export, next to them:
	- summary.svg / summary.png: one picture with the overall MRR of the three strategies
	  for every project (messages and variables) and the table of the numbers,
	- summary.md, summary.csv, summary.tex: the same table as text.

```
(CooHistoryExperimentSummary fromDirectory: FileLocator workingDirectory / 'History-Bench-Results')
	exportTo: FileLocator workingDirectory / 'History-Bench-Results'
```
"
Class {
	#name : 'CooHistoryExperimentSummary',
	#superclass : 'Object',
	#instVars : [
		'rows'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'instance creation' }
CooHistoryExperimentSummary class >> fromDirectory: aDirectory [

	^ self new
		  readDirectory: aDirectory asFileReference;
		  yourself
]

{ #category : 'svg' }
CooHistoryExperimentSummary >> appendBarPanel: aTitle kind: aKind on: aStream top: top width: width [

	| left height groupWidth barWidth |
	left := 80.
	height := 260.
	groupWidth := (width - left - 40) / (rows size max: 1).
	barWidth := (groupWidth - 24) / 3 min: 40.

	self appendText: aTitle on: aStream x: width / 2 y: top - 18 size: 18 weight: 700 anchor: 'middle'.
	#( 0 0.2 0.4 0.6 0.8 1.0 ) do: [ :tick |
		| y |
		y := top + ((1 - tick) * height).
		aStream nextPutAll: '<line x1="'; print: left; nextPutAll: '" y1="'; nextPutAll: (self number: y);
			nextPutAll: '" x2="'; print: width - 40; nextPutAll: '" y2="'; nextPutAll: (self number: y);
			nextPutAll: '" stroke="#e6e8eb"/>'; cr.
		self appendText: (tick printShowingDecimalPlaces: 1) on: aStream x: left - 8 y: y + 4 size: 12 weight: 400 anchor: 'end' ].

	rows doWithIndex: [ :row :index |
		| groupLeft |
		groupLeft := left + ((index - 1) * groupWidth) + ((groupWidth - (3 * barWidth)) / 2).
		self strategies doWithIndex: [ :strategy :strategyIndex |
			| value x barHeight |
			value := self mrrOf: row kind: aKind strategy: strategy.
			x := groupLeft + ((strategyIndex - 1) * barWidth).
			barHeight := value * height.
			aStream nextPutAll: '<rect x="'; nextPutAll: (self number: x); nextPutAll: '" y="';
				nextPutAll: (self number: top + height - barHeight); nextPutAll: '" width="';
				nextPutAll: (self number: barWidth - 2); nextPutAll: '" height="';
				nextPutAll: (self number: barHeight); nextPutAll: '" fill="';
				nextPutAll: (self colorFor: strategy); nextPutAll: '"/>'; cr.
			self
				appendText: (value printShowingDecimalPlaces: 2)
				on: aStream x: x + (barWidth / 2) - 1 y: top + height - barHeight - 4
				size: 10 weight: 400 anchor: 'middle' ].
		self
			appendText: (row at: #project)
			on: aStream x: left + ((index - 0.5) * groupWidth) y: top + height + 20
			size: 13 weight: 700 anchor: 'middle' ].

	aStream nextPutAll: '<line x1="'; print: left; nextPutAll: '" y1="'; print: top + height;
		nextPutAll: '" x2="'; print: width - 40; nextPutAll: '" y2="'; print: top + height;
		nextPutAll: '" stroke="#333" stroke-width="1.5"/>'; cr
]

{ #category : 'svg' }
CooHistoryExperimentSummary >> appendLegendOn: aStream x: x y: y [

	self strategies doWithIndex: [ :strategy :index |
		| left |
		left := x + ((index - 1) * 150).
		aStream nextPutAll: '<rect x="'; print: left; nextPutAll: '" y="'; print: y - 10;
			nextPutAll: '" width="14" height="14" fill="'; nextPutAll: (self colorFor: strategy); nextPutAll: '"/>'; cr.
		self appendText: (self labelFor: strategy) on: aStream x: left + 20 y: y + 2 size: 14 weight: 400 anchor: 'start' ]
]

{ #category : 'svg' }
CooHistoryExperimentSummary >> appendTableOn: aStream top: top width: width [

	| columnWidth |
	columnWidth := (width - 80) / self tableHeader size.
	self tableRows withIndexDo: [ :cells :rowIndex |
		| y |
		y := top + ((rowIndex - 1) * 24).
		rowIndex = 1 ifFalse: [
			aStream nextPutAll: '<line x1="40" y1="'; nextPutAll: (self number: y - 17);
				nextPutAll: '" x2="'; print: width - 40; nextPutAll: '" y2="'; nextPutAll: (self number: y - 17);
				nextPutAll: '" stroke="#e6e8eb"/>'; cr ].
		cells withIndexDo: [ :cell :columnIndex |
			self
				appendText: cell
				on: aStream
				x: 40 + ((columnIndex - 1) * columnWidth) + (columnIndex = 1 ifTrue: [ 0 ] ifFalse: [ columnWidth / 2 ])
				y: y
				size: 12
				weight: (rowIndex = 1 ifTrue: [ 700 ] ifFalse: [ 400 ])
				anchor: (columnIndex = 1 ifTrue: [ 'start' ] ifFalse: [ 'middle' ]) ] ]
]

{ #category : 'svg' }
CooHistoryExperimentSummary >> appendText: aString on: aStream x: x y: y size: size weight: weight anchor: anchor [

	aStream nextPutAll: '<text x="'; nextPutAll: (self number: x); nextPutAll: '" y="'; nextPutAll: (self number: y);
		nextPutAll: '" text-anchor="'; nextPutAll: anchor;
		nextPutAll: '" font-family="Arial, sans-serif" font-size="'; print: size;
		nextPutAll: '" font-weight="'; print: weight; nextPutAll: '" fill="#222">';
		nextPutAll: (self xmlEscape: aString asString); nextPutAll: '</text>'; cr
]

{ #category : 'private' }
CooHistoryExperimentSummary >> colorFor: aStrategy [

	^ (Dictionary newFrom: {
			  #semantic -> '#2ca02c'.
			  #history -> '#1f77b4'.
			  #completeDirectDependency -> '#d62728' }) at: aStrategy
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> csvString [

	^ String streamContents: [ :stream |
		  self tableRows do: [ :cells |
			  cells do: [ :cell | stream nextPutAll: cell ] separatedBy: [ stream nextPut: $, ].
			  stream lf ] ]
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> exportTo: aDirectory [

	| directory |
	directory := aDirectory asFileReference.
	directory ensureCreateDirectory.
	self write: self svgString to: directory / 'summary.svg'.
	self write: self markdownString to: directory / 'summary.md'.
	self write: self csvString to: directory / 'summary.csv'.
	self write: self latexString to: directory / 'summary.tex'.
	^ directory
]

{ #category : 'private' }
CooHistoryExperimentSummary >> labelFor: aStrategy [

	^ (Dictionary newFrom: {
			  #semantic -> 'Semantic'.
			  #history -> 'History'.
			  #completeDirectDependency -> 'Dependency' }) at: aStrategy
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> latexString [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: '\begin{table}[ht]'; lf;
			  nextPutAll: '\centering'; lf;
			  nextPutAll: '\begin{tabular}{l'; nextPutAll: (String new: self tableHeader size - 1 withAll: $r); nextPutAll: '}'; lf;
			  nextPutAll: '\toprule'; lf.
		  self tableRows withIndexDo: [ :cells :index |
			  cells do: [ :cell | stream nextPutAll: (cell copyReplaceAll: '_' with: '\_') ] separatedBy: [ stream nextPutAll: ' & ' ].
			  stream nextPutAll: ' \\'; lf.
			  index = 1 ifTrue: [ stream nextPutAll: '\midrule'; lf ] ].
		  stream
			  nextPutAll: '\bottomrule'; lf;
			  nextPutAll: '\end{tabular}'; lf;
			  nextPutAll: '\caption{Overall MRR per project. S: complete semantics, H: + session history, D: + direct package dependencies.}'; lf;
			  nextPutAll: '\label{tab:history-summary}'; lf;
			  nextPutAll: '\end{table}'; lf ]
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> markdownString [

	^ String streamContents: [ :stream |
		  self tableRows withIndexDo: [ :cells :index |
			  stream nextPutAll: '| '.
			  cells do: [ :cell | stream nextPutAll: cell ] separatedBy: [ stream nextPutAll: ' | ' ].
			  stream nextPutAll: ' |'; lf.
			  index = 1 ifTrue: [
				  stream nextPutAll: '|'.
				  cells size timesRepeat: [ stream nextPutAll: '---|' ].
				  stream lf ] ] ]
]

{ #category : 'private' }
CooHistoryExperimentSummary >> mrrOf: aRow kind: aKind strategy: aStrategy [

	^ (((aRow at: aKind ifAbsent: [ nil ]) ifNotNil: [ :benchmarks |
		    (benchmarks at: aStrategy ifAbsent: [ nil ]) ifNotNil: [ :benchmark |
			    benchmark at: #mrr ifAbsent: [ nil ] ] ]) ifNil: [ 0 ]) asFloat
]

{ #category : 'private' }
CooHistoryExperimentSummary >> number: aNumber [

	^ aNumber asFloat printShowingDecimalPlaces: 1
]

{ #category : 'reading' }
CooHistoryExperimentSummary >> readDirectory: aDirectory [

	rows := (aDirectory allChildrenMatching: '*-results.ston')
		        collect: [ :file | STON fromString: file contents ].
	rows := rows asSortedCollection: [ :a :b | (a at: #project) <= (b at: #project) ].
	rows := rows asArray
]

{ #category : 'accessing' }
CooHistoryExperimentSummary >> rows [

	^ rows
]

{ #category : 'private' }
CooHistoryExperimentSummary >> statisticOf: aRow named: aKey [

	^ ((aRow at: #statistics ifAbsent: [ Dictionary new ]) at: aKey ifAbsent: [ '-' ]) asString
]

{ #category : 'private' }
CooHistoryExperimentSummary >> strategies [

	^ #( #semantic #history #completeDirectDependency )
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> svgString [

	| width height |
	width := 200 + (rows size * 150) max: 1100.
	height := 830 + (rows size * 24).
	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: '<?xml version="1.0" encoding="UTF-8"?>'; cr;
			  nextPutAll: '<svg xmlns="http://www.w3.org/2000/svg" width="'; print: width;
			  nextPutAll: '" height="'; print: height; nextPutAll: '" viewBox="0 0 '; print: width; space; print: height;
			  nextPutAll: '">'; cr;
			  nextPutAll: '<rect width="100%" height="100%" fill="white"/>'; cr.
		  self appendText: 'History experiments: overall MRR per project' on: stream x: width / 2 y: 36 size: 22 weight: 700 anchor: 'middle'.
		  self appendLegendOn: stream x: width / 2 - 220 y: 68.
		  self appendBarPanel: 'Message completion' kind: #messages on: stream top: 120 width: width.
		  self appendBarPanel: 'Variable completion' kind: #variables on: stream top: 450 width: width.
		  self appendTableOn: stream top: 790 width: width.
		  stream nextPutAll: '</svg>'; cr ]
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> tableHeader [

	^ #( 'Project' 'Commits' 'Msg sites' 'Msg S' 'Msg H' 'Msg D' 'Var sites' 'Var S' 'Var H' 'Var D' )
]

{ #category : 'exporting' }
CooHistoryExperimentSummary >> tableRows [

	^ (OrderedCollection with: self tableHeader)
		  addAll: (rows collect: [ :row |
					   {
						   (row at: #project).
						   (row at: #commitsAnalyzed ifAbsent: [ '-' ]) asString.
						   (self statisticOf: row named: #messageCallsites) } ,
					   (self strategies collect: [ :strategy |
						    (self mrrOf: row kind: #messages strategy: strategy) printShowingDecimalPlaces: 4 ]) ,
					   { (self statisticOf: row named: #variableCallsites) } ,
					   (self strategies collect: [ :strategy |
						    (self mrrOf: row kind: #variables strategy: strategy) printShowingDecimalPlaces: 4 ]) ]);
		  yourself
]

{ #category : 'private' }
CooHistoryExperimentSummary >> write: aString to: aFileReference [

	aFileReference ensureDelete.
	aFileReference writeStreamDo: [ :stream | stream nextPutAll: aString ].
	^ aFileReference
]

{ #category : 'private' }
CooHistoryExperimentSummary >> xmlEscape: aString [

	^ ((aString copyReplaceAll: '&' with: '&amp;') copyReplaceAll: '<' with: '&lt;')
		  copyReplaceAll: '>'
		  with: '&gt;'
]
