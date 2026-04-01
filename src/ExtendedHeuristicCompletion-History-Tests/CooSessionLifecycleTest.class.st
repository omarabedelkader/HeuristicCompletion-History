Class {
	#name : 'CooSessionLifecycleTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'running' }
CooSessionLifecycleTest >> setUp [

	super setUp.
	session := CooSession new programEntityHandler: CooTemporalHandler new
]

{ #category : 'running' }
CooSessionLifecycleTest >> testAddAndRemoveClassClearsEntries [

	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'MyWidget'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'MyWidget'; yourself).

	self assert: self programEntityHandler classEntries size equals: 2.

	session addClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'MyWidget'; yourself).

	self assert: self programEntityHandler classEntries size equals: 0
]

{ #category : 'running' }
CooSessionLifecycleTest >> testAddModifyRemoveAddLifecycle [
	"Simulate a method being added, modified several times, removed, then re-added.
	 The temporal handler should clear history on remove, then have just the re-added one."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).
	session addMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).
	session addMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).

	self assert: self programEntityHandler selectorEntries size equals: 3.

	"Remove clears all matching entries in the temporal handler"
	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).

	self assert: self programEntityHandler selectorEntries size equals: 0.

	"Re-add after removal"
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).

	self assert: self programEntityHandler selectorEntries size equals: 1
]

{ #category : 'running' }
CooSessionLifecycleTest >> testExistingMethodDescriptionsFiltersRemovedMethods [
	"existingMethodDescriptions should exclude methods that were later removed."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'MyClass'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; timestamp: DateAndTime now; yourself).

	self assert: session existingMethodDescriptions size equals: 1.
	self assert: session existingMethodDescriptions anyOne selector equals: #bar
]

{ #category : 'running' }
CooSessionLifecycleTest >> testExistingMethodDescriptionsWithNoRemovals [

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; timestamp: DateAndTime now; yourself).
	session addMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; timestamp: DateAndTime now; yourself).

	"Both the added and modified version should be present (neither removed)"
	self assert: session existingMethodDescriptions size equals: 2
]

{ #category : 'running' }
CooSessionLifecycleTest >> testMethodsAndClassesAreSeparateCollections [
	"Adding methods should not affect class entries and vice versa."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'MyClass'; yourself).

	self assert: session methodDescriptions size equals: 1.
	self assert: session classDescriptions size equals: 1.
	self assert: self programEntityHandler selectorEntries size equals: 1.
	self assert: self programEntityHandler classEntries size equals: 1
]

{ #category : 'running' }
CooSessionLifecycleTest >> testNewSessionStartsEmpty [

	self assert: session methodDescriptions isEmpty.
	self assert: session classDescriptions isEmpty.
	self assert: self programEntityHandler selectorEntries isEmpty.
	self assert: self programEntityHandler classEntries isEmpty
]

{ #category : 'running' }
CooSessionLifecycleTest >> testRemoveClassKeepsOtherClasses [

	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'Button'; yourself).

	session addClassItem: (CooRemovedClassHistoryItem new nameOfClass: 'Widget'; yourself).

	self assert: self programEntityHandler classEntries size equals: 1.
	self assert: self programEntityHandler classEntries first contents equals: 'Button'
]

{ #category : 'running' }
CooSessionLifecycleTest >> testRemoveOneMethodKeepsOthers [
	"Removing method #foo should not affect method #bar."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #bar; nameOfClass: 'MyClass'; yourself).
	session addMethodItem: (CooModifiedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).

	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).

	self assert: self programEntityHandler selectorEntries size equals: 1.
	self assert: self programEntityHandler selectorEntries first selector equals: #bar
]

{ #category : 'running' }
CooSessionLifecycleTest >> testResetProgramEntitiesClearsEverything [

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'MyClass'; yourself).
	session addClassItem: (CooAddedClassHistoryItem new nameOfClass: 'MyClass'; yourself).

	session resetProgramEntities.

	self assert: session methodDescriptions isEmpty.
	self assert: session classDescriptions isEmpty
]

{ #category : 'running' }
CooSessionLifecycleTest >> testSameMethodNameDifferentClassesAreIndependent [
	"#foo in ClassA and #foo in ClassB are different methods.
	 Removing #foo from ClassA should not remove #foo from ClassB."

	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).
	session addMethodItem: (CooAddedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassB'; yourself).

	session addMethodItem: (CooRemovedMethodHistoryItem new selector: #foo; nameOfClass: 'ClassA'; yourself).

	"ClassB's #foo should survive"
	self assert: self programEntityHandler selectorEntries size equals: 1
]
