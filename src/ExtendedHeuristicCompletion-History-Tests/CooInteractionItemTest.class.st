Class {
	#name : 'CooInteractionItemTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'tests' }
CooInteractionItemTest >> testFetchersAreStored [

	| item |
	item := CooInteractionItem new.
	item fetchers: #('CoASTFetcher' 'CooMessageSessionFetcher').

	self assert: item fetchers size equals: 2.
	self assert: (item fetchers includes: 'CooMessageSessionFetcher')
]

{ #category : 'tests' }
CooInteractionItemTest >> testSelectedItemEntryReturnsChoiceAtIndex [

	| item entry1 entry2 entry3 |
	entry1 := NECSessionSelectorEntry contents: 'alpha' node: nil.
	entry2 := NECSessionSelectorEntry contents: 'beta' node: nil.
	entry3 := NECSessionSelectorEntry contents: 'gamma' node: nil.

	item := CooInteractionItem new.
	item choices: { entry1. entry2. entry3 }.
	item index: 2.

	self assert: item selectedItemEntry equals: entry2
]

{ #category : 'tests' }
CooInteractionItemTest >> testSelectedItemStringReturnsChoiceAtIndex [
	"selectedItemString should be equivalent to selectedItemEntry"

	| item entry1 entry2 |
	entry1 := NECSessionSelectorEntry contents: 'alpha' node: nil.
	entry2 := NECSessionSelectorEntry contents: 'beta' node: nil.

	item := CooInteractionItem new.
	item choices: { entry1. entry2 }.
	item index: 1.

	self assert: item selectedItemString equals: item selectedItemEntry
]

{ #category : 'tests' }
CooInteractionItemTest >> testTokenIsStored [

	| item |
	item := CooInteractionItem new.
	item token: 'coll'.

	self assert: item token equals: 'coll'
]
