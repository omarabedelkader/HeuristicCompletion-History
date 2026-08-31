"
I export project comparison plots from a CooHistoryExperimentResult.
"
Class {
	#name : 'CooHistoryBenchmarkPlotter',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendAxesOn: aStream left: left top: top width: width height: height [

	aStream
		nextPutAll: '<line x1="';
		nextPutAll: (self svgNumber: left);
		nextPutAll: '" y1="';
		nextPutAll: (self svgNumber: top);
		nextPutAll: '" x2="';
		nextPutAll: (self svgNumber: left);
		nextPutAll: '" y2="';
		nextPutAll: (self svgNumber: top + height);
		nextPutAll: '" stroke="#333" stroke-width="1.5"/>';
		cr.
	aStream
		nextPutAll: '<line x1="';
		nextPutAll: (self svgNumber: left);
		nextPutAll: '" y1="';
		nextPutAll: (self svgNumber: top + height);
		nextPutAll: '" x2="';
		nextPutAll: (self svgNumber: left + width);
		nextPutAll: '" y2="';
		nextPutAll: (self svgNumber: top + height);
		nextPutAll: '" stroke="#333" stroke-width="1.5"/>';
		cr
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendGridOn: aStream left: left top: top width: width height: height [

	#( 0 0.2 0.4 0.6 0.8 1.0 ) do: [ :tick |
		| y |
		y := self yForMrr: tick top: top height: height.
		aStream
			nextPutAll: '<line x1="';
			nextPutAll: (self svgNumber: left);
			nextPutAll: '" y1="';
			nextPutAll: (self svgNumber: y);
			nextPutAll: '" x2="';
			nextPutAll: (self svgNumber: left + width);
			nextPutAll: '" y2="';
			nextPutAll: (self svgNumber: y);
			nextPutAll: '" stroke="#e6e8eb" stroke-width="1"/>';
			cr.
		aStream
			nextPutAll: '<text x="';
			nextPutAll: (self svgNumber: left - 12);
			nextPutAll: '" y="';
			nextPutAll: (self svgNumber: y + 4);
			nextPutAll: '" text-anchor="end" font-family="Arial, sans-serif" font-size="13" fill="#333">';
			nextPutAll: (tick asFloat printShowingDecimalPlaces: 1);
			nextPutAll: '</text>';
			cr ]
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendLegendOn: aStream x: x y: y [

	aStream
		nextPutAll: '<circle cx="';
		nextPutAll: (self svgNumber: x);
		nextPutAll: '" cy="';
		nextPutAll: (self svgNumber: y);
		nextPutAll: '" r="5" fill="#1f77b4"/>';
		cr.
	aStream
		nextPutAll: '<text x="';
		nextPutAll: (self svgNumber: x + 14);
		nextPutAll: '" y="';
		nextPutAll: (self svgNumber: y + 5);
		nextPutAll: '" font-family="Arial, sans-serif" font-size="14" fill="#222">History</text>';
		cr.
	self
		appendTriangleOn: aStream
		x: x + 120
		y: y
		color: '#d62728'.
	aStream
		nextPutAll: '<text x="';
		nextPutAll: (self svgNumber: x + 134);
		nextPutAll: '" y="';
		nextPutAll: (self svgNumber: y + 5);
		nextPutAll: '" font-family="Arial, sans-serif" font-size="14" fill="#222">Dependency</text>';
		cr
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendPanelNamed: aTitle historyValues: historyValues dependencyValues: dependencyValues on: aStream left: left top: top width: width height: height [

	aStream
		nextPutAll: '<text x="';
		nextPutAll: (self svgNumber: left + (width / 2));
		nextPutAll: '" y="';
		nextPutAll: (self svgNumber: top - 26);
		nextPutAll: '" text-anchor="middle" font-family="Arial, sans-serif" font-size="20" font-weight="700" fill="#111">';
		nextPutAll: (self xmlEscape: aTitle);
		nextPutAll: '</text>';
		cr.

	self
		appendGridOn: aStream
		left: left
		top: top
		width: width
		height: height.
	self
		appendAxesOn: aStream
		left: left
		top: top
		width: width
		height: height.
	self
		appendXTicksOn: aStream
		left: left
		top: top
		width: width
		height: height.
	self
		appendSeries: historyValues
		color: '#1f77b4'
		marker: #circle
		on: aStream
		left: left
		top: top
		width: width
		height: height.
	self
		appendSeries: dependencyValues
		color: '#d62728'
		marker: #triangle
		on: aStream
		left: left
		top: top
		width: width
		height: height.

	aStream
		nextPutAll: '<text x="';
		nextPutAll: (self svgNumber: left + (width / 2));
		nextPutAll: '" y="';
		nextPutAll: (self svgNumber: top + height + 54);
		nextPutAll: '" text-anchor="middle" font-family="Arial, sans-serif" font-size="15" fill="#333">Prefix Length</text>';
		cr
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendSeries: values color: color marker: marker on: aStream left: left top: top width: width height: height [

	| points |
	points := OrderedCollection new.
	self prefixes withIndexDo: [ :prefix :index |
		| value x y |
		value := values at: index ifAbsent: [ 0 ].
		x := self xForPrefix: prefix left: left width: width.
		y := self yForMrr: value top: top height: height.
		points add:
			(self svgNumber: x) , ',' , (self svgNumber: y) ].

	aStream
		nextPutAll: '<polyline fill="none" stroke="';
		nextPutAll: color;
		nextPutAll: '" stroke-width="2.5" points="';
		nextPutAll: (self join: points separatedBy: ' ');
		nextPutAll: '"/>';
		cr.

	self prefixes withIndexDo: [ :prefix :index |
		| value x y |
		value := values at: index ifAbsent: [ 0 ].
		x := self xForPrefix: prefix left: left width: width.
		y := self yForMrr: value top: top height: height.
		marker = #circle
			ifTrue: [
				aStream
					nextPutAll: '<circle cx="';
					nextPutAll: (self svgNumber: x);
					nextPutAll: '" cy="';
					nextPutAll: (self svgNumber: y);
					nextPutAll: '" r="5" fill="';
					nextPutAll: color;
					nextPutAll: '"/>';
					cr ].
		marker = #triangle
			ifTrue: [
				self
					appendTriangleOn: aStream
					x: x
					y: y
					color: color ] ]
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendTriangleOn: aStream x: x y: y color: color [

	aStream
		nextPutAll: '<polygon points="';
		nextPutAll: (self svgNumber: x);
		nextPutAll: ',';
		nextPutAll: (self svgNumber: y - 6);
		space;
		nextPutAll: (self svgNumber: x - 6);
		nextPutAll: ',';
		nextPutAll: (self svgNumber: y + 5);
		space;
		nextPutAll: (self svgNumber: x + 6);
		nextPutAll: ',';
		nextPutAll: (self svgNumber: y + 5);
		nextPutAll: '" fill="';
		nextPutAll: color;
		nextPutAll: '"/>';
		cr
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> appendXTicksOn: aStream left: left top: top width: width height: height [

	self prefixes do: [ :prefix |
		| x |
		x := self xForPrefix: prefix left: left width: width.
		aStream
			nextPutAll: '<line x1="';
			nextPutAll: (self svgNumber: x);
			nextPutAll: '" y1="';
			nextPutAll: (self svgNumber: top + height);
			nextPutAll: '" x2="';
			nextPutAll: (self svgNumber: x);
			nextPutAll: '" y2="';
			nextPutAll: (self svgNumber: top + height + 6);
			nextPutAll: '" stroke="#333" stroke-width="1"/>';
			cr.
		aStream
			nextPutAll: '<text x="';
			nextPutAll: (self svgNumber: x);
			nextPutAll: '" y="';
			nextPutAll: (self svgNumber: top + height + 24);
			nextPutAll: '" text-anchor="middle" font-family="Arial, sans-serif" font-size="13" fill="#333">';
			nextPutAll: prefix asString;
			nextPutAll: '</text>';
			cr ]
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> canvasExtent [

	^ 1200 @ 620
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> drawLineOn: canvas from: startPoint to: endPoint width: width color: color [

	[ canvas
		line: startPoint
		to: endPoint
		width: width
		color: color ]
		on: MessageNotUnderstood
		do: [ :exception |
			canvas
				line: startPoint
				to: endPoint
				color: color ]
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> drawPNGPanelNamed: aTitle historyValues: historyValues dependencyValues: dependencyValues on: canvas left: left top: top width: width height: height [

	| axisColor gridColor textColor |
	axisColor := Color r: 0.2 g: 0.2 b: 0.2.
	gridColor := Color r: 0.9 g: 0.91 b: 0.92.
	textColor := Color r: 0.1 g: 0.1 b: 0.1.

	self
		drawString: aTitle
		on: canvas
		at: (left + (width / 2) - 45) rounded @ (top - 42) rounded
		color: textColor.

	#( 0 0.2 0.4 0.6 0.8 1.0 ) do: [ :tick |
		| y |
		y := (self yForMrr: tick top: top height: height) rounded.
		self
			drawLineOn: canvas
			from: left rounded @ y
			to: (left + width) rounded @ y
			width: 1
			color: gridColor.
		self
			drawString: (tick asFloat printShowingDecimalPlaces: 1)
			on: canvas
			at: (left - 36) rounded @ (y - 7)
			color: textColor ].

	self
		drawLineOn: canvas
		from: left rounded @ top rounded
		to: left rounded @ (top + height) rounded
		width: 2
		color: axisColor.
	self
		drawLineOn: canvas
		from: left rounded @ (top + height) rounded
		to: (left + width) rounded @ (top + height) rounded
		width: 2
		color: axisColor.

	self prefixes do: [ :prefix |
		| x |
		x := (self xForPrefix: prefix left: left width: width) rounded.
		self
			drawString: prefix asString
			on: canvas
			at: (x - 4) @ (top + height + 12) rounded
			color: textColor ].

	self
		drawPNGSeries: historyValues
		on: canvas
		left: left
		top: top
		width: width
		height: height
		color: (Color r: 0.12 g: 0.47 b: 0.71)
		marker: #circle.
	self
		drawPNGSeries: dependencyValues
		on: canvas
		left: left
		top: top
		width: width
		height: height
		color: (Color r: 0.84 g: 0.15 b: 0.16)
		marker: #triangle
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> drawPNGSeries: values on: canvas left: left top: top width: width height: height color: color marker: marker [

	| previousPoint |
	previousPoint := nil.
	self prefixes withIndexDo: [ :prefix :index |
		| value x y point |
		value := values at: index ifAbsent: [ 0 ].
		x := (self xForPrefix: prefix left: left width: width) rounded.
		y := (self yForMrr: value top: top height: height) rounded.
		point := x @ y.
		previousPoint ifNotNil: [
			self
				drawLineOn: canvas
				from: previousPoint
				to: point
				width: 3
				color: color ].
		marker = #circle
			ifTrue: [
				self
					fillOvalOn: canvas
					center: point
					radius: 5
					color: color ].
		marker = #triangle
			ifTrue: [
				self
					strokeTriangleOn: canvas
					center: point
					color: color ].
		previousPoint := point ]
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> drawString: aString on: canvas at: aPoint color: color [

	[ canvas
		drawString: aString
		at: aPoint
		font: StandardFonts defaultFont
		color: color ]
		on: MessageNotUnderstood
		do: [ :exception |
			canvas
				drawString: aString
				at: aPoint
				color: color ]
]

{ #category : 'exporting' }
CooHistoryBenchmarkPlotter >> exportAllFor: anExperimentResult to: aDirectory [

	| directory svgPath pngPath |
	directory := aDirectory asFileReference.
	directory ensureCreateDirectory.
	svgPath := directory / (anExperimentResult fileStem , '-comparison.svg').
	pngPath := directory / (anExperimentResult fileStem , '-comparison.png').

	self exportSVGFor: anExperimentResult to: svgPath.
	self exportPNGFor: anExperimentResult to: pngPath.

	^ { svgPath. pngPath }
]

{ #category : 'exporting' }
CooHistoryBenchmarkPlotter >> exportPNGFor: anExperimentResult to: aFileReference [

	(Smalltalk globals includesKey: #PNGReadWriter)
		ifFalse: [ ^ nil ].

	^ [ self renderPNGFor: anExperimentResult to: aFileReference asFileReference ]
		  on: Error
		  do: [ :exception |
			  Transcript
				  cr;
				  show: 'Could not export PNG plot: ';
				  show: exception messageText.
			  nil ]
]

{ #category : 'exporting' }
CooHistoryBenchmarkPlotter >> exportSVGFor: anExperimentResult to: aFileReference [

	self
		write: (self svgFor: anExperimentResult)
		to: aFileReference asFileReference
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> fillOvalOn: canvas center: centerPoint radius: radius color: color [

	| rectangle |
	rectangle := (centerPoint x - radius) @ (centerPoint y - radius)
		             corner:
			             (centerPoint x + radius) @ (centerPoint y + radius).
	[ canvas
		fillOval: rectangle
		color: color
		borderWidth: 1
		borderColor: color ]
		on: MessageNotUnderstood
		do: [ :exception |
			canvas
				fillOval: rectangle
				color: color ]
]

{ #category : 'private' }
CooHistoryBenchmarkPlotter >> join: aCollection separatedBy: separatorString [

	^ String streamContents: [ :stream |
		  aCollection
			  do: [ :each | stream nextPutAll: each ]
			  separatedBy: [ stream nextPutAll: separatorString ] ]
]

{ #category : 'private' }
CooHistoryBenchmarkPlotter >> normalizedMrr: aNumber [

	aNumber ifNil: [ ^ 0 ].
	^ ((aNumber asFloat max: 0) min: 1)
]

{ #category : 'accessing' }
CooHistoryBenchmarkPlotter >> prefixes [

	^ 2 to: 8
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> renderPNGFor: anExperimentResult to: aFileReference [

	| form canvas writer |
	form := Form extent: self canvasExtent depth: 32.
	canvas := form getCanvas.
	canvas
		fillRectangle: form boundingBox
		color: Color white.

	self
		drawString: anExperimentResult projectName asUppercase
		on: canvas
		at: 520 @ 32
		color: Color black.
	self
		drawPNGPanelNamed: 'Messages'
		historyValues: anExperimentResult messageHistoryValues
		dependencyValues: anExperimentResult messageDependencyValues
		on: canvas
		left: 80
		top: 100
		width: 460
		height: 360.
	self
		drawPNGPanelNamed: 'Variables'
		historyValues: anExperimentResult variableHistoryValues
		dependencyValues: anExperimentResult variableDependencyValues
		on: canvas
		left: 660
		top: 100
		width: 460
		height: 360.

	self
		fillOvalOn: canvas
		center: 470 @ 555
		radius: 5
		color: (Color r: 0.12 g: 0.47 b: 0.71).
	self
		drawString: 'History'
		on: canvas
		at: 485 @ 548
		color: Color black.
	self
		strokeTriangleOn: canvas
		center: 585 @ 555
		color: (Color r: 0.84 g: 0.15 b: 0.16).
	self
		drawString: 'Dependency'
		on: canvas
		at: 600 @ 548
		color: Color black.

	writer := Smalltalk globals at: #PNGReadWriter.
	writer
		putForm: form
		onFileNamed: aFileReference fullName.
	^ aFileReference
]

{ #category : 'png' }
CooHistoryBenchmarkPlotter >> strokeTriangleOn: canvas center: centerPoint color: color [

	| topPoint leftPoint rightPoint |
	topPoint := centerPoint x @ (centerPoint y - 6).
	leftPoint := (centerPoint x - 6) @ (centerPoint y + 5).
	rightPoint := (centerPoint x + 6) @ (centerPoint y + 5).
	self
		drawLineOn: canvas
		from: topPoint
		to: leftPoint
		width: 2
		color: color.
	self
		drawLineOn: canvas
		from: leftPoint
		to: rightPoint
		width: 2
		color: color.
	self
		drawLineOn: canvas
		from: rightPoint
		to: topPoint
		width: 2
		color: color
]

{ #category : 'svg' }
CooHistoryBenchmarkPlotter >> svgFor: anExperimentResult [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: '<?xml version="1.0" encoding="UTF-8"?>';
			  cr.
		  stream
			  nextPutAll:
				  '<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="620" viewBox="0 0 1200 620">';
			  cr.
		  stream
			  nextPutAll: '<rect width="1200" height="620" fill="white"/>';
			  cr.
		  stream
			  nextPutAll:
				  '<text x="600" y="42" text-anchor="middle" font-family="Arial, sans-serif" font-size="24" font-weight="700" fill="#111">';
			  nextPutAll:
				  (self xmlEscape: anExperimentResult projectName asUppercase);
			  nextPutAll: '</text>';
			  cr.
		  self
			  appendPanelNamed: 'Messages'
			  historyValues: anExperimentResult messageHistoryValues
			  dependencyValues: anExperimentResult messageDependencyValues
			  on: stream
			  left: 80
			  top: 100
			  width: 460
			  height: 360.
		  self
			  appendPanelNamed: 'Variables'
			  historyValues: anExperimentResult variableHistoryValues
			  dependencyValues: anExperimentResult variableDependencyValues
			  on: stream
			  left: 660
			  top: 100
			  width: 460
			  height: 360.
		  self
			  appendLegendOn: stream
			  x: 470
			  y: 555.
		  stream
			  nextPutAll: '</svg>';
			  cr ]
]

{ #category : 'private' }
CooHistoryBenchmarkPlotter >> svgNumber: aNumber [

	^ aNumber asFloat printShowingDecimalPlaces: 2
]

{ #category : 'exporting' }
CooHistoryBenchmarkPlotter >> write: aString to: aFileReference [

	aFileReference parent ensureCreateDirectory.
	aFileReference writeStreamDo: [ :stream |
		stream nextPutAll: aString ].
	^ aFileReference
]

{ #category : 'private' }
CooHistoryBenchmarkPlotter >> xForPrefix: prefix left: left width: width [

	^ left + (((prefix - 2) / 6) * width)
]

{ #category : 'private' }
CooHistoryBenchmarkPlotter >> xmlEscape: aString [

	| escaped |
	escaped := aString asString.
	escaped := escaped copyReplaceAll: '&' with: '&amp;'.
	escaped := escaped copyReplaceAll: '<' with: '&lt;'.
	escaped := escaped copyReplaceAll: '>' with: '&gt;'.
	^ escaped
]

{ #category : 'private' }
CooHistoryBenchmarkPlotter >> yForMrr: value top: top height: height [

	^ top + ((1 - (self normalizedMrr: value)) * height)
]
