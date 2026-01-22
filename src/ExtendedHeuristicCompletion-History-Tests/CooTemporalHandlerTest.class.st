Class {
	#name : 'CooTemporalHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper'
}

{ #category : 'running' }
CooTemporalHandlerTest >> setUp [

	super setUp.
	handler := CooTemporalHandler new
]

{ #category : 'running' }
CooTemporalHandlerTest >> testHandleNewClassItemRemovalClearsMatchingEntries [

	| added newer removed |
	added := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	newer := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewClassItem: added addedTo: #().
	handler handleNewClassItem: newer addedTo: #().

	self assert: handler classEntries size equals: 2.

	removed := CooRemovedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewClassItem: removed addedTo: #().

	self assert: handler classEntries isEmpty
]

{ #category : 'running' }
CooTemporalHandlerTest >> testHandleNewClassItemRemovalKeepsOtherClasses [

	| classOne classTwo removed |
	classOne := CooAddedClassHistoryItem new
		nameOfClass: 'ClassOne';
		yourself.
	classTwo := CooAddedClassHistoryItem new
		nameOfClass: 'ClassTwo';
		yourself.

	handler handleNewClassItem: classOne addedTo: #().
	handler handleNewClassItem: classTwo addedTo: #().

	self assert: handler classEntries size equals: 2.

	removed := CooRemovedClassHistoryItem new
		nameOfClass: 'ClassOne';
		yourself.
	handler handleNewClassItem: removed addedTo: #().

	self assert: handler classEntries size equals: 1
]

{ #category : 'running' }
CooTemporalHandlerTest >> testHandleNewMethodItemRemovalClearsMatchingEntries [

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
CooTemporalHandlerTest >> testSelectorEntriesExcludeRemovedMethods [

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
