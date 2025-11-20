Class {
	#name : 'NewCooSessionMessageTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-History',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History'
}

{ #category : 'origins' }
NewCooSessionMessageTest >> cache [

	^ session vocabularyCache
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
NewCooSessionMessageTest >> setUp [

	super setUp.
	session := CooXPSession withCache: CooNewTemporalCache new
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddModifiedMethodComputesMessageDiff [

		| announcement |
	announcement := CooMockMethodModified
		                methodChangedFrom: self class >> #ourOriginalPrintString
		                to: self class >> #ourModifiedPrintString
		                oldProtocol: 'toto'.

	session addModifiedMethodInVocabulary: announcement.
	self 
		assert: session vocabularyCache selectorDescriptions first deltaMessages asArray
		equals: #( #testComputeMessages )
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
