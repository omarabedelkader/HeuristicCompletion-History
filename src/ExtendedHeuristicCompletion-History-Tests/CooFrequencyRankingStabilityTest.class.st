Class {
	#name : 'CooFrequencyRankingStabilityTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooFrequencyRankingStabilityTest >> setUp [

	super setUp.
	handler := CooFrequencyHandler new
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testRankingIsDeterministic [
	"Adding the same items in the same order should always produce the same ranking."

	| handler2 |
	handler2 := CooFrequencyHandler new.

	#(#alpha #beta #gamma #alpha #alpha #beta) do: [ :sel |
		| item |
		item := CooAddedMethodHistoryItem new selector: sel; nameOfClass: 'A'; yourself.
		handler handleNewMethodItem: item addedTo: #().
		handler2 handleNewMethodItem: item addedTo: #() ].

	self
		assert: (handler selectorEntries collect: [ :e | e selector ])
		equals: (handler2 selectorEntries collect: [ :e | e selector ])
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testRankingReflectsFrequencyOrder [
	"alpha: 3 times, beta: 2, gamma: 1 -> alpha > beta > gamma"

	3 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #alpha; nameOfClass: 'A'; yourself) addedTo: #() ].
	2 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #beta; nameOfClass: 'A'; yourself) addedTo: #() ].
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #gamma; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler selectorEntries first selector equals: #alpha.
	self assert: handler selectorEntries second selector equals: #beta.
	self assert: handler selectorEntries third selector equals: #gamma
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testRemoveAndReAddResetsFrequency [
	"After removal, re-adding starts the count fresh at 1."

	5 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #() ].
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	"Also add bar with 2 occurrences"
	2 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'A'; yourself) addedTo: #() ].

	"bar(2) > foo(1)"
	self assert: handler selectorEntries first selector equals: #bar.
	self assert: handler selectorEntries second selector equals: #foo
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testClassRankingReflectsFrequency [

	4 timesRepeat: [
		handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself) addedTo: #() ].
	2 timesRepeat: [
		handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Button'; yourself) addedTo: #() ].
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Panel'; yourself) addedTo: #().

	self assert: handler classEntries first contents equals: 'Widget'.
	self assert: handler classEntries second contents equals: 'Button'.
	self assert: handler classEntries third contents equals: 'Panel'
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testModificationCountsAsFrequencyBump [
	"A method added once then modified 4 times should have freq 5."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #evolving; nameOfClass: 'A'; yourself) addedTo: #().
	4 timesRepeat: [
		handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #evolving; nameOfClass: 'A'; yourself) addedTo: #() ].

	"Add a competitor with 3 occurrences"
	3 timesRepeat: [
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #stable; nameOfClass: 'A'; yourself) addedTo: #() ].

	"evolving(5) > stable(3)"
	self assert: handler selectorEntries first selector equals: #evolving
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testManySelectorsStaySorted [
	"Add 20 selectors with different frequencies and verify sorting."

	1 to: 20 do: [ :i |
		i timesRepeat: [
			handler handleNewMethodItem: (CooAddedMethodHistoryItem new
				selector: ('method', i asString) asSymbol;
				nameOfClass: 'A';
				yourself) addedTo: #() ] ].

	"method20 should be first (highest frequency), method1 last"
	self assert: handler selectorEntries first selector equals: #method20.
	self assert: handler selectorEntries last selector equals: #method1
]

{ #category : 'tests - ranking' }
CooFrequencyRankingStabilityTest >> testTiedFrequenciesDoNotCrash [
	"Multiple selectors with the same frequency should not cause errors."

	#(#a #b #c #d #e) do: [ :sel |
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: sel; nameOfClass: 'A'; yourself) addedTo: #() ].

	"All have frequency 1, sorting should work without error"
	self assert: handler selectorEntries size equals: 5
]

{ #category : 'tests - edge cases' }
CooFrequencyRankingStabilityTest >> testRemovingNonExistentDoesNotAffectExisting [
	"Removing a method that was never added should leave existing entries intact."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #existing; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #phantom; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 1.
	self assert: handler selectorEntries first selector equals: #existing
]

{ #category : 'tests - edge cases' }
CooFrequencyRankingStabilityTest >> testInterleaveAddRemoveAddForMultipleSelectors [
	"Interleaving add/remove/add across multiple selectors should leave a consistent state."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #baz; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #bar; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	"foo(1), baz(1) should remain; bar was removed"
	self assert: handler selectorEntries size equals: 2.
	self assert: ((handler selectorEntries collect: [ :e | e selector ]) includesAll: { #foo . #baz }).
	self deny: ((handler selectorEntries collect: [ :e | e selector ]) includes: #bar)
]
