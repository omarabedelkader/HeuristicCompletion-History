"
So far the navigation only report entries for Class navigation.
"
Class {
	#name : 'CooClassNavigationHistoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Navigation',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Navigation'
}

{ #category : 'running' }
CooClassNavigationHistoryTest >> setUp [

	super setUp.
	session := CooSession new.
	session noUserSelectionHandling
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testAddNavigationItemAppearsInClassEntries [

	| item entries |
	item := CooNavigationHistoryItem class: 'OrderedCollection'.
	session addNavigationItem: item.

	entries := session classEntries.
	self assert: entries size equals: 1.
	self assert: entries first contents equals: 'OrderedCollection'.
	self assert: entries first sessionItem equals: item
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testClassObservationDoesNotLeakIntoSelectorEntries [

	session addNavigationItem: (CooNavigationHistoryItem class: 'Array').

	self assert: session selectorEntries isEmpty.
	self assert: session classEntries size equals: 1
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testNavigationEntriesAreCappedAtFive [

	1 to: 12 do: [ :i |
		session addNavigationItem: (CooNavigationHistoryItem selector: ('selector', i asString) asSymbol) ].

	self assert: session navigationSelectorEntries size equals: 5
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testNavigationEntriesAreDeduplicated [

	session addNavigationItem: (CooNavigationHistoryItem selector: #foo).
	session addNavigationItem: (CooNavigationHistoryItem selector: #foo).
	session addNavigationItem: (CooNavigationHistoryItem selector: #bar).

	self assert: session navigationSelectorEntries size equals: 2
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testNavigationItemDefaultsTimestamp [

	| item |
	item := CooNavigationHistoryItem selector: #foo.

	self assert: item timestamp isNotNil.
	self assert: item isSelectorObservation.
	self deny: item isClassObservation
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testNavigationItemForClassReportsClassKind [

	| item |
	item := CooNavigationHistoryItem class: 'String'.

	self assert: item isClassObservation.
	self deny: item isSelectorObservation.
	self assert: item kind equals: #class.
	self assert: item name equals: 'String'
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testResetNavigationItemsClearsHistory [

	session addNavigationItem: (CooNavigationHistoryItem class: 'Foo').
	session resetNavigationItems.

	self assert: session navigationItems isEmpty.
	self assert: session classEntries isEmpty
]

{ #category : 'running' }
CooClassNavigationHistoryTest >> testScrapperDegradesGracefullyWithoutBrowsers [

	| items |
	items := CooNavigationScrapper new snapshotItems.
	self assert: items isCollection
]
