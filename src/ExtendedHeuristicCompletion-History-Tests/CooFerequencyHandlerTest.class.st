Class {
	#name : 'CooFerequencyHandlerTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper'
}

{ #category : 'running' }
CooFerequencyHandlerTest >> setUp [

	super setUp.
	handler := CooTemporalHandler new
]

{ #category : 'running' }
CooFerequencyHandlerTest >> testHandleNewClassItemRemovalClearsMatchingEntries [

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
CooFerequencyHandlerTest >> testHandleNewClassItemRemovalKeepsOtherClasses [

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
CooFerequencyHandlerTest >> testHandleNewMethodItemRemovalClearsMatchingEntries [

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
CooFerequencyHandlerTest >> testSelectorEntriesExcludeRemovedMethods [

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
