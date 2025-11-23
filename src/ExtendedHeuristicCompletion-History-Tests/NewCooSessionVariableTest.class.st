Class {
	#name : 'NewCooSessionVariableTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-NewTestForHistory',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'NewTestForHistory'
}

{ #category : 'tests' }
NewCooSessionVariableTest >> testAddNewVariableAnnouncementRegistersEntry [

	| announcement entry |
	announcement := CooMockClassAddedAnnouncement for: NewCooSessionVariableTest.
	session addNewVariableInVocabulary: announcement.

	entry := session vocabularyCache variableDescriptions first.

	self assert: session vocabularyCache variableNames size equals: 1.
	self assert: entry event equals: #added
]
