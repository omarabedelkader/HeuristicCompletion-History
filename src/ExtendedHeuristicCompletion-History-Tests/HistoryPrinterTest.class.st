Class {
	#name : 'HistoryPrinterTest',
	#superclass : 'Object',
	#instVars : [
		'printer',
		'transcript'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'tests' }
HistoryPrinterTest >> setUp [
    transcript := HistoryMockTranscript new.
    printer := HistoryPrinter new
        transcript: transcript;
        indent: '>';
        yourself
]

{ #category : 'tests' }
HistoryPrinterTest >> testPrintCodeTruncatesLongMethods [
    | code |
    code := String streamContents: [ :stream |
        1 to: 22 do: [ :index |
            stream nextPutAll: 'line', index asString.
            index < 22 ifTrue: [ stream cr ] ] ].
    printer printCode: code.
    self assert: (transcript contents includesSubstring: '... (2 more lines)')
]

{ #category : 'tests' }
HistoryPrinterTest >> testVisitAdditionPrintsDescriptionAndCode [
    | addition |
    addition := HistoryMockDiffOperation additionForSelector: #foo leftContents: 'foo ^ 1'.
    addition description: 'Mock addition'.
    printer visitAddition: addition.
    self assert: (transcript contents includesSubstring: '+ ADDED: Mock addition').
    self assert: (transcript contents includesSubstring: 'Code:').
    self assert: (transcript contents includesSubstring: 'foo ^ 1')
]

{ #category : 'tests' }
HistoryPrinterTest >> testVisitAdditionSkipsCodeForNonMethods [
    | addition |
    addition := HistoryMockDiffOperation additionForSelector: #foo leftContents: 'foo ^ 1'.
    addition definition: HistoryMockNonMethodDefinition new.
    printer visitAddition: addition.
    self deny: (transcript contents includesSubstring: 'Code:')
]

{ #category : 'tests' }
HistoryPrinterTest >> testVisitModificationPrintsBothVersions [
    | modification |
    modification := HistoryMockDiffOperation
        modificationForSelector: #bar
        leftContents: 'bar ^ 2'
        rightContents: 'bar ^ 1'.
    printer visitModification: modification.
    self assert: (transcript contents includesSubstring: 'Old code:').
    self assert: (transcript contents includesSubstring: 'New code:').
    self assert: (transcript contents includesSubstring: 'bar ^ 2').
    self assert: (transcript contents includesSubstring: 'bar ^ 1')
]
