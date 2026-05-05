Class {
	#name : 'CooDualMostRecentFrequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Interaction',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Interaction'
}

{ #category : 'running' }
CooDualMostRecentFrequencyHandlerTest >> fakeEntryWithContents: aString [

	^ CoSelectorEntry contents: aString node: nil
]

{ #category : 'running' }
CooDualMostRecentFrequencyHandlerTest >> fakeInteractionItemWithToken: aToken selectedIndex: anIndex choices: aCollection [

	| item |
	item := CooInteractionItem new.
	item token: aToken.
	item choices: aCollection.
	item index: anIndex.
	^ item
]

{ #category : 'running' }
CooDualMostRecentFrequencyHandlerTest >> setUp [

	super setUp.
	handler := CooDualMostRecentFrequencyHandler new
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testAddingUppercaseDoesNotDecayLowercase [

	| selectorEntry classEntry selectorItem classItem |
	selectorEntry := self fakeEntryWithContents: 'collect:'.
	classEntry := self fakeEntryWithContents: 'OrderedCollection'.
	selectorItem := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { selectorEntry }.
	classItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { classEntry }.

	handler handleNewSelectionItem: selectorItem.

	20 timesRepeat: [ handler handleNewSelectionItem: classItem].
	self assert: handler sortedUserLowercasedEntries size equals: 1.
	self assert: handler sortedUserLowercasedEntries first contents equals: 'collect:'
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testDecayWithinLowercaseDict [ 

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'alpha'.
	entryB := self fakeEntryWithContents: 'beta'.
	itemA := self fakeInteractionItemWithToken: 'al' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'be' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA.
	handler handleNewSelectionItem: itemB.
	self assert: handler sortedUserLowercasedEntries first contents equals: 'beta'
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testDecayWithinUppercaseDict [

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'Array'.
	entryB := self fakeEntryWithContents: 'Bag'.
	itemA := self fakeInteractionItemWithToken: 'Ar' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'Ba' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA.
	handler handleNewSelectionItem: itemB.
	self assert: handler sortedUserUppercasedEntries first contents equals: 'Bag'
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testEmptyHandlerReturnsEmptyForBothCases [

	self assert: handler sortedUserLowercasedEntries isEmpty.
	self assert: handler sortedUserUppercasedEntries isEmpty
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testLowercaseAndUppercaseAreSeparateWorlds [

	| selectorEntry classEntry selectorItem classItem |
	selectorEntry := self fakeEntryWithContents: 'collect:'.
	classEntry := self fakeEntryWithContents: 'OrderedCollection'.
	selectorItem := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { selectorEntry }.
	classItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { classEntry }.

	5 timesRepeat: [ handler handleNewSelectionItem: selectorItem].
	handler handleNewSelectionItem: classItem.

	self assert: handler sortedUserLowercasedEntries first contents equals: 'collect:'.
	self assert: handler sortedUserUppercasedEntries first contents equals: 'OrderedCollection'.
	self assert: handler sortedUserLowercasedEntries size equals: 1.
	self assert: handler sortedUserUppercasedEntries size equals: 1
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testLowercaseTokenGoesToLowercaseDictionary [ 

	| entry item |
	entry := self fakeEntryWithContents: 'collect:'.
	item := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { entry }.
	handler handleNewSelectionItem: item.

	self assert: handler sortedUserLowercasedEntries size equals: 1.
	self assert: handler sortedUserLowercasedEntries first contents equals: 'collect:'.
	self assert: handler sortedUserUppercasedEntries isEmpty
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testSortedUserLowercasedEntriesCapsAt5 [

	(1 to: 8) do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'method', i asString.
		item := self fakeInteractionItemWithToken: 'me' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item].

	self assert: handler sortedUserLowercasedEntries size equals: 5
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testSortedUserUppercasedEntriesCapsAt5 [

	(1 to: 8) do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'Class', i asString.
		item := self fakeInteractionItemWithToken: 'Cl' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item].

	self assert: handler sortedUserUppercasedEntries size equals: 5
]

{ #category : 'tests' }
CooDualMostRecentFrequencyHandlerTest >> testUppercaseTokenGoesToUppercaseDictionary [

	| entry item |
	entry := self fakeEntryWithContents: 'OrderedCollection'.
	item := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { entry }.
	handler handleNewSelectionItem: item.

	self assert: handler sortedUserUppercasedEntries size equals: 1.
	self assert: handler sortedUserUppercasedEntries first contents equals: 'OrderedCollection'.
	self assert: handler sortedUserLowercasedEntries isEmpty
]
