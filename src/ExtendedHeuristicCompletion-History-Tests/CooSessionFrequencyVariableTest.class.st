Class {
	#name : 'CooSessionFrequencyVariableTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Tests'
}

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> cache [

    ^ session instVarNamed: 'vocabularyCache'
]

{ #category : 'running' }
CooSessionFrequencyVariableTest >> setUp [

    super setUp.
    session := CooSessionFrequencyVariable new
]

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> testAddNewVariableAnnouncementRegistersEntry [

    | announcement association entry |
    announcement := CooMockClassAddedAnnouncement for: #Mock.
    session addNewVariableInVocabulary: announcement.
    association := #Mock -> #Mock.
    entry := self cache at: association.
    self assert: session size = 1.
    self assert: (entry at: #addedCount) = 1.
    self assert: (entry at: #selectedCount) = 0.
    self assert: (entry at: #lastSeen) notNil
]

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> testAddVocabularyRecordsMetadata [

    | timestamp entry |
    timestamp := DateAndTime now.
    session addVocabulary: 'Foo' at: timestamp.
    entry := self cache at: 'Foo'.
    self assert: session size = 1.
    self assert: (entry at: #addedCount) = 1.
    self assert: (entry at: #selectedCount) = 0.
    self assert: (entry at: #lastSeen) = timestamp
]

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> testRemoveVariableFromVocabularyDropsAssociation [

    | announcement association removal |
    announcement := CooMockClassAddedAnnouncement for: #Obsolete.
    session addNewVariableInVocabulary: announcement.
    association := #Obsolete -> #Obsolete.
    removal := CooMockClassRemovedAnnouncement for: #Obsolete.
    session removeVariableFromVocabulary: removal.
    self deny: (self cache includesKey: association)
]

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> testSelectionAnnouncementIncrementsCount [

    | variable announcement entry |
    variable := CooMockVariable new.
    announcement := CooMockVariableSelectedAnnouncement for: variable.
    session addVariableInVocabulary: announcement.
    entry := self cache at: CooMockVariable.
    self assert: session size = 1.
    self assert: (entry at: #addedCount) = 0.
    self assert: (entry at: #selectedCount) = 1.
    self assert: (entry at: #lastSeen) notNil
]
