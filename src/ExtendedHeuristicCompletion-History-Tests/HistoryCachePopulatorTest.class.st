Class {
	#name : 'HistoryCachePopulatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'populator'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper'
}

{ #category : 'running' }
HistoryCachePopulatorTest >> setUp [
    super setUp.
    populator := HistoryCachePopulator new
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testExtractMethodFromDiffNodeRejectsNonMethods [
    | operation |
    operation := HistoryMockDiffOperation additionForSelector: #foo leftContents: 'foo ^ 1'.
    operation definition: Object new.
    self assert: (populator extractMethodFromDiffNode: operation) isNil
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testExtractMethodFromDiffNodeReturnsSelector [
    | operation |
    operation := HistoryMockDiffOperation additionForSelector: #foo leftContents: 'foo ^ 1'.
    self assert: (populator extractMethodFromDiffNode: operation) equals: #foo
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testPopulateCachesWithMethodInfoDelegatesToSessions [
    | temporal frequency info |
    temporal := HistoryMockSession new.
    frequency := HistoryMockSession new.
    populator temporalSession: temporal.
    populator frequencySession: frequency.
    info := CooODescriptionItem new
		selector: #sample;
		event: #added;
		timestamp: DateAndTime now;
		yourself.
		
    populator populateCachesWithMethodInfo: info.
    self assert: temporal registrations size equals: 1.
    self assert: frequency registrations size equals: 1.
    self assert: ((temporal registrations first) selector) equals: #sample
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testProcessAdditionAddsDictionaryWithMetadata [
    | collection addition timestamp info |
    collection := OrderedCollection new.
    addition := HistoryMockDiffOperation additionForSelector: #bar leftContents: 'bar ^ 2'.
    timestamp := DateAndTime now.
    populator processAddition: addition into: collection timestamp: timestamp.
    self assert: collection size equals: 1.
    info := collection first.
    self assert: (info selector) equals: #bar.
    self assert: (info event) equals: #added.
    self assert: (info timestamp) equals: timestamp.
    self deny: (info ast) isNil
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testProcessModificationAddsDictionaryWithMetadata [
    | collection modification timestamp info |
    collection := OrderedCollection new.
    modification := HistoryMockDiffOperation
        modificationForSelector: #baz
        leftContents: 'baz ^ 3'
        rightContents: 'baz ^ 2'.
    timestamp := DateAndTime now.
    populator processModification: modification into: collection timestamp: timestamp.
    self assert: collection size equals: 1.
    info := collection first.
    self assert: (info selector) equals: #baz.
    self assert: (info event) equals: #modified.
    self assert: (info timestamp) equals: timestamp
]
