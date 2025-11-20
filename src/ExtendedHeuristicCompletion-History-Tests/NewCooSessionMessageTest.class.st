Class {
	#name : 'NewCooSessionMessageTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-History',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History'
}

{ #category : 'origins' }
NewCooSessionMessageTest >> cache [

	^ session vocabularyCache
]

{ #category : 'running' }
NewCooSessionMessageTest >> setUp [

	super setUp.
	session := CooXPSession withCache: CooNewTemporalCache new
]

{ #category : 'tests' }
NewCooSessionMessageTest >> testAddNewMethodRegistersEntry [

	| announcement |
	announcement := CooMockMethodAdded for: Point >> #degrees.

	session addNewMethodInVocabulary: announcement.
	self assert: session vocabularyCache selectors size equals: 1
]
