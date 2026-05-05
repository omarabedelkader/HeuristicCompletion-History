Class {
	#name : 'CooMostRecentFrequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Interaction',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Interaction'
}

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> fakeEntryWithContents: aString [
	"Create a minimal mock entry object that responds to #contents."

	^ CoSelectorEntry contents: aString node: nil
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> fakeInteractionItemWithToken: aToken selectedIndex: anIndex choices: aCollection [

	| item |
	item := CooInteractionItem new.
	item token: aToken.
	item choices: aCollection.
	item index: anIndex.
	^ item
]

{ #category : 'running' }
CooMostRecentFrequencyHandlerTest >> setUp [

	super setUp.
	handler := CooMostRecentFrequencyHandler new
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testDecayReducesOldEntriesFrequency [

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'alpha'.
	entryB := self fakeEntryWithContents: 'beta'.
	itemA := self fakeInteractionItemWithToken: 'al' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'be' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA.
	"alpha freq = 1"
	handler handleNewSelectionItem: itemB.
	"alpha freq = 1 * 0.5 = 0.5, beta freq = 1"

	"beta should be first because its frequency is higher"
	self assert: handler sortedRecentChoices first contents equals: 'beta'.
	self assert: handler sortedRecentChoices second contents equals: 'alpha'
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testEmptyHandlerReturnsEmptyEntries [

	self assert: handler sortedRecentChoices isEmpty
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testLowercasedAndUppercasedReturnSameAsGeneral [
	"CooMostRecentFrequencyHandler does NOT distinguish case - both should return same results"

	| entry item |
	entry := self fakeEntryWithContents: 'collect:'.
	item := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { entry }.
	handler handleNewSelectionItem: item.

	self assert: handler sortedUserLowercasedEntries size equals: handler sortedUserUppercasedEntries size.
	self assert: handler sortedUserLowercasedEntries size equals: handler sortedUserEntries size
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testRecentSelectionOvertakesOldFrequent [
	"If A is selected once, then B is selected 3 times in a row, B should dominate
	 because A gets decayed 3 times: 1 * 0.5 * 0.5 * 0.5 = 0.125"

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'alpha'.
	entryB := self fakeEntryWithContents: 'beta'.
	itemA := self fakeInteractionItemWithToken: 'al' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'be' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA.
	3 timesRepeat: [ handler handleNewSelectionItem: itemB].

	self assert: handler sortedRecentChoices first contents equals: 'beta'
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testRepeatedSelectionOvercomesDecay [
	"Selecting A many times should keep it above B even after B is selected once"

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'alpha'.
	entryB := self fakeEntryWithContents: 'beta'.
	itemA := self fakeInteractionItemWithToken: 'al' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'be' selectedIndex: 1 choices: { entryB }.

	10 timesRepeat: [ handler handleNewSelectionItem: itemA].
	handler handleNewSelectionItem: itemB.

	"alpha was selected 10 times, decayed once by 0.5. Its accumulated freq should still be high.
	 beta was selected 1 time. alpha should still be first."
	self assert: handler sortedRecentChoices first contents equals: 'alpha'
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testSameEntrySelectedTwiceIncrementsFrequency [
	"Selecting the same entry twice should give it frequency 2, not create a duplicate"

	| entry item |
	entry := self fakeEntryWithContents: 'collect:'.
	item := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { entry }.

	handler handleNewSelectionItem: item.
	handler handleNewSelectionItem: item.

	self assert: handler sortedRecentChoices size equals: 1
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testSingleSelectionIsReturned [

	| entry item |
	entry := self fakeEntryWithContents: 'collect:'.
	item := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { entry }.

	handler handleNewSelectionItem: item.

	self assert: handler sortedRecentChoices size equals: 1.
	self assert: handler sortedRecentChoices first contents equals: 'collect:'
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testSortedUserEntriesReturnsAllWhenLessThan5 [

	| entries |
	entries := (1 to: 3) collect: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'entry', i asString.
		item := self fakeInteractionItemWithToken: 'en' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item.
		entry ].

	self assert: handler sortedUserEntries size equals: 3
]

{ #category : 'tests' }
CooMostRecentFrequencyHandlerTest >> testSortedUserEntriesReturnsAtMost5 [
	"sortedUserEntries should cap at 5 items even if more exist"

	| entries |
	entries := (1 to: 8) collect: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'entry', i asString.
		item := self fakeInteractionItemWithToken: 'en' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item.
		entry ].

	self assert: handler sortedUserEntries size equals: 5
]
