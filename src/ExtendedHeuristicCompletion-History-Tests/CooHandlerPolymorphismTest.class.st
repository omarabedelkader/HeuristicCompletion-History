Class {
	#name : 'CooHandlerPolymorphismTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'helpers' }
CooHandlerPolymorphismTest >> allHandlerClasses [

	^ { CooTemporalHandler. CooFrequencyHandler. CooLRUHandler }
]

{ #category : 'helpers' }
CooHandlerPolymorphismTest >> methodItem: aSelector class: aClassName event: anEventClass [

	^ anEventClass new
		  selector: aSelector;
		  nameOfClass: aClassName;
		  yourself
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testAllHandlersReturnEmptyCollectionsWhenFresh [
	"Every handler must return empty collections for both selector and class entries
	 when no items have been added."

	self allHandlerClasses do: [ :handlerClass |
		| h |
		h := handlerClass new.
		self assert: h selectorEntries isEmpty description: handlerClass name, ' selectorEntries not empty when fresh'.
		self assert: h classEntries isEmpty description: handlerClass name, ' classEntries not empty when fresh' ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testAllHandlersAcceptAddedMethod [
	"Every handler must accept an added method item without error."

	self allHandlerClasses do: [ :handlerClass |
		| h item |
		h := handlerClass new.
		item := self methodItem: #testMethod class: 'TestClass' event: CooAddedMethodHistoryItem.
		h handleNewMethodItem: item addedTo: #().
		self assert: h selectorEntries isNotEmpty description: handlerClass name, ' did not register added method' ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testAllHandlersAcceptModifiedMethod [
	"Every handler must accept a modified method item without error."

	self allHandlerClasses do: [ :handlerClass |
		| h |
		h := handlerClass new.
		h handleNewMethodItem: (self methodItem: #foo class: 'A' event: CooAddedMethodHistoryItem) addedTo: #().
		h handleNewMethodItem: (self methodItem: #foo class: 'A' event: CooModifiedMethodHistoryItem) addedTo: #().
		self assert: h selectorEntries isNotEmpty description: handlerClass name, ' lost entries after modification' ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testAllHandlersAcceptAddedClass [
	"Every handler must accept an added class item without error."

	self allHandlerClasses do: [ :handlerClass |
		| h item |
		h := handlerClass new.
		item := CooAddedClassHistoryItem new nameOfClass: 'Widget'; yourself.
		h handleNewClassItem: item addedTo: #().
		self assert: h classEntries isNotEmpty description: handlerClass name, ' did not register added class' ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testAllHandlersReturnNECEntries [
	"All handlers must return entries that respond to #contents for selectors and classes."

	self allHandlerClasses do: [ :handlerClass |
		| h |
		h := handlerClass new.
		h handleNewMethodItem: (self methodItem: #bar class: 'X' event: CooAddedMethodHistoryItem) addedTo: #().
		h handleNewClassItem: (CooAddedClassHistoryItem new nameOfClass: 'X'; yourself) addedTo: #().

		h selectorEntries do: [ :entry |
			self assert: (entry respondsTo: #contents) description: handlerClass name, ' selectorEntry does not respond to #contents' ].
		h classEntries do: [ :entry |
			self assert: (entry respondsTo: #contents) description: handlerClass name, ' classEntry does not respond to #contents' ] ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testRemoveThenQueryDoesNotCrashAnyHandler [
	"Removing from an empty handler, or removing something never added, should not crash."

	self allHandlerClasses do: [ :handlerClass |
		| h removed |
		h := handlerClass new.
		removed := self methodItem: #ghost class: 'NoClass' event: CooRemovedMethodHistoryItem.

		"Should not raise an error"
		[ h handleNewMethodItem: removed addedTo: #() ]
			on: Error
			do: [ :e | self fail: handlerClass name, ' crashed on remove of non-existent method: ', e messageText ] ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testRemoveClassDoesNotCrashAnyHandler [

	self allHandlerClasses do: [ :handlerClass |
		| h removed |
		h := handlerClass new.
		removed := CooRemovedClassHistoryItem new nameOfClass: 'Ghost'; yourself.

		[ h handleNewClassItem: removed addedTo: #() ]
			on: Error
			do: [ :e | self fail: handlerClass name, ' crashed on remove of non-existent class: ', e messageText ] ]
]

{ #category : 'tests - contract' }
CooHandlerPolymorphismTest >> testAllHandlersSelectorEntriesRespondToSelector [
	"Selector entries should respond to #selector."

	self allHandlerClasses do: [ :handlerClass |
		| h |
		h := handlerClass new.
		h handleNewMethodItem: (self methodItem: #doIt class: 'Z' event: CooAddedMethodHistoryItem) addedTo: #().
		h selectorEntries do: [ :entry |
			self assert: (entry respondsTo: #selector) description: handlerClass name, ' entry does not respond to #selector' ] ]
]

{ #category : 'tests - switching' }
CooHandlerPolymorphismTest >> testSessionShiftPreservesDataForAllHandlerPairs [
	"Shifting from any handler to any other handler via CooSession should not lose methodDescriptions."

	self allHandlerClasses do: [ :fromClass |
		self allHandlerClasses do: [ :toClass |
			| s |
			s := CooSession new programEntityHandler: fromClass new.
			s addMethodItem: (self methodItem: #alpha class: 'A' event: CooAddedMethodHistoryItem).
			s addMethodItem: (self methodItem: #beta class: 'B' event: CooAddedMethodHistoryItem).

			s shiftHandlerTo: toClass new.

			self
				assert: s methodDescriptions size equals: 2
				description: 'Shifting from ', fromClass name, ' to ', toClass name, ' lost methodDescriptions' ] ]
]
