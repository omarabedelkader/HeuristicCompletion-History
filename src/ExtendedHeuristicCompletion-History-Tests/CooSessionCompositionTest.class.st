Class {
	#name : 'CooSessionCompositionTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'helpers' }
CooSessionCompositionTest >> fakeEntryWithContents: aString [

	^ NECSessionSelectorEntry contents: aString node: nil
]

{ #category : 'helpers' }
CooSessionCompositionTest >> fakeGlobalEntryWithContents: aString [

	^ NECSessionGlobalEntry contents: aString node: nil
]

{ #category : 'helpers' }
CooSessionCompositionTest >> fakeInteractionItemWithToken: aToken selectedIndex: anIndex choices: aCollection [

	| item |
	item := CooInteractionItem new.
	item token: aToken.
	item choices: aCollection.
	item index: anIndex.
	^ item
]

{ #category : 'running' }
CooSessionCompositionTest >> setUp [

	super setUp.
	session := CooSession new programEntityHandler: CooFrequencyHandler new
]

{ #category : 'tests - composition' }
CooSessionCompositionTest >> testSelectorEntriesComposesUserSelectionsAndStructuralItems [
	"selectorEntries = userSelectionHandler sortedUserLowercasedEntries , programEntityHandler selectorEntries.
	 So both sources should contribute."

	"Add structural method"
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #structuralMethod; nameOfClass: 'A'; yourself).

	"Add user selection"
	session useSelectionHandler: CooMostRecentFrequencyHandler new.
	| entry item |
	entry := self fakeEntryWithContents: 'userChoice'.
	item := self fakeInteractionItemWithToken: 'us' selectedIndex: 1 choices: { entry }.
	session useSelectionHandler handleNewSelectionItem: item addedTo: #().

	"selectorEntries should contain both the user selection and the structural method"
	self assert: session selectorEntries size equals: 2.
	self assert: ((session selectorEntries collect: [ :e | e contents ]) includes: 'userChoice').
	self assert: ((session selectorEntries collect: [ :e | e contents ]) includes: #structuralMethod)
]

{ #category : 'tests - composition' }
CooSessionCompositionTest >> testClassEntriesComposesUserSelectionsAndStructuralItems [
	"classEntries = userSelectionHandler sortedUserUppercasedEntries , programEntityHandler classEntries."

	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'StructuralClass'; yourself).

	"Add uppercase user selection"
	session useSelectionHandler: CooDualMostRecentFrequencyHandler new.
	| entry item |
	entry := self fakeGlobalEntryWithContents: 'UserClass'.
	item := self fakeInteractionItemWithToken: 'Us' selectedIndex: 1 choices: { entry }.
	session useSelectionHandler handleNewSelectionItem: item addedTo: #().

	self assert: session classEntries size equals: 2.
	self assert: ((session classEntries collect: [ :e | e contents ]) includes: 'UserClass').
	self assert: ((session classEntries collect: [ :e | e contents ]) includes: 'StructuralClass')
]

{ #category : 'tests - composition' }
CooSessionCompositionTest >> testNullSelectionHandlerContributesNothing [
	"When using CooNullUserSelectionHandler, only structural entries should appear."

	session noUserSelectionHandling.
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #onlyStructural; nameOfClass: 'A'; yourself).

	self assert: session selectorEntries size equals: 1.
	self assert: session selectorEntries first contents equals: #onlyStructural
]

{ #category : 'tests - composition' }
CooSessionCompositionTest >> testSwitchingUserSelectionHandlerMidSession [
	"Switching from Null to MostRecentFrequency should immediately start tracking."

	session noUserSelectionHandling.
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	self assert: session selectorEntries size equals: 1.

	session mostRecentFrequentSelectionHandling.
	| entry item |
	entry := self fakeEntryWithContents: 'bar'.
	item := self fakeInteractionItemWithToken: 'ba' selectedIndex: 1 choices: { entry }.
	session useSelectionHandler handleNewSelectionItem: item addedTo: #().

	"Now we should have 1 structural + 1 user selection = 2"
	self assert: session selectorEntries size equals: 2
]

{ #category : 'tests - composition' }
CooSessionCompositionTest >> testDualHandlerSeparatesUpperAndLowerInSession [
	"With CooDualMostRecentFrequencyHandler, lowercase completions go to selectorEntries
	 and uppercase completions go to classEntries."

	session mostDualRecentFrequentSelectionHandling.

	| lowerEntry upperEntry lowerItem upperItem |
	lowerEntry := self fakeEntryWithContents: 'collect:'.
	upperEntry := self fakeGlobalEntryWithContents: 'OrderedCollection'.
	lowerItem := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { lowerEntry }.
	upperItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { upperEntry }.

	session useSelectionHandler handleNewSelectionItem: lowerItem addedTo: #().
	session useSelectionHandler handleNewSelectionItem: upperItem addedTo: #().

	"selectorEntries uses sortedUserLowercasedEntries -> should have 'collect:'"
	self assert: ((session selectorEntries collect: [ :e | e contents ]) includes: 'collect:').

	"classEntries uses sortedUserUppercasedEntries -> should have 'OrderedCollection'"
	self assert: ((session classEntries collect: [ :e | e contents ]) includes: 'OrderedCollection')
]

{ #category : 'tests - composition' }
CooSessionCompositionTest >> testResetProgramEntitiesDoesNotAffectCompletionItems [
	"resetProgramEntities clears structural data but should not affect user selection tracking."

	session mostRecentFrequentSelectionHandling.

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #structural; nameOfClass: 'A'; yourself).

	| entry item |
	entry := self fakeEntryWithContents: 'userPick'.
	item := self fakeInteractionItemWithToken: 'us' selectedIndex: 1 choices: { entry }.
	session useSelectionHandler handleNewSelectionItem: item addedTo: #().

	self assert: session selectorEntries size equals: 2.

	session resetProgramEntities.

	"Structural entries gone, but user selections are still handled by their own handler"
	self assert: session methodDescriptions isEmpty.
	"After resetProgramEntities, programEntityHandler is a fresh CooTemporalHandler (empty)"
	self assert: session programEntityHandler selectorEntries isEmpty
]

{ #category : 'tests - printing' }
CooSessionCompositionTest >> testSessionPrintOnIncludesHandlerInfo [
	"printOn: should include the handler class name and counts."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'B'; yourself).

	| printString |
	printString := session printString.

	self assert: (printString includesSubstring: 'mths').
	self assert: (printString includesSubstring: 'cls')
]
