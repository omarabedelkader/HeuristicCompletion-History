Class {
	#name : 'NewCooSessionTemporalTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
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
	"Pay attention for now running the tests will empty the session cache."
	
	session := CooSession withCache: CooTemporalHandler new
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddModifiedMethodComputesMessageDiff [

	| announcement |
	announcement := self modifiedMethodAnnouncement.

	session addModifiedMethodInVocabulary: announcement.
	self assert: session programEntityHandler methodDescriptions first deltaMessages asArray equals: #( #testComputeMessages )
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddModifiedMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.

	session addModifiedMethodInVocabulary: announcement.
	self assert: session programEntityHandler selectorEntries size equals: 1
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddNewMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodAdded for: Point >> #degrees.

	session addNewMethodInVocabulary: announcement.
	self assert: session programEntityHandler selectorEntries size equals: 1
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddNewVariableAnnouncementRegistersEntry [

	| announcement entry |
	announcement := CooMockClassAddedAnnouncement for: NewCooSessionTemporalTest.
	session addNewClassInVocabulary: announcement.

	entry := session programEntityHandler classDescriptions first.

	self assert: session programEntityHandler classEntries size equals: 1.
]

{ #category : 'tests' }
NewCooSessionTemporalTest >> testAddedAndRemovedTheSameMethod [
	| announcement |
	announcement := self removedMethodAnnouncement.
	session removeMethodFromVocabulary: announcement.
	
	announcement := self modifiedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	
	self 
		assert: session programEntityHandler methodDescriptions first deltaMessages asArray
		equals: #( #testComputeMessages )
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> testComputeMessages [

	| announcement |
	announcement := CooMockMethodModified
		                methodChangedFrom: self class >> #ourOriginalPrintString
		                to: self class >> #ourModifiedPrintString
		                oldProtocol: 'toto'.

	self assert: (CooTemporalHandler new computeDeltaMessageOf: announcement) asArray equals: #( #testComputeMessages )
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> testComputeMessagesOfSimilarMethods [

	| announcement |
	announcement := CooMockMethodModified methodChangedFrom: self class >> #ourOriginalPrintString to: (self class >> #ourOriginalPrintString) oldProtocol: 'toto'.

	self assert: (CooTemporalHandler new computeDeltaMessageOf: announcement) isEmpty
]
