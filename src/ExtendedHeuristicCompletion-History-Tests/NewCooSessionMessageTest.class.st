Class {
	#name : 'NewCooSessionMessageTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-NewTestForHistory',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'NewTestForHistory'
}

{ #category : 'running' }
NewCooSessionMessageTest >> cache [

	^ session vocabularyCache
]

{ #category : 'running' }
NewCooSessionMessageTest >> modifiedMethodAnnouncement [

	^ CooMockMethodModified
		  methodChangedFrom: self class >> #ourOriginalPrintString
		  to: self class >> #ourModifiedPrintString
		  oldProtocol: 'toto'
]

{ #category : 'tests - compute' }
NewCooSessionMessageTest >> ourModifiedPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."

	self testComputeMessages.
	^ self printStringLimitedTo: 50000
]

{ #category : 'tests - compute' }
NewCooSessionMessageTest >> ourOriginalPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."

	^ self printStringLimitedTo: 50000
]

{ #category : 'running' }
NewCooSessionMessageTest >> removedMethodAnnouncement [

	^ CooMockMethodRemoved new
		  methodOrigin: NewCooSessionMessageTest;
		  method: NewCooSessionMessageTest >> #ourModifiedPrintString
]

{ #category : 'running' }
NewCooSessionMessageTest >> setUp [

	super setUp.
	session := CooXPSession withCache: CooNewTemporalCache new
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddModifiedMethodComputesMessageDiff [

	| announcement |
	announcement := self modifiedMethodAnnouncement.

	session addModifiedMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectorDescriptions first deltaMessages asArray equals: #( #testComputeMessages )
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddModifiedMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.

	session addModifiedMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectors size equals: 1
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddNewMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodAdded for: Point >> #degrees.

	session addNewMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectors size equals: 1
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddedAndRemovedTheSameMethod [
	| announcement |
	announcement := self removedMethodAnnouncement.
	session removeMethodFromVocabulary: announcement.
	
	announcement := self modifiedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	
	self 
		assert: session vocabularyCache selectorDescriptions first deltaMessages asArray
		equals: #( #testComputeMessages )
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddedAndRemovedTheSameMethodShouldRemoveIt [

	| announcement descr |
	self skip.
	announcement := self modifiedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	announcement := self removedMethodAnnouncement.
	session removeMethodFromVocabulary: announcement.
	
	descr := session vocabularyCache selectorDescriptions.
	self assert: descr size equals: 2.
	self assert: descr first selector equals: #ourModifiedPrintString. 
	self assert: descr second selector equals: #ourModifiedPrintString. 
	self assert: session vocabularyCache selectors isEmpty
]

{ #category : 'tests - compute' }
NewCooSessionMessageTest >> testComputeMessages [

	| announcement |
	announcement := CooMockMethodModified
		                methodChangedFrom: self class >> #ourOriginalPrintString
		                to: self class >> #ourModifiedPrintString
		                oldProtocol: 'toto'.

	self assert: (CooNewTemporalCache new computeDeltaMessageOf: announcement) asArray equals: #( #testComputeMessages )
]

{ #category : 'tests - compute' }
NewCooSessionMessageTest >> testComputeMessagesOfSimilarMethods [

	| announcement |
	announcement := CooMockMethodModified methodChangedFrom: self class >> #ourOriginalPrintString to: (self class >> #ourOriginalPrintString) oldProtocol: 'toto'.

	self assert: (CooNewTemporalCache new computeDeltaMessageOf: announcement) isEmpty
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testMethodRemovedDoesNotRemoveOtherMethods [

	| announcement |
	self skip. "should define it first"
	
	announcement := self removedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	announcement := self modifiedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	

]

{ #category : 'tests' }
NewCooSessionMessageTest >> testMethodRemovedRemovedTheMethodFromSelectors [

	| announcement descr |
	announcement := self removedMethodAnnouncement.

	session removeMethodFromVocabulary: announcement.
	descr := session vocabularyCache selectorDescriptions.
	self assert: descr size equals: 1.
	self assert: descr first selector equals: #ourModifiedPrintString. "but we removed the first one."
	self assert: session vocabularyCache selectors isEmpty
]
