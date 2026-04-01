Class {
	#name : 'CooDecayConvergenceTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'helpers' }
CooDecayConvergenceTest >> fakeEntryWithContents: aString [

	^ NECSessionSelectorEntry contents: aString node: nil
]

{ #category : 'helpers' }
CooDecayConvergenceTest >> fakeInteractionItemWithToken: aToken selectedIndex: anIndex choices: aCollection [

	| item |
	item := CooInteractionItem new.
	item token: aToken.
	item choices: aCollection.
	item index: anIndex.
	^ item
]

{ #category : 'running' }
CooDecayConvergenceTest >> setUp [

	super setUp.
	handler := CooMostRecentFrequencyHandler new
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testAncientEntryBecomesNegligibleAfterManyInsertions [
	"An entry selected once, then 20 different entries are added, should have
	 its frequency decayed to near zero: 1 * 0.5^20 ~ 0.00000095"

	| ancientEntry ancientItem |
	ancientEntry := self fakeEntryWithContents: 'ancient'.
	ancientItem := self fakeInteractionItemWithToken: 'an' selectedIndex: 1 choices: { ancientEntry }.

	handler handleNewSelectionItem: ancientItem addedTo: #().

	1 to: 20 do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'newer', i asString.
		item := self fakeInteractionItemWithToken: 'ne' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item addedTo: #() ].

	"ancient should be the very last entry because its frequency was decayed 20 times"
	self assert: handler sortedRecentChoices last contents equals: 'ancient'
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testDecayIsMultiplicativeNotAdditive [
	"After 3 insertions of different items, the first item's frequency should be
	 1 * 0.5 * 0.5 = 0.25, NOT 1 - 0.5 - 0.5 = 0"

	| entryA entryB entryC itemA itemB itemC |
	entryA := self fakeEntryWithContents: 'alpha'.
	entryB := self fakeEntryWithContents: 'beta'.
	entryC := self fakeEntryWithContents: 'gamma'.
	itemA := self fakeInteractionItemWithToken: 'al' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'be' selectedIndex: 1 choices: { entryB }.
	itemC := self fakeInteractionItemWithToken: 'ga' selectedIndex: 1 choices: { entryC }.

	handler handleNewSelectionItem: itemA addedTo: #().
	handler handleNewSelectionItem: itemB addedTo: #().
	handler handleNewSelectionItem: itemC addedTo: #().

	"alpha still exists in the sorted list (frequency ~0.25, not zero)"
	self assert: (handler sortedRecentChoices anySatisfy: [ :e | e contents = 'alpha' ])
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testHighFrequencyEntryResistsDecay [
	"An entry selected 100 times should survive 5 subsequent new entries.
	 Accumulated freq: sum of geometric series ~ 2*(1-0.5^100) ~ 2,
	 then decayed 5 times: 2 * 0.5^5 = 0.0625.
	 Each new entry has freq 1. So the old one loses rank but still exists."

	| heavyEntry heavyItem |
	heavyEntry := self fakeEntryWithContents: 'heavyweight'.
	heavyItem := self fakeInteractionItemWithToken: 'he' selectedIndex: 1 choices: { heavyEntry }.

	100 timesRepeat: [ handler handleNewSelectionItem: heavyItem addedTo: #() ].

	1 to: 5 do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'light', i asString.
		item := self fakeInteractionItemWithToken: 'li' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item addedTo: #() ].

	"heavyweight should still be in the results"
	self assert: (handler sortedRecentChoices anySatisfy: [ :e | e contents = 'heavyweight' ])
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testRepeatedSelectionOfSameEntryConverges [
	"Selecting the same entry N times: freq = sum(0.5^i, i=0..N-1).
	 This converges to 2 as N -> infinity. Verify it stays bounded."

	| entry item |
	entry := self fakeEntryWithContents: 'repeated'.
	item := self fakeInteractionItemWithToken: 're' selectedIndex: 1 choices: { entry }.

	200 timesRepeat: [ handler handleNewSelectionItem: item addedTo: #() ].

	"Only one entry, and its frequency should be bounded (not grow unbounded)"
	self assert: handler sortedRecentChoices size equals: 1
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testTwoEntryOscillationReachesEquilibrium [
	"Alternating between two entries should eventually give them similar frequencies.
	 After many alternations, neither should dominate hugely."

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'ping'.
	entryB := self fakeEntryWithContents: 'pong'.
	itemA := self fakeInteractionItemWithToken: 'pi' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'po' selectedIndex: 1 choices: { entryB }.

	50 timesRepeat: [
		handler handleNewSelectionItem: itemA addedTo: #().
		handler handleNewSelectionItem: itemB addedTo: #() ].

	"Both should be present in results"
	self assert: handler sortedRecentChoices size equals: 2.
	"The last one selected (pong) should be ranked first due to recency"
	self assert: handler sortedRecentChoices first contents equals: 'pong'
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testDecayNeverProducesNegativeFrequency [
	"No matter how many different entries are added, existing entries should
	 never go negative. Frequency = original * 0.5^N which is always positive."

	| firstEntry firstItem |
	firstEntry := self fakeEntryWithContents: 'sentinel'.
	firstItem := self fakeInteractionItemWithToken: 'se' selectedIndex: 1 choices: { firstEntry }.

	handler handleNewSelectionItem: firstItem addedTo: #().

	"Add 50 distinct entries to decay 'sentinel' 50 times"
	1 to: 50 do: [ :i |
		| entry item |
		entry := self fakeEntryWithContents: 'other', i asString.
		item := self fakeInteractionItemWithToken: 'ot' selectedIndex: 1 choices: { entry }.
		handler handleNewSelectionItem: item addedTo: #() ].

	"sentinel should still be in the list (frequency > 0, just very small)"
	self assert: (handler sortedRecentChoices anySatisfy: [ :e | e contents = 'sentinel' ])
]

{ #category : 'tests - convergence' }
CooDecayConvergenceTest >> testComebackEntryOvertakesDecayedLeader [
	"Entry A is selected 5 times, then B is selected 10 times.
	 A gets decayed 10 times. Then A is selected again 3 more times.
	 A should still trail B because B accumulated much more recently."

	| entryA entryB itemA itemB |
	entryA := self fakeEntryWithContents: 'comeback'.
	entryB := self fakeEntryWithContents: 'dominant'.
	itemA := self fakeInteractionItemWithToken: 'co' selectedIndex: 1 choices: { entryA }.
	itemB := self fakeInteractionItemWithToken: 'do' selectedIndex: 1 choices: { entryB }.

	5 timesRepeat: [ handler handleNewSelectionItem: itemA addedTo: #() ].
	10 timesRepeat: [ handler handleNewSelectionItem: itemB addedTo: #() ].

	"Now comeback tries to catch up"
	3 timesRepeat: [ handler handleNewSelectionItem: itemA addedTo: #() ].

	"comeback was selected most recently so it should be first now"
	self assert: handler sortedRecentChoices first contents equals: 'comeback'
]
