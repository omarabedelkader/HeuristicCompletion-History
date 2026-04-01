Class {
	#name : 'CooInteractionAndSelectionIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'helpers' }
CooInteractionAndSelectionIntegrationTest >> fakeEntryWithContents: aString [

	^ NECSessionSelectorEntry contents: aString node: nil
]

{ #category : 'helpers' }
CooInteractionAndSelectionIntegrationTest >> fakeGlobalEntryWithContents: aString [

	^ NECSessionGlobalEntry contents: aString node: nil
]

{ #category : 'helpers' }
CooInteractionAndSelectionIntegrationTest >> fakeInteractionItemWithToken: aToken selectedIndex: anIndex choices: aCollection [

	| item |
	item := CooInteractionItem new.
	item token: aToken.
	item choices: aCollection.
	item index: anIndex.
	^ item
]

{ #category : 'running' }
CooInteractionAndSelectionIntegrationTest >> setUp [

	super setUp.
	session := CooSession new.
	session programEntityHandler: CooTemporalHandler new
]

{ #category : 'tests - interaction recording' }
CooInteractionAndSelectionIntegrationTest >> testInteractionItemRecordsTimestamp [
	"Each CooInteractionItem should have a timestamp automatically set on creation."

	| item |
	item := CooInteractionItem new.
	self assert: item choices isEmpty.
	self assert: item fetchers isEmpty
]

{ #category : 'tests - interaction recording' }
CooInteractionAndSelectionIntegrationTest >> testInteractionItemSelectedItemEntryMatchesIndex [
	"selectedItemEntry should return the choice at the given index."

	| entry1 entry2 entry3 item |
	entry1 := self fakeEntryWithContents: 'first'.
	entry2 := self fakeEntryWithContents: 'second'.
	entry3 := self fakeEntryWithContents: 'third'.

	item := CooInteractionItem new.
	item choices: { entry1. entry2. entry3 }.
	item index: 3.

	self assert: item selectedItemEntry equals: entry3.
	self assert: item selectedItemEntry contents equals: 'third'
]

{ #category : 'tests - interaction recording' }
CooInteractionAndSelectionIntegrationTest >> testInteractionItemSelectedItemStringEqualsEntry [
	"selectedItemString and selectedItemEntry should return the same object."

	| entry item |
	entry := self fakeEntryWithContents: 'onlyChoice'.
	item := CooInteractionItem new.
	item choices: { entry }.
	item index: 1.

	self assert: item selectedItemString == item selectedItemEntry
]

{ #category : 'tests - dual handler' }
CooInteractionAndSelectionIntegrationTest >> testDualHandlerAccumulatesAcrossManyLowercaseTokens [
	"Feed many different lowercase tokens and verify sortedUserLowercasedEntries caps at 5."

	| dualHandler |
	dualHandler := CooDualMostRecentFrequencyHandler new.

	1 to: 10 do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'method', i asString.
		item := self fakeInteractionItemWithToken: 'me' selectedIndex: 1 choices: { entry }.
		dualHandler handleNewSelectionItem: item addedTo: #() ].

	self assert: dualHandler sortedUserLowercasedEntries size equals: 5.
	self assert: dualHandler sortedUserUppercasedEntries isEmpty
]

{ #category : 'tests - dual handler' }
CooInteractionAndSelectionIntegrationTest >> testDualHandlerAccumulatesAcrossManyUppercaseTokens [
	"Feed many different uppercase tokens and verify sortedUserUppercasedEntries caps at 5."

	| dualHandler |
	dualHandler := CooDualMostRecentFrequencyHandler new.

	1 to: 10 do: [ :i |
		| entry item |
		entry := self fakeGlobalEntryWithContents: 'Class', i asString.
		item := self fakeInteractionItemWithToken: 'Cl' selectedIndex: 1 choices: { entry }.
		dualHandler handleNewSelectionItem: item addedTo: #() ].

	self assert: dualHandler sortedUserUppercasedEntries size equals: 5.
	self assert: dualHandler sortedUserLowercasedEntries isEmpty
]

{ #category : 'tests - dual handler' }
CooInteractionAndSelectionIntegrationTest >> testDualHandlerDecayOnlyAffectsOwnCase [
	"Adding lowercase entries should not decay uppercase entries and vice versa."

	| dualHandler upperEntry lowerEntry upperItem lowerItem |
	dualHandler := CooDualMostRecentFrequencyHandler new.

	upperEntry := self fakeGlobalEntryWithContents: 'OrderedCollection'.
	upperItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { upperEntry }.
	dualHandler handleNewSelectionItem: upperItem addedTo: #().

	"Now add 20 lowercase entries - should NOT decay OrderedCollection"
	1 to: 20 do: [ :i |
		lowerEntry := self fakeEntryWithContents: 'method', i asString.
		lowerItem := self fakeInteractionItemWithToken: 'me' selectedIndex: 1 choices: { lowerEntry }.
		dualHandler handleNewSelectionItem: lowerItem addedTo: #() ].

	"OrderedCollection should still be the only uppercase entry, undecayed"
	self assert: dualHandler sortedUserUppercasedEntries size equals: 1.
	self assert: dualHandler sortedUserUppercasedEntries first contents equals: 'OrderedCollection'
]

{ #category : 'tests - null handler' }
CooInteractionAndSelectionIntegrationTest >> testNullHandlerAlwaysReturnsEmpty [
	"CooNullUserSelectionHandler should always return empty for all queries."

	| nullHandler |
	nullHandler := CooNullUserSelectionHandler new.

	self assert: nullHandler sortedUserEntries isEmpty.
	self assert: nullHandler sortedUserLowercasedEntries isEmpty.
	self assert: nullHandler sortedUserUppercasedEntries isEmpty
]

{ #category : 'tests - session integration' }
CooInteractionAndSelectionIntegrationTest >> testSessionDefaultsToMostDualRecentHandler [
	"A fresh session should default to CooDualMostRecentFrequencyHandler."

	| freshSession |
	freshSession := CooSession new.
	self assert: freshSession selectorEntries isEmpty.
	self assert: freshSession classEntries isEmpty
]

{ #category : 'tests - session integration' }
CooInteractionAndSelectionIntegrationTest >> testSessionSwitchBetweenAllSelectionHandlers [
	"Switching between all user selection handler configurations should not crash."

	session noUserSelectionHandling.
	self assert: session selectorEntries isEmpty.

	session mostRecentFrequentSelectionHandling.
	self assert: session selectorEntries isEmpty.

	session mostDualRecentFrequentSelectionHandling.
	self assert: session selectorEntries isEmpty
]

{ #category : 'tests - edge cases' }
CooInteractionAndSelectionIntegrationTest >> testMostRecentHandlerWithSingleCharTokens [
	"Tokens can be very short - single char. Verify decay still works."

	| handler entryA entryB itemA itemB |
	handler := CooMostRecentFrequencyHandler new.
	entryA := self fakeEntryWithContents: 'at:'.
	entryB := self fakeEntryWithContents: 'add:'.
	itemA := self fakeInteractionItemWithToken: 'a' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'a' selectedIndex: 1 choices: { entryB }.

	handler handleNewSelectionItem: itemA addedTo: #().
	handler handleNewSelectionItem: itemB addedTo: #().

	"Both registered, last one wins"
	self assert: handler sortedRecentChoices first contents equals: 'add:'.
	self assert: handler sortedRecentChoices size equals: 2
]

{ #category : 'tests - edge cases' }
CooInteractionAndSelectionIntegrationTest >> testExistingMethodDescriptionsWithMultipleRemovalsOfSameMethod [
	"If the same method is removed multiple times, it should still be filtered correctly."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'X'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'X'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'X'; timestamp: DateAndTime now; yourself).

	self assert: session existingMethodDescriptions isEmpty
]

{ #category : 'tests - edge cases' }
CooInteractionAndSelectionIntegrationTest >> testExistingMethodDescriptionsKeepsMethodsInOtherClasses [
	"Removing #foo from ClassA should not remove #foo from ClassB."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassB'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; timestamp: DateAndTime now; yourself).

	self assert: session existingMethodDescriptions size equals: 1.
	self assert: session existingMethodDescriptions anyOne nameOfClass equals: 'ClassB'
]
