"
I display one selectable numeric survey rating tile.
"
Class {
	#name : 'CooHistoryRatingTileMorph',
	#superclass : 'BorderedMorph',
	#instVars : [
		'value',
		'selected',
		'actionBlock'
	],
	#category : 'ExtendedHeuristicCompletion-History-Spec',
	#package : 'ExtendedHeuristicCompletion-History-Spec'
}

{ #category : 'instance creation' }
CooHistoryRatingTileMorph class >> value: anInteger action: aBlock [

	^ self new
		value: anInteger;
		actionBlock: aBlock;
		yourself
]

{ #category : 'accessing' }
CooHistoryRatingTileMorph >> actionBlock: aBlock [

	actionBlock := aBlock ifNil: [ [ :ignored | ] ]
]

{ #category : 'colors' }
CooHistoryRatingTileMorph >> backgroundColor [

	^ selected
		ifTrue: [ Color r: 0.40 g: 0.45 b: 0.63 ]
		ifFalse: [ Color r: 0.21 g: 0.26 b: 0.37 ]
]

{ #category : 'colors' }
CooHistoryRatingTileMorph >> borderColor [

	^ selected
		ifTrue: [ Color white ]
		ifFalse: [ Color r: 0.13 g: 0.17 b: 0.25 ]
]

{ #category : 'drawing' }
CooHistoryRatingTileMorph >> drawOn: aCanvas [

	| font text textExtent origin |
	super drawOn: aCanvas.

	font := self ratingFont.
	text := value asString.
	textExtent := (font widthOfString: text) @ font height.
	origin := self bounds center - (textExtent // 2).
	aCanvas
		drawString: text
		at: origin
		font: font
		color: Color white
]

{ #category : 'events' }
CooHistoryRatingTileMorph >> handlesMouseDown: evt [

	^ true
]

{ #category : 'initialization' }
CooHistoryRatingTileMorph >> initialize [

	super initialize.

	value := 0.
	selected := false.
	actionBlock := [ :ignored | ].
	self
		extent: 88 @ 54;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		borderWidth: 2.
	self updateColors
]

{ #category : 'events' }
CooHistoryRatingTileMorph >> mouseUp: evt [

	super mouseUp: evt.
	(self containsPoint: evt cursorPoint) ifTrue: [
		actionBlock cull: self ]
]

{ #category : 'accessing' }
CooHistoryRatingTileMorph >> ratingFont [

	^ StandardFonts windowTitleFont
]

{ #category : 'accessing' }
CooHistoryRatingTileMorph >> selected [

	^ selected
]

{ #category : 'accessing' }
CooHistoryRatingTileMorph >> selected: aBoolean [

	selected := aBoolean = true.
	self updateColors
]

{ #category : 'private' }
CooHistoryRatingTileMorph >> updateColors [

	self
		color: self backgroundColor;
		borderStyle: (BorderStyle color: self borderColor width: 2).
	self changed
]

{ #category : 'accessing' }
CooHistoryRatingTileMorph >> value [

	^ value
]

{ #category : 'accessing' }
CooHistoryRatingTileMorph >> value: anInteger [

	value := anInteger
]
