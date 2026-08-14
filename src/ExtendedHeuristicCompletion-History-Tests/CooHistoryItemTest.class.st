Class {
	#name : 'CooHistoryItemTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Handlers',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Handlers'
}

{ #category : 'tests' }
CooHistoryItemTest >> testAddedClassEvent [

	self assert: CooAddedClassHistoryItem new event equals: #added
]

{ #category : 'tests' }
CooHistoryItemTest >> testAddedMethodEvent [

	self assert: CooAddedMethodHistoryItem new event equals: #added
]

{ #category : 'tests' }
CooHistoryItemTest >> testClassNameIsStored [

	| item |
	item := CooHistoryItem new.
	item nameOfClass: 'OrderedCollection'.

	self assert: item nameOfClass equals: 'OrderedCollection'
]

{ #category : 'tests' }
CooHistoryItemTest >> testDefaultLiveIsFalse [

	| item |
	item := CooHistoryItem new.
	self assert: (item printString includesSubstring: '(Rep)')
]

{ #category : 'tests' }
CooHistoryItemTest >> testLiveFlagSetToTrue [

	| item |
	item := CooHistoryItem new.
	item live: true.

	self assert: (item printString includesSubstring: '(Liv)')
]

{ #category : 'tests' }
CooHistoryItemTest >> testMethodItemDefaultDeltaMessagesIsEmpty [

	| item |
	item := CooMethodHistoryItem new.

	self assert: item deltaMessages equals: #()
]

{ #category : 'tests' }
CooHistoryItemTest >> testMessageCompletionSelectorRejectsPunctuation [

	#( ',' '.' ';' '+' '->' '<=' ) do: [ :selector |
		self deny:
			(CooMethodHistoryItem isMessageCompletionSelector: selector) ]
]

{ #category : 'tests' }
CooHistoryItemTest >> testMessageCompletionSelectorAcceptsUnaryAndKeywordSelectors [

	self assert:
		(CooMethodHistoryItem isMessageCompletionSelector: #yourself).
	self assert:
		(CooMethodHistoryItem isMessageCompletionSelector: #at:put:)
]

{ #category : 'tests' }
CooHistoryItemTest >> testMessageCompletionSelectorsFromASTFiltersBinarySelectors [

	| ast selectors |
	ast := RBParser parseMethod:
		       'sample | text |
		       self alpha; beta: 1.
		       text := ''a'' , ''b''.
		       ^ 1 + 2'.
	selectors := CooMethodHistoryItem messageCompletionSelectorsFromAST: ast.

	self assert: (selectors includes: #alpha).
	self assert: (selectors includes: #beta:).
	self deny: (selectors includes: #,).
	self deny: (selectors includes: #+)
]

{ #category : 'tests' }
CooHistoryItemTest >> testMethodItemPrintOnShowsSelector [

	| item |
	item := CooMethodHistoryItem new.
	item selector: #collect:.
	item nameOfClass: 'OrderedCollection'.

	self assert: (item printString includesSubstring: 'collect:').
	self assert: (item printString includesSubstring: 'OrderedCollection')
]

{ #category : 'tests' }
CooHistoryItemTest >> testMethodItemStoresAST [

	| item ast |
	ast := RBParser parseMethod: 'sample ^ self alpha'.
	item := CooMethodHistoryItem new.
	item selector: #sample.
	item ast: ast.

	self assert: item ast isNotNil.
	self assert: item ast selector equals: #sample
]

{ #category : 'tests' }
CooHistoryItemTest >> testMethodItemStoresDeltaMessages [

	| item |
	item := CooMethodHistoryItem new.
	item selector: #foo.
	item deltaMessages: #(#alpha #beta).

	self assert: item deltaMessages size equals: 2.
	self assert: (item deltaMessages includes: #alpha).
	self assert: (item deltaMessages includes: #beta)
]

{ #category : 'tests' }
CooHistoryItemTest >> testMethodItemStoresSelector [

	| item |
	item := CooMethodHistoryItem new.
	item selector: #collect:.

	self assert: item selector equals: #collect:
]

{ #category : 'tests' }
CooHistoryItemTest >> testModifiedClassEvent [

	self assert: CooModifiedClassHistoryItem new event equals: #modified
]

{ #category : 'tests' }
CooHistoryItemTest >> testModifiedMethodEvent [

	self assert: CooModifiedMethodHistoryItem new event equals: #modified
]

{ #category : 'tests' }
CooHistoryItemTest >> testPrintOnHandlesNilClassName [
	"When className is nil, printOn should not crash."

	| item |
	item := CooHistoryItem new.

	self assert: (item printString includesSubstring: 'No class name!')
]

{ #category : 'tests' }
CooHistoryItemTest >> testPrintOnShowsClassName [

	| item |
	item := CooHistoryItem new.
	item nameOfClass: 'Point'.

	self assert: (item printString includesSubstring: 'Point')
]

{ #category : 'tests' }
CooHistoryItemTest >> testRemovedClassEvent [

	self assert: CooRemovedClassHistoryItem new event equals: #removed
]

{ #category : 'tests' }
CooHistoryItemTest >> testRemovedMethodEvent [

	self assert: CooRemovedMethodHistoryItem new event equals: #removed
]

{ #category : 'tests' }
CooHistoryItemTest >> testTimestampIsStored [

	| item ts |
	ts := DateAndTime now.
	item := CooHistoryItem new.
	item timestamp: ts.

	self assert: item timestamp equals: ts
]
