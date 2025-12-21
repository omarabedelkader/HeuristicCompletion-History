Class {
	#name : 'NewCooSessionTemporalTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-NewTestForHistory',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'NewTestForHistory'
}

{ #category : 'running' }
NewCooSessionTemporalTest >> modifiedMethodAnnouncement [

	^ CooMockMethodModified
		  methodChangedFrom: self class >> #ourOriginalPrintString
		  to: self class >> #ourModifiedPrintString
		  oldProtocol: 'toto'
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> ourModifiedPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString.
	
	The following body is garbage"

	self testComputeMessages.
	^ self printStringLimitedTo: 50000
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> ourOriginalPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString.
	
	The following body is garbage it is just to compute the diff between two method versions."

	^ self printStringLimitedTo: 50000
]

{ #category : 'running' }
NewCooSessionTemporalTest >> removedMethodAnnouncement [

	^ CooMockMethodRemoved new
		  methodOrigin: NewCooSessionTemporalTest;
		  method: NewCooSessionTemporalTest >> #ourModifiedPrintString
]

{ #category : 'running' }
NewCooSessionTemporalTest >> setUp [

	super setUp.
	session := CooXPSession withCache: CooTemporalCache new
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddModifiedMethodComputesMessageDiff [

	| announcement |
	announcement := self modifiedMethodAnnouncement.

	session addModifiedMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectorDescriptions first deltaMessages asArray equals: #( #testComputeMessages )
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddModifiedMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.

	session addModifiedMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectors size equals: 1
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddNewMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodAdded for: Point >> #degrees.

	session addNewMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectors size equals: 1
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddNewVariableAnnouncementRegistersEntry [

	| announcement entry |
	announcement := CooMockClassAddedAnnouncement for: NewCooSessionTemporalTest.
	session addNewVariableInVocabulary: announcement.

	entry := session vocabularyCache variableDescriptions first.

	self assert: session vocabularyCache variableNames size equals: 1.
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddedAndRemovedTheSameMethod [
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
NewCooSessionTemporalTest >> testAddedAndRemovedTheSameMethodShouldRemoveIt [

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
NewCooSessionTemporalTest >> testComputeMessages [

	| announcement |
	announcement := CooMockMethodModified
		                methodChangedFrom: self class >> #ourOriginalPrintString
		                to: self class >> #ourModifiedPrintString
		                oldProtocol: 'toto'.

	self assert: (CooTemporalCache new computeDeltaMessageOf: announcement) asArray equals: #( #testComputeMessages )
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> testComputeMessagesOfSimilarMethods [

	| announcement |
	announcement := CooMockMethodModified methodChangedFrom: self class >> #ourOriginalPrintString to: (self class >> #ourOriginalPrintString) oldProtocol: 'toto'.

	self assert: (CooTemporalCache new computeDeltaMessageOf: announcement) isEmpty
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testMethodRemovedRemovedTheMethodFromSelectors [

	| announcement descr |
	announcement := self removedMethodAnnouncement.

	session removeMethodFromVocabulary: announcement.
	descr := session vocabularyCache selectorDescriptions.
	self assert: descr size equals: 1.
	self assert: descr first selector equals: #ourModifiedPrintString. "but we removed the first one."
	self assert: session vocabularyCache selectors isEmpty
]
