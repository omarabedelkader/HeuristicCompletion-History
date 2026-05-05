Class {
	#name : 'CooSessionCompositionTest',
	#superclass : 'CooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'running' }
CooSessionCompositionTest >> fakeEntryWithContents: aString [

	^ CoSelectorEntry contents: aString node: nil
]

{ #category : 'running' }
CooSessionCompositionTest >> fakeGlobalEntryWithContents: aString [

	^ CoSessionGlobalEntry contents: aString node: nil
]

{ #category : 'running' }
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
	session := CooSession new programEntityHandler: CooWeightedClassFrequencyHandler new
]

{ #category : 'tests' }
CooSessionCompositionTest >> testClassEntriesComposesUserSelectionsAndStructuralItems [
	"classEntries = userSelectionHandler sortedUserUppercasedEntries , programEntityHandler classEntries."

	| entry item |
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'StructuralClass'; yourself).

	"Add uppercase user selection"
	session userSelectionHandler: CooDualMostRecentFrequencyHandler new.
	entry := self fakeGlobalEntryWithContents: 'UserClass'.
	item := self fakeInteractionItemWithToken: 'Us' selectedIndex: 1 choices: { entry }.
	session userSelectionHandler handleNewSelectionItem: item.

	self assert: session classEntries size equals: 2.
	self assert: ((session classEntries collect: [ :e | e contents ]) includes: 'UserClass').
	self assert: ((session classEntries collect: [ :e | e contents ]) includes: 'StructuralClass')
]

{ #category : 'tests' }
CooSessionCompositionTest >> testDualHandlerSeparatesUpperAndLowerInSession [ 
	"With CooDualMostRecentFrequencyHandler, lowercase completions go to selectorEntries
	 and uppercase completions go to classEntries."

	| lowerEntry upperEntry lowerItem upperItem |
	session mostDualRecentFrequentSelectionHandling.

	lowerEntry := self fakeEntryWithContents: 'collect:'.
	upperEntry := self fakeGlobalEntryWithContents: 'OrderedCollection'.
	lowerItem := self fakeInteractionItemWithToken: 'col' selectedIndex: 1 choices: { lowerEntry }.
	upperItem := self fakeInteractionItemWithToken: 'Ord' selectedIndex: 1 choices: { upperEntry }.

	session userSelectionHandler handleNewSelectionItem: lowerItem.
	session userSelectionHandler handleNewSelectionItem: upperItem.

	"selectorEntries uses sortedUserLowercasedEntries -> should have 'collect:'"
	self assert: ((session selectorEntries collect: [ :e | e contents ]) includes: 'collect:').

	"classEntries uses sortedUserUppercasedEntries -> should have 'OrderedCollection'"
	self assert: ((session classEntries collect: [ :e | e contents ]) includes: 'OrderedCollection')
]

{ #category : 'tests' }
CooSessionCompositionTest >> testNullSelectionHandlerContributesNothing [
	"When using CooNullUserSelectionHandler, only structural entries should appear."

	session noUserSelectionHandling.
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #onlyStructural; nameOfClass: 'A'; yourself).

	self assert: session selectorEntries size equals: 1.
	self assert: session selectorEntries first contents equals: #onlyStructural
]

{ #category : 'tests' }
CooSessionCompositionTest >> testResetProgramEntitiesDoesNotAffectCompletionItems [
	"resetProgramEntities clears structural data but should not affect user selection tracking."

	| entry item |
	session mostRecentFrequentSelectionHandling.

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #structural; nameOfClass: 'A'; yourself).
	entry := self fakeEntryWithContents: 'userPick'.
	item := self fakeInteractionItemWithToken: 'us' selectedIndex: 1 choices: { entry }.
	session userSelectionHandler handleNewSelectionItem: item.

	self assert: session selectorEntries size equals: 2.

	session resetProgramEntities.

	"Structural entries gone, but user selections are still handled by their own handler"
	self assert: session methodDescriptions isEmpty.
	"After resetProgramEntities, programEntityHandler is a fresh CooTemporalHandler (empty)"
	self assert: session programEntityHandler selectorEntries isEmpty
]

{ #category : 'tests' }
CooSessionCompositionTest >> testSelectorEntriesComposesUserSelectionsAndStructuralItems [
	"selectorEntries = userSelectionHandler sortedUserLowercasedEntries , programEntityHandler selectorEntries.
	 So both sources should contribute."

	"Add structural method"
	| entry item |
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #structuralMethod; nameOfClass: 'A'; yourself).

	"Add user selection"
	session userSelectionHandler: CooMostRecentFrequencyHandler new.
	entry := self fakeEntryWithContents: 'userChoice'.
	item := self fakeInteractionItemWithToken: 'us' selectedIndex: 1 choices: { entry }.
	session userSelectionHandler handleNewSelectionItem: item.

	"selectorEntries should contain both the user selection and the structural method"
	self assert: session selectorEntries size equals: 2.
	self assert: ((session selectorEntries collect: [ :e | e contents ]) includes: 'userChoice').
	self assert: ((session selectorEntries collect: [ :e | e contents ]) includes: #structuralMethod)
]

{ #category : 'tests' }
CooSessionCompositionTest >> testSessionPrintOnIncludesHandlerInfo [ 
	"printOn: should include the handler class name and counts."

	| printString |
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'B'; yourself).

	printString := session printString.

	self assert: (printString includesSubstring: 'mths').
	self assert: (printString includesSubstring: 'cls')
]

{ #category : 'tests' }
CooSessionCompositionTest >> testSwitchingUserSelectionHandlerMidSession [
	"Switching from Null to MostRecentFrequency should immediately start tracking."

	| entry item |
	session noUserSelectionHandling.
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself).
	self assert: session selectorEntries size equals: 1.

	session mostRecentFrequentSelectionHandling.
	entry := self fakeEntryWithContents: 'bar'.
	item := self fakeInteractionItemWithToken: 'ba' selectedIndex: 1 choices: { entry }.
	session userSelectionHandler handleNewSelectionItem: item.

	"Now we should have 1 structural + 1 user selection = 2"
	self assert: session selectorEntries size equals: 2
]
