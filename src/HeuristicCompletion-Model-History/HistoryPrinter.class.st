Class {
	#name : 'HistoryPrinter',
	#superclass : 'Object',
	#instVars : [
		'transcript',
		'indent'
	],
	#category : 'HeuristicCompletion-Model-History',
	#package : 'HeuristicCompletion-Model-History'
}

{ #category : 'accessing' }
HistoryPrinter >> indent: aString [
	indent := aString.
]

{ #category : 'accessing' }
HistoryPrinter >> printCode: codeString [
	| lines |
	lines := codeString lines.
	lines size > 20 
		ifTrue: [
			(lines first: 20) do: [ :line | transcript show: indent, '    ', line; cr ].
			transcript show: indent, '    ... (', (lines size - 20) asString, ' more lines)'; cr
		]
		ifFalse: [ lines do: [ :line | transcript show: indent, '    ', line; cr ] ].
]

{ #category : 'accessing' }
HistoryPrinter >> transcript: aTranscript [
	transcript := aTranscript.
]

{ #category : 'accessing' }
HistoryPrinter >> visitAddition: anAddition [

	transcript
		show: indent , '+ ADDED: ' , anAddition description;
		cr.
	anAddition definition isMethodDefinition ifFalse: [ ^ self ].
	transcript
		show: indent , '  Code:';
		cr.
	self printCode: anAddition leftContents
]

{ #category : 'accessing' }
HistoryPrinter >> visitClassDefinition: aClass [
	transcript show: indent, 'Class: ', aClass name; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitDirectoryDefinition: aDir [.

	"nothing"
]

{ #category : 'accessing' }
HistoryPrinter >> visitExtensionDefinition: anExtension [
	transcript show: indent, 'Extension: ', anExtension name; cr.

]

{ #category : 'accessing' }
HistoryPrinter >> visitFileNode: aFile [
	transcript 
		show: indent, 'File: ', aFile name; cr;
		show: indent, '  (', aFile contents size asString, ' bytes)'; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitMethodNode: aMethod [

	"nothing"
]

{ #category : 'accessing' }
HistoryPrinter >> visitModification: aModification [

	transcript
		show: indent , '~ MODIFIED: ' , aModification description;
		cr.
	aModification definition isMethodDefinition ifFalse: [ ^ self ].
	transcript
		show: indent , '  Old code:';
		cr.
	self printCode: aModification rightContents.
	transcript
		show: indent , '  New code:';
		cr.
	self printCode: aModification leftContents
]

{ #category : 'accessing' }
HistoryPrinter >> visitNoModification: aNoModification [

	"nothing "

]

{ #category : 'accessing' }
HistoryPrinter >> visitPackage: aPackage [

	transcript show: indent, 'Package: ', aPackage name; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitRemoval: aRemoval [

	transcript
		show: indent , '- REMOVED: ' , aRemoval description;
		cr.
	aRemoval definition isMethodDefinition ifFalse: [ ^ self ].
	transcript
		show: indent , '  Code:';
		cr.
	self printCode: aRemoval leftContents
]

{ #category : 'accessing' }
HistoryPrinter >> visitRootDefinition: aRoot [

	"nothing"
]

{ #category : 'accessing' }
HistoryPrinter >> visitTraitDefinition: aTrait [

	transcript
		show: indent , 'Trait: ' , aTrait name;
		cr
]
