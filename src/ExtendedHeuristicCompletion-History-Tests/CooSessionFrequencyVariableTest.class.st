Class {
	#name : 'CooSessionFrequencyVariableTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-History',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History'
}

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> cache [

	^ session vocabularyCache
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
	self assert: (entry at: #addedCount) equals: 1.
	self assert: (entry at: #selectedCount) equals: 0.
	self assert: (entry at: #lastSeen) equals: timestamp
]

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> testRegisterClassAccumulatesCounts [

    | timestampOlder timestampRecent entry |
    timestampOlder := DateAndTime now.
    timestampRecent := timestampOlder + (Duration seconds: 3).
    session registerClass: #TrackedFrequency event: #added at: timestampOlder.
    session registerClass: #TrackedFrequency event: #selected at: timestampRecent.
    entry := self cache at: #TrackedFrequency.
    self assert: (entry at: #addedCount) = 1.
    self assert: (entry at: #selectedCount) = 1.
    self assert: (entry at: #lastSeen) = timestampRecent
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

{ #category : 'origins' }
CooSessionFrequencyVariableTest >> testUnknownEventDoesNotChangeCounters [

    | timestamp entry |
    timestamp := DateAndTime now.
    session registerClass: #UnknownEvent event: #added at: timestamp.
    session registerClass: #UnknownEvent event: #mystery at: timestamp.
    entry := self cache at: #UnknownEvent.
    self assert: (entry at: #addedCount) = 1.
    self assert: (entry at: #selectedCount) = 0.
    self assert: (entry at: #lastSeen) = timestamp
]
