Class {
	#name : 'NewCooSessionVariableTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-History',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History'
}

{ #category : 'tests' }
NewCooSessionVariableTest >> testAddNewVariableAnnouncementRegistersEntry [

	| announcement entry |
	announcement := CooMockClassAddedAnnouncement for: #TemporalMock.
	session addNewVariableInVocabulary: announcement.

	entry := session vocabularyCache variableDescriptions first.

	self assert: session vocabularyCache names size equals: 1.
	self assert: entry event equals: #added.

]
