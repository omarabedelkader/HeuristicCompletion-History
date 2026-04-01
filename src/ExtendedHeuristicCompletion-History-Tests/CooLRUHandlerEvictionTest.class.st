Class {
	#name : 'CooLRUHandlerEvictionTest',
	#superclass : 'TestCase',
	#instVars : [
		'handler'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooLRUHandlerEvictionTest >> setUp [

	super setUp.
	handler := CooLRUHandler new
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testClassLRUAlsoHas1000Capacity [
	"Same capacity test for classes."

	1 to: 1001 do: [ :i |
		handler handleNewClassItem: (CooAddedClassHistoryItem new
			nameOfClass: 'Class', i asString;
			yourself) addedTo: #() ].

	self assert: handler classEntries size equals: 1000
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testDuplicateClassNamesAreDeduplicated [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself) addedTo: #().
	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself) addedTo: #().

	self assert: handler classEntries size equals: 1
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testDuplicateSelectorsAreDeduplicated [
	"Adding the same selector twice should result in 1 entry (LRU stores by key)."

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().
	handler handleNewMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 1
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testEvictsOldestWhenCapacityExceeded [
	"Fill up LRU to 1000, then add one more. The oldest entry should be evicted."

	1 to: 1000 do: [ :i |
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new
			selector: ('method', i asString) asSymbol;
			nameOfClass: 'A';
			yourself) addedTo: #() ].

	self assert: handler selectorEntries size equals: 1000.

	"Add one more - should evict the oldest (method1)"
	handler handleNewMethodItem: (CooAddedMethodHistoryItem new
		selector: #brandNewMethod;
		nameOfClass: 'A';
		yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 1000.
	self assert: ((handler selectorEntries collect: [ :e | e selector ]) includes: #brandNewMethod)
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testReAccessingUpdatesLRUEntry [
	"Re-adding the same selector should update its value (the item)."

	| originalItem updatedItem |
	originalItem := CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself.
	updatedItem := CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself.

	handler handleNewMethodItem: originalItem addedTo: #().
	handler handleNewMethodItem: updatedItem addedTo: #().

	"Should still be 1 entry but with the updated item"
	self assert: handler selectorEntries size equals: 1
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testSelectorAndClassLRUAreIndependent [
	"Filling up the selector LRU should not affect the class LRU."

	1 to: 1000 do: [ :i |
		handler handleNewMethodItem: (CooAddedMethodHistoryItem new
			selector: ('m', i asString) asSymbol;
			nameOfClass: 'A';
			yourself) addedTo: #() ].

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'OnlyClass'; yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 1000.
	self assert: handler classEntries size equals: 1
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testSingleClassItem [

	handler handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself) addedTo: #().

	self assert: handler classEntries size equals: 1.
	self assert: handler classEntries first contents equals: 'Widget'
]

{ #category : 'running' }
CooLRUHandlerEvictionTest >> testSingleMethodItem [ 

	handler handleNewMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'A'; yourself) addedTo: #().

	self assert: handler selectorEntries size equals: 1.
	self assert: handler selectorEntries first selector equals: #foo
]
