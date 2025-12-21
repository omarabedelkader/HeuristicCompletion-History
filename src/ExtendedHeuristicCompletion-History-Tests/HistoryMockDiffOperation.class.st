Class {
	#name : 'HistoryMockDiffOperation',
	#superclass : 'Object',
	#instVars : [
		'definition',
		'leftContents',
		'rightContents',
		'description',
		'kind',
		'className'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'as yet unclassified' }
HistoryMockDiffOperation class >> additionForSelector: aSymbol leftContents: sourceCode [
    ^ self new
        definition: (HistoryMockMethodDefinition selector: aSymbol);
        leftContents: sourceCode;
        description: aSymbol asString;
        kind: #addition;
        yourself
]

{ #category : 'as yet unclassified' }
HistoryMockDiffOperation class >> modificationForSelector: aSymbol leftContents: newCode rightContents: oldCode [
    ^ self new
        definition: (HistoryMockMethodDefinition selector: aSymbol);
        leftContents: newCode;
        rightContents: oldCode;
        description: aSymbol asString;
        kind: #modification;
        yourself
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> accept: aVisitor [
    self isAddition ifTrue: [ ^ aVisitor visitAddition: self ].
    self isModification ifTrue: [ ^ aVisitor visitModification: self ].
    ^ self
]

{ #category : 'accessing' }
HistoryMockDiffOperation >> className: aString [ 
	definition className: aString
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> definition [
    ^ definition
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> definition: anObject [
    definition := anObject
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> description [
    ^ description ifNil: [ 'Mock change' ]
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> description: aString [
	    description := aString
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> isAddition [

    ^ kind = #addition
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> isModification [
    ^ kind = #modification
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> kind: aSymbol [
    kind := aSymbol
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> leftContents [
    ^ leftContents
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> leftContents: sourceCode [
    leftContents := sourceCode
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> rightContents [
    ^ rightContents
]

{ #category : 'visiting' }
HistoryMockDiffOperation >> rightContents: sourceCode [
    rightContents := sourceCode
]
