Class {
	#name : 'CooTemporalHandlerOrderingTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> setUp [

	super setUp.
	handler := CooTemporalHandler new
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testClassesAreNewestFirst [
	"The most recently added class should appear first in classEntries."

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Alpha'; yourself) addedTo: #().
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Beta'; yourself) addedTo: #().

	self assert: handler classEntries first contents equals: 'Beta'.
	self assert: handler classEntries second contents equals: 'Alpha'
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testInterleavedClassAndMethodOperations [
	"Adding classes and methods interleaved should maintain independence."

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #draw; nameOfClass: 'Widget'; yourself) addedTo: #().
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Button'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #click; nameOfClass: 'Button'; yourself) addedTo: #().

	self assert: handler classEntries size equals: 2.
	self assert: handler selectorEntries size equals: 2.

	"Newest first"
	self assert: handler classEntries first contents equals: 'Button'.
	self assert: handler selectorEntries first selector equals: #click
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testMethodSizeTracksAllItems [

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler methodSize equals: 2.
	self assert: handler size equals: 2
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testMethodsAreNewestFirst [
	"The most recently added method should appear first in selectorEntries."

	| first second |
	first := CooAddedMethodHistoryItem new selector: #alpha; nameOfClass: 'TestClass'; yourself.
	second := CooAddedMethodHistoryItem new selector: #beta; nameOfClass: 'TestClass'; yourself.

	handler handleNewMethodItem: first addedTo: #().
	handler handleNewMethodItem: second addedTo: #().

	"beta was added last, so it should be first"
	self assert: handler selectorEntries first selector equals: #beta.
	self assert: handler selectorEntries second selector equals: #alpha
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testModifiedMethodKeepsTemporalOrder [
	"Modifying a method that was previously added should place the modification first."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	"Both should be present (temporal keeps all), modified first"
	self assert: handler selectorEntries size equals: 2.
	self assert: handler methodDescriptions first class equals: CooModifiedMethodHistoryItem
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testRemovalDeletesAllMatchingByClassAndSelector [
	"Removing a method should delete ALL history entries with that class+selector combo."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 3.

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	"All 3 entries for A>>foo should be gone. The removed item itself is kept in methodDescriptions but filtered from selectorEntries."
	self assert: handler selectorEntries isEmpty
]

{ #category : 'running' }
CooTemporalHandlerOrderingTest >> testRemovalOnlyAffectsMatchingClassAndSelector [
	"#foo in ClassA is different from #foo in ClassB. Removing A>>foo should not touch B>>foo."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'B'; yourself) addedTo: #().

	handler handleNewMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 1
]
