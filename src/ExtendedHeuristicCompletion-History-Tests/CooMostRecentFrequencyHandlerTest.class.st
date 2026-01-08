Class {
	#name : 'CooMostRecentFrequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> setUp [

	super setUp.
	handler := CooMostRecentFrequencyHandler new
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testAddingSixEntriesStillIncludesNewest [

	| entries selectionCollection |
	selectionCollection := OrderedCollection new.
	entries := (1 to: 6) collect: [ :index |
		CooMockCompletionEntry withContents: 'Item', index asString ].

	entries do: [ :entry |
		handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entry)
			addedTo: selectionCollection ].

	self assert: (handler sortedUserEntries includes: entries last)
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testAlphabeticalOrderWhenFrequenciesEqual [

	| entryA entryB itemA itemB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	itemA := CooMockSelectionItem forEntry: entryA.
	itemB := CooMockSelectionItem forEntry: entryB.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: itemB addedTo: selectionCollection.
	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	handler handleNewSelectionItem: itemB addedTo: selectionCollection.
	handler handleNewSelectionItem: itemA addedTo: selectionCollection.

	self assert: handler sortedUserEntries first equals: entryA
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testAlternatingSelectionsKeepsBothEntries [

	| entryA entryB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	selectionCollection := OrderedCollection new.

	1 to: 4 do: [ :index |
		handler handleNewSelectionItem:
			(CooMockSelectionItem forEntry: (index odd ifTrue: [ entryA ] ifFalse: [ entryB ]))
			addedTo: selectionCollection ].

	self assert: handler sortedUserEntries size equals: 2
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testDifferentStringsAreReturnedAsEntries [

	| entryA entryB selectionCollection results |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.
	results := handler sortedUserEntries.

	self assert: (results includes: entryA).
	self assert: (results includes: entryB)
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testEmptyHandlerReturnsNoEntries [

	self assert: handler sortedUserEntries isEmpty
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testFrequentEntryOutranksOlderOne [

	| entryA entryB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.
	4 timesRepeat: [ handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection ].

	self assert: handler sortedUserEntries first equals: entryA
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testLatestEntryAppearsFirstWhenFrequenciesEqual [

	| entryA entryB itemA itemB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	itemA := CooMockSelectionItem forEntry: entryA.
	itemB := CooMockSelectionItem forEntry: entryB.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	handler handleNewSelectionItem: itemB addedTo: selectionCollection.
	self assert: handler sortedUserEntries first equals: entryB
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testMoreThanFiveEntriesReturnsFive [

	| entries selectionCollection results |
	selectionCollection := OrderedCollection new.
	entries := (1 to: 10) collect: [ :index |
		CooMockCompletionEntry withContents: 'Entry', index asString ].

	entries do: [ :entry |
		handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entry)
			addedTo: selectionCollection ].
	results := handler sortedUserEntries.

	self assert: results size equals: 5
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testMoreThanTwoEntriesStillOrdersMostRecentFirst [

	| entryA entryB entryC selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	entryC := CooMockCompletionEntry withContents: 'Gamma'.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryC) addedTo: selectionCollection.

	self assert: handler sortedUserEntries first equals: entryC
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testMultipleEntriesSortedByPriority [

	| entryA entryB entryC selectionCollection results |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	entryC := CooMockCompletionEntry withContents: 'Gamma'.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryC) addedTo: selectionCollection.

	results := handler sortedUserEntries.
	self assert: results first equals: entryC.
	self assert: results size equals: 3
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testMultipleSelectionsKeepUniqueEntries [

	| entry item selectionCollection |
	entry := CooMockCompletionEntry withContents: 'Alpha'.
	item := CooMockSelectionItem forEntry: entry.
	selectionCollection := OrderedCollection new.

	3 timesRepeat: [ handler handleNewSelectionItem: item addedTo: selectionCollection ].
	self assert: handler sortedUserEntries size equals: 1.
	self assert: handler sortedUserEntries first equals: entry
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testOrderingAfterRepeatedLastSelection [

	| entryA entryB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.

	self assert: handler sortedUserEntries first equals: entryB
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testRecentSelectionOutranksOlderEntries [

	| entryA entryB itemA itemB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	itemA := CooMockSelectionItem forEntry: entryA.
	itemB := CooMockSelectionItem forEntry: entryB.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	handler handleNewSelectionItem: itemB addedTo: selectionCollection.
	self assert: handler sortedUserEntries first equals: entryB.

	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	self assert: handler sortedUserEntries first equals: entryA.
	self assert: handler sortedUserEntries size equals: 2
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testRepeatedRecentSelectionRemainsFirst [

	| entryA entryB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryB) addedTo: selectionCollection.
	2 timesRepeat: [ handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection ].
	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entryA) addedTo: selectionCollection.

	self assert: handler sortedUserEntries first equals: entryA
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testRepeatedSelectionsIncreasePriority [

	| entryA entryB itemA itemB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	itemA := CooMockSelectionItem forEntry: entryA.
	itemB := CooMockSelectionItem forEntry: entryB.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	handler handleNewSelectionItem: itemB addedTo: selectionCollection.
	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	handler handleNewSelectionItem: itemA addedTo: selectionCollection.

	self assert: handler sortedUserEntries first equals: entryA.
	self assert: handler sortedUserEntries size equals: 2
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testSecondSelectionBecomesFirst [

	| entryA entryB itemA itemB selectionCollection |
	entryA := CooMockCompletionEntry withContents: 'Alpha'.
	entryB := CooMockCompletionEntry withContents: 'Beta'.
	itemA := CooMockSelectionItem forEntry: entryA.
	itemB := CooMockSelectionItem forEntry: entryB.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: itemA addedTo: selectionCollection.
	self assert: handler sortedUserEntries first equals: entryA.
	handler handleNewSelectionItem: itemB addedTo: selectionCollection.
	self assert: handler sortedUserEntries first equals: entryB
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testSelectionCollectionIsIgnored [

	| entry selectionCollection |
	entry := CooMockCompletionEntry withContents: 'Alpha'.
	selectionCollection := OrderedCollection new.
	selectionCollection add: #ignored.

	handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entry) addedTo: selectionCollection.
	self assert: handler sortedUserEntries first equals: entry
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testSingleSelectionReturnsEntry [

	| entry item selectionCollection |
	entry := CooMockCompletionEntry withContents: 'Alpha'.
	item := CooMockSelectionItem forEntry: entry.
	selectionCollection := OrderedCollection new.

	handler handleNewSelectionItem: item addedTo: selectionCollection.
	self assert: handler sortedUserEntries size equals: 1.
	self assert: handler sortedUserEntries first equals: entry
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testSortedUserEntriesIsLimitedToFive [

	| entries items selectionCollection results |
	selectionCollection := OrderedCollection new.
	entries := (1 to: 6) collect: [ :index |
		CooMockCompletionEntry withContents: 'Item', index asString ].
	items := entries collect: [ :entry | CooMockSelectionItem forEntry: entry ].

	items do: [ :item | handler handleNewSelectionItem: item addedTo: selectionCollection ].
	results := handler sortedUserEntries.

	self assert: results size equals: 5.
	self assert: results first equals: entries last
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> testTopFiveContainsMostRecentEntry [

	| entries selectionCollection results |
	selectionCollection := OrderedCollection new.
	entries := (1 to: 7) collect: [ :index |
		CooMockCompletionEntry withContents: 'Entry', index asString ].

	entries do: [ :entry |
		handler handleNewSelectionItem: (CooMockSelectionItem forEntry: entry)
			addedTo: selectionCollection ].
	results := handler sortedUserEntries.

	self assert: (results includes: entries last).
]
