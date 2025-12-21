Class {
	#name : 'HistoryCachePopulatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'populator'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper'
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

	| session info |
	session := HistoryMockSession new.
	populator session: session.

	info := CooAddedMethodHistoryItem new
		        selector: #sample;
		        timestamp: DateAndTime now;
		        yourself.

	populator populateCachesWithMethodInfo: info.
	self assert: session registrations size equals: 1.
	self assert: session registrations first selector equals: #sample
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
	self assert: info selector equals: #bar.
	self assert: info timestamp equals: timestamp.
	self deny: info ast isNil
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testProcessModificationAddsDictionaryWithMetadata [

	| collection modification timestamp info |
	collection := OrderedCollection new.
	modification := HistoryMockDiffOperation modificationForSelector: #baz leftContents: 'baz ^ 3' rightContents: 'baz ^ 2'.
	modification className: #AAA.
	timestamp := DateAndTime now.
	populator processModification: modification into: collection timestamp: timestamp.
	self assert: collection size equals: 1.
	info := collection first.
	self assert: info selector equals: #baz.
	self assert: info nameOfClass equals: #AAA.
	self assert: info timestamp equals: timestamp
]
