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
HistoryCachePopulatorTest >> commitWithDiff [

	| repository |
	repository := self repository.
	repository ifNil: [ ^ nil ].
	^ (repository head withCommitWalkDo: [ :walk |
			   walk
				   maxNumber: 50;
				   commits ]) detect: [ :commit | commit diffToParent notNil ] ifNone: [ nil ]
]

{ #category : 'running' }
HistoryCachePopulatorTest >> firstAdditionOperation [

	^ self firstOperationMatching: [ :operation |
		  operation isAddition and: [ (populator selectorFromNode: operation) notNil ] ]
]

{ #category : 'running' }
HistoryCachePopulatorTest >> firstMethodOperation [

	^ self firstOperationMatching: [ :operation |
		  (populator selectorFromNode: operation) notNil ]
]

{ #category : 'running' }
HistoryCachePopulatorTest >> firstModificationOperation [

	^ self firstOperationMatching: [ :operation |
		  operation isModification and: [ (populator selectorFromNode: operation) notNil ] ]
]

{ #category : 'running' }
HistoryCachePopulatorTest >> firstNonMethodOperation [

	^ self firstOperationMatching: [ :operation |
		  (populator selectorFromNode: operation) isNil ]
]

{ #category : 'running' }
HistoryCachePopulatorTest >> firstOperationMatching: aBlock [

	| commit diff found |
	commit := self commitWithDiff.
	commit ifNil: [ ^ nil ].
	diff := commit diffToParent.
	diff ifNil: [ ^ nil ].
	found := nil.
	diff tree allChildrenDo: [ :node |
		(found isNil and: [ aBlock value: node value ]) ifTrue: [ found := node value ] ].
	^ found
]

{ #category : 'running' }
HistoryCachePopulatorTest >> repository [

	^ IceRepository registry
		  detect: [ :repo | #('HeuristicCompletion-History' 'ExtendedHeuristicCompletion-History') includes: repo name ]
		  ifNone: [ nil ]
]

{ #category : 'running' }
HistoryCachePopulatorTest >> setUp [
    super setUp.
    populator := HistoryCachePopulator new
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testExtractMethodFromDiffNodeRejectsNonMethods [

	| operation |
	operation := self firstNonMethodOperation.
   operation ifNil: [ ^ self skip ].
	self assert: (populator selectorFromNode: operation) isNil
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testExtractMethodFromDiffNodeReturnsSelector [

	| operation |
	operation := self firstMethodOperation.
    operation ifNil: [ ^ self skip ].
    self assert: (populator selectorFromNode: operation) equals: operation definition selector
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testPopulateCachesWithMethodInfoDelegatesToSessions [

	| session info |
	session := CooTemporalHandler new.
	populator session: session.

	info := CooAddedMethodHistoryItem new
		        selector: #sample;
		        timestamp: DateAndTime now;
		        yourself.

	populator populateCachesWithMethodInfo: info.
	self assert: session size equals: 1.
	self assert: session selectorEntries first contents equals: #sample
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testProcessAdditionAddsDictionaryWithMetadata [

	| collection addition timestamp info |
	collection := OrderedCollection new.
	addition := self firstAdditionOperation.
	addition ifNil: [ ^ self skip ].
	timestamp := DateAndTime now.
	populator processAddition: addition into: collection timestamp: timestamp.
	self assert: collection size equals: 1.
	info := collection first.
	self assert: info selector equals: addition definition selector.
	self assert: info timestamp equals: timestamp.
	self deny: info ast isNil
]

{ #category : 'running' }
HistoryCachePopulatorTest >> testProcessModificationAddsDictionaryWithMetadata [

	| collection modification timestamp info |
	collection := OrderedCollection new.
	modification := self firstModificationOperation.
	modification ifNil: [ ^ self skip ].
	timestamp := DateAndTime now.
	populator processModification: modification into: collection timestamp: timestamp.
	self assert: collection size equals: 1.
	info := collection first.
	self assert: info selector equals: modification definition selector.
	self assert: info nameOfClass equals: modification definition className.
	self assert: info timestamp equals: timestamp
]
