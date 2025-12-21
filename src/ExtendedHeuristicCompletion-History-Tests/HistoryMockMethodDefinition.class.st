Class {
	#name : 'HistoryMockMethodDefinition',
	#superclass : 'Object',
	#instVars : [
		'selector'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockMethodDefinition class >> selector: aSymbol [
    ^ self new
        selector: aSymbol;
        yourself
]

{ #category : 'accessing' }
HistoryMockMethodDefinition >> isKindOf: aClass [
    | iceClass |
    iceClass := Smalltalk at: #IceMethodDefinition ifAbsent: [ Object ].
    aClass == iceClass ifTrue: [ ^ true ].
    ^ super isKindOf: aClass
]

{ #category : 'accessing' }
HistoryMockMethodDefinition >> isMethodDefinition [
    ^ true
]

{ #category : 'accessing' }
HistoryMockMethodDefinition >> selector [
    ^ selector
]

{ #category : 'accessing' }
HistoryMockMethodDefinition >> selector: aSymbol [ 
    selector := aSymbol

]
