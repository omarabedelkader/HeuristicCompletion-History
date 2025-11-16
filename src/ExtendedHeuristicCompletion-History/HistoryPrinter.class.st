Class {
	#name : 'HistoryPrinter',
	#superclass : 'IceTreeVisitor',
	#instVars : [
		'transcript',
		'indent'
	],
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'accessing' }
HistoryPrinter >> indent [
        ^ indent ifNil: [ indent := '' ]
]

{ #category : 'accessing' }
HistoryPrinter >> indent: aString [

	indent := aString ifNil: [ '' ].
]

{ #category : 'accessing' }
HistoryPrinter >> initialize [

        super initialize.
        transcript := Transcript.
        indent := ''.
]

{ #category : 'accessing' }
HistoryPrinter >> maxPreviewLines [
        ^ 20
]

{ #category : 'accessing' }
HistoryPrinter >> printCode: codeString [

        | lines |
        codeString ifNil: [ ^ self ].
        lines := codeString lines.
        lines size > self maxPreviewLines
                ifTrue: [
                        (lines first: self maxPreviewLines) do: [ :line | self printIndentedLine: line ].
                        self printIndentedLine: ('... (' , (lines size - self maxPreviewLines) asString , ' more lines)')
                ]
                ifFalse: [ lines do: [ :line | self printIndentedLine: line ] ].
]

{ #category : 'accessing' }
HistoryPrinter >> printIndentedLine: aString [

        self transcript show: self indent, '    ', aString; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> transcript [
        ^ transcript ifNil: [ transcript := Transcript ]
]

{ #category : 'accessing' }
HistoryPrinter >> transcript: aTranscript [
	transcript := aTranscript.
        transcript := aTranscript ifNil: [ Transcript ].
]

{ #category : 'accessing' }
HistoryPrinter >> visitAddition: anAddition [

        self transcript
                show: self indent , '+ ADDED: ' , anAddition description;
                cr.
        anAddition definition isMethodDefinition ifFalse: [ ^ self ].
        self transcript
                show: self indent , '  Code:';
                cr.
        self printCode: anAddition leftContents
]

{ #category : 'accessing' }
HistoryPrinter >> visitClassDefinition: aClass [
        self transcript show: self indent, 'Class: ', aClass name; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitDirectoryDefinition: aDirectory [

        "no-op"
]

{ #category : 'accessing' }
HistoryPrinter >> visitExtensionDefinition: anExtension [

        self transcript show: self indent, 'Extension: ', anExtension name; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitFileNode: aFile [

        self transcript
                show: self indent, 'File: ', aFile name; cr;
                show: self indent, '  (', aFile contents size asString, ' bytes)'; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitMethodNode: aMethod [

	"nothing"
]

{ #category : 'accessing' }
HistoryPrinter >> visitModification: aModification [
        self transcript
                show: self indent , '~ MODIFIED: ' , aModification description;
                cr.
        aModification definition isMethodDefinition ifFalse: [ ^ self ].
        self transcript
                show: self indent , '  Old code:';
                cr.
        self printCode: aModification rightContents.
        self transcript
                show: self indent , '  New code:';
                cr.
        self printCode: aModification leftContents
]

{ #category : 'accessing' }
HistoryPrinter >> visitNoModification: aNoModification [
	"nothing "

	
]

{ #category : 'accessing' }
HistoryPrinter >> visitPackage: aPackage [

self transcript show: self indent, 'Package: ', aPackage name; cr.
]

{ #category : 'accessing' }
HistoryPrinter >> visitRemoval: aRemoval [

        self transcript
                show: self indent , '- REMOVED: ' , aRemoval description;
                cr.
        aRemoval definition isMethodDefinition ifFalse: [ ^ self ].
        self transcript
                show: self indent , '  Code:';
                cr.
        self printCode: aRemoval leftContents
]

{ #category : 'accessing' }
HistoryPrinter >> visitRootDefinition: aRoot [

	"nothing"
]

{ #category : 'accessing' }
HistoryPrinter >> visitTraitDefinition: aTrait [

        self transcript
                show: self indent , 'Trait: ' , aTrait name;
                cr
]
