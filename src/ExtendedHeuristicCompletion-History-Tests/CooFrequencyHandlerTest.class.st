Class {
	#name : 'CooFrequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper'
}

{ #category : 'running' }
CooFrequencyHandlerTest >> setUp [

	super setUp.
	handler := CooFrequencyHandler new
]

{ #category : 'running' }
CooFrequencyHandlerTest >> testAddingThreeTimesTheSame [

	| added1 addedTheSame1 aDifferentOne |
	added1 := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	addedTheSame1 := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewClassItem: added1 addedTo: #().
	handler handleNewClassItem: addedTheSame1 addedTo: #().

	self assert: handler classEntries size equals: 1.

	aDifferentOne := CooAddedClassHistoryItem new
		nameOfClass: 'AnotherTestClass';
		yourself.
	handler handleNewClassItem: aDifferentOne addedTo: #().
	
	self assert: handler classEntries size equals: 2
]

{ #category : 'running' }
CooFrequencyHandlerTest >> testHandleNewMethodItemRemovalClearsMatchingEntries [

	| added modified removed |
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	modified := CooModifiedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewMethodItem: added addedTo: #().
	handler handleNewMethodItem: modified addedTo: #().

	self assert: handler selectorEntries size equals: 2.

	removed := CooRemovedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewMethodItem: removed addedTo: #().

	self assert: handler selectorEntries isEmpty
]

{ #category : 'running' }
CooFrequencyHandlerTest >> testSelectorEntriesExcludeRemovedMethods [

	| added removed selectorEntries |
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewMethodItem: added addedTo: #().

	removed := CooRemovedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewMethodItem: removed addedTo: #().

	selectorEntries := handler selectorEntries.

	self assert: selectorEntries isEmpty
]
