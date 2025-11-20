Class {
	#name : 'CooSessionTemporalVariableTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-History',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History'
}

{ #category : 'origins' }
CooSessionTemporalVariableTest >> cache [

	^ session vocabularyCache
]

{ #category : 'origins' }
CooSessionTemporalVariableTest >> setUp [
    super setUp.
    session := CooSessionTemporalVariable new
]

{ #category : 'origins' }
CooSessionTemporalVariableTest >> testAddNewVariableAnnouncementRegistersEntry [

    | announcement association entry |
    announcement := CooMockClassAddedAnnouncement for: #TemporalMock.
    session addNewVariableInVocabulary: announcement.
    association := #TemporalMock -> #TemporalMock.
    entry := self cache at: association.
    self assert: session size = 1.
    self assert: (entry at: #event) = #added.
    self assert: (entry at: #lastSeen) notNil
]

{ #category : 'origins' }
CooSessionTemporalVariableTest >> testAddVocabularyRecordsMetadata [

    | timestamp entry |
    timestamp := DateAndTime now.
    session addVocabulary: 'TemporalFoo' at: timestamp.
    entry := self cache at: 'TemporalFoo'.
    self assert: session size = 1.
    self assert: (entry at: #event) = #added.
    self assert: (entry at: #lastSeen) = timestamp
]

{ #category : 'tests' }
CooSessionTemporalVariableTest >> testRegisterClassUpdatesExistingEntry [

    | timestampOlder timestampRecent entry |
    timestampOlder := DateAndTime now.
    timestampRecent := timestampOlder + (Duration seconds: 5).
    session registerClass: #TemporalTracked event: #added at: timestampOlder.
    session registerClass: #TemporalTracked event: #selected at: timestampRecent.
    entry := self cache at: #TemporalTracked.
    self assert: (entry at: #event) = #selected.
    self assert: (entry at: #lastSeen) = timestampRecent
]

{ #category : 'origins' }
CooSessionTemporalVariableTest >> testRemoveVariableFromVocabularyDropsAssociation [

    | announcement association removal |
    announcement := CooMockClassAddedAnnouncement for: #TemporalObsolete.
    session addNewVariableInVocabulary: announcement.
    association := #TemporalObsolete -> #TemporalObsolete.
    removal := CooMockClassRemovedAnnouncement for: #TemporalObsolete.
    session removeVariableFromVocabulary: removal.
    self deny: (self cache includesKey: association)
]

{ #category : 'origins' }
CooSessionTemporalVariableTest >> testSelectionAnnouncementUpdatesEntry [

	| variable announcement entry |
	variable := CooMockVariable new.
	announcement := CooMockVariableSelectedAnnouncement for: variable.
	session addVariableInVocabulary: announcement.
	entry := self cache at: CooMockVariable.
	self assert: session size equals:  1.
	self assert: (entry event) equals: #selected.
	self assert: (entry lastSeen) notNil
]

{ #category : 'tests' }
CooSessionTemporalVariableTest >> testWordsReflectTrackedAssociations [

	| announcement |
	announcement := CooMockClassAddedAnnouncement for: #TemporalWord.
	session addNewVariableInVocabulary: announcement.
	self assert: session words size equals: 1.
	self assert: (session words includes: #TemporalWord -> #TemporalWord)
]
