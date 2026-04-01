Class {
	#name : 'CooDualMostRecentFrequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> fakeEntryWithContents: aString [

	^ NECSessionSelectorEntry contents: aString node: nil
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> fakeInteractionItemWithToken: aToken selectedIndex: anIndex choices: aCollection [

	| item |
	item := CooInteractionItem new.
	item token: aToken.
	item choices: aCollection.
	item index: anIndex.
	^ item
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> setUp [

	super setUp.
	handler := CooDualMostRecentFrequencyHandler new
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testAddingUppercaseDoesNotDecayLowercase [

	| selectorEntry classEntry selectorItem classItem |
	selectorEntry := self fakeEntryWithContents: 'collect:'.
	classEntry := self fakeEntryWithContents: 'OrderedCollection'.
	selectorItem := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { selectorEntry }.
	classItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { classEntry }.

	handler handleNewSelectionItem: selectorItem addedTo: #().

	20 timesRepeat: [ handler handleNewSelectionItem: classItem addedTo: #() ].
	self assert: handler sortedUserLowercasedEntries size equals: 1.
	self assert: handler sortedUserLowercasedEntries first contents equals: 'collect:'
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testDecayWithinLowercaseDict [ 

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'alpha'.
	entryB := self fakeEntryWithContents: 'beta'.
	itemA := self fakeInteractionItemWithToken: 'al' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'be' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA addedTo: #().
	handler handleNewSelectionItem: itemB addedTo: #().
	self assert: handler sortedUserLowercasedEntries first contents equals: 'beta'
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testDecayWithinUppercaseDict [

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'Array'.
	entryB := self fakeEntryWithContents: 'Bag'.
	itemA := self fakeInteractionItemWithToken: 'Ar' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'Ba' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA addedTo: #().
	handler handleNewSelectionItem: itemB addedTo: #().
	self assert: handler sortedUserUppercasedEntries first contents equals: 'Bag'
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testEmptyHandlerReturnsEmptyForBothCases [

	self assert: handler sortedUserLowercasedEntries isEmpty.
	self assert: handler sortedUserUppercasedEntries isEmpty
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testLowercaseAndUppercaseAreSeparateWorlds [

	| selectorEntry classEntry selectorItem classItem |
	selectorEntry := self fakeEntryWithContents: 'collect:'.
	classEntry := self fakeEntryWithContents: 'OrderedCollection'.
	selectorItem := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { selectorEntry }.
	classItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { classEntry }.

	5 timesRepeat: [ handler handleNewSelectionItem: selectorItem addedTo: #() ].
	handler handleNewSelectionItem: classItem addedTo: #().

	self assert: handler sortedUserLowercasedEntries first contents equals: 'collect:'.
	self assert: handler sortedUserUppercasedEntries first contents equals: 'OrderedCollection'.
	self assert: handler sortedUserLowercasedEntries size equals: 1.
	self assert: handler sortedUserUppercasedEntries size equals: 1
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testLowercaseTokenGoesToLowercaseDictionary [ 

	| entry item |
	entry := self fakeEntryWithContents: 'collect:'.
	item := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { entry }.
	handler handleNewSelectionItem: item addedTo: #().

	self assert: handler sortedUserLowercasedEntries size equals: 1.
	self assert: handler sortedUserLowercasedEntries first contents equals: 'collect:'.
	self assert: handler sortedUserUppercasedEntries isEmpty
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testSortedUserLowercasedEntriesCapsAt5 [

	(1 to: 8) do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'method', i asString.
		item := self fakeInteractionItemWithToken: 'me' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item addedTo: #() ].

	self assert: handler sortedUserLowercasedEntries size equals: 5
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testSortedUserUppercasedEntriesCapsAt5 [

	(1 to: 8) do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'Class', i asString.
		item := self fakeInteractionItemWithToken: 'Cl' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item addedTo: #() ].

	self assert: handler sortedUserUppercasedEntries size equals: 5
]

{ #category : 'as yet unclassified' }
CooDualMostRecentFrequencyHandlerTest >> testUppercaseTokenGoesToUppercaseDictionary [

	| entry item |
	entry := self fakeEntryWithContents: 'OrderedCollection'.
	item := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { entry }.
	handler handleNewSelectionItem: item addedTo: #().

	self assert: handler sortedUserUppercasedEntries size equals: 1.
	self assert: handler sortedUserUppercasedEntries first contents equals: 'OrderedCollection'.
	self assert: handler sortedUserLowercasedEntries isEmpty
]
