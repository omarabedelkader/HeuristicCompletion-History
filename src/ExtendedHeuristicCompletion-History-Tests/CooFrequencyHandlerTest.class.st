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

{ #category : 'tests - class' }
CooFrequencyHandlerTest >> testAddingClassesSortsTheMostFrequent [

	| added1 aDifferentOne |
	added1 := CooAddedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	aDifferentOne := CooAddedClassHistoryItem new
		nameOfClass: 'AnotherTestClass';
		yourself.
		
	handler handleNewClassItem: aDifferentOne addedTo: #().

	handler handleNewClassItem: added1 addedTo: #().
	handler handleNewClassItem: added1 addedTo: #().
	
	self assert: handler classEntries first contents equals: 'TestClass'.


	added1 := CooRemovedClassHistoryItem new
		nameOfClass: 'TestClass';
		yourself.
	handler handleNewClassItem: added1 addedTo: #().
	
	self assert: handler classEntries size equals: 1.
	self assert: handler classEntries first contents equals: 'AnotherTestClass' 
]

{ #category : 'tests - class' }
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

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testNewAddModifiedMethodUpdateTheSameEntry [

	| later added modified |
	later := CooAddedMethodHistoryItem new
		selector: #rankedLaterSelector;
		nameOfClass: 'TestClass';
		yourself.
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	modified := CooModifiedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.

	handler handleNewMethodItem: later addedTo: #().
	handler handleNewMethodItem: added addedTo: #().
	handler handleNewMethodItem: modified addedTo: #().

	self assert: handler selectorEntries size equals: 2.
	"SampleSelector got 2 and rankedLaterSelector 1 so sampleSelector is first."
	self assert: handler selectorEntries first selector equals: #sampleSelector.
	self assert: handler selectorEntries second selector equals: #rankedLaterSelector
	
]

{ #category : 'tests - selectors' }
CooFrequencyHandlerTest >> testSelectorEntriesExcludeRemovedMethods [

	| added removed willBeRankedFirstSelector |
	willBeRankedFirstSelector := CooAddedMethodHistoryItem new
		selector: #willBeRankedFirstSelector;
		nameOfClass: 'TestClass';
		yourself.
	added := CooAddedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
		
		
	handler handleNewMethodItem: willBeRankedFirstSelector addedTo: #().	
	handler handleNewMethodItem: added addedTo: #().
	handler handleNewMethodItem: added addedTo: #().
	
	self assert: handler selectorEntries size equals: 2.
	"SampleSelector got 2 and willBeRankedFirstSelector 1 so sampleSelector is first."
	self assert: handler selectorEntries first selector equals: #sampleSelector.
	self assert: handler selectorEntries second selector equals: #willBeRankedFirstSelector.
	
	
	removed := CooRemovedMethodHistoryItem new
		selector: #sampleSelector;
		nameOfClass: 'TestClass';
		yourself.
	
	"The question is what do we do when we remove a method
	We could zero the entry or decrease it from one. Now structurally if we remove the method, we should not get it proposed
	because it can be really the only one."
		
	handler handleNewMethodItem: removed addedTo: #().
	"SampleSelector got 2 and willBeRankedFirstSelector 1 so sampleSelector is first."
	
	self assert: handler selectorEntries size equals: 1.
	self assert: handler selectorEntries first selector equals: #willBeRankedFirstSelector.
]
