"
I am an end-to-end integration test proving that a completion event recorded
by CooHistoryEventRecorder reaches a real PXServerDelegate (the server
implementation of the pharo-data-collector project) and is persisted in the
metadata directory hierarchy:

	data/<category>/<experienceId>/<participantUUID>/<taskOrSurveyId>/

The server runs in-process on an ephemeral port, backed by an in-memory
filesystem. The event travels through the real PXEventCollector,
PXEventRecorder and EREventDelivery stack as a multipart HTTP PUT to /events.
The stored binary payload is unpacked again with the EventRecorder packing
strategy to verify that the completion event survived the full round trip.

These tests require the supplied local PXServer implementation (the one that
maps '/events' and validates four non-empty metadata strings). They skip when
a different PX stack without those features is loaded.
"
Class {
	#name : 'CooHistoryPXServerIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'recorder',
		'delegate',
		'server',
		'fileSystem',
		'originalServerUrl',
		'originalCategory',
		'originalExperienceId',
		'originalParticipantUUID',
		'originalTaskOrSurveyId',
		'originalDeliveryBatchSize',
		'originalDeliveryEnabled'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests-Integration',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#tag : 'Integration'
}

{ #category : 'running' }
CooHistoryPXServerIntegrationTest >> restoreRecorderState [

	recorder deliveryEnabled: originalDeliveryEnabled.
	recorder deliveryBatchSize: originalDeliveryBatchSize.
	recorder serverUrl: originalServerUrl.
	recorder category: originalCategory.
	recorder experienceId: originalExperienceId.
	recorder participantUUID: originalParticipantUUID.
	recorder taskOrSurveyId: originalTaskOrSurveyId
]

{ #category : 'running' }
CooHistoryPXServerIntegrationTest >> setUp [

	super setUp.
	recorder := CooHistoryEventRecorder uniqueInstance.

	self requiresSuppliedPXServer.

	fileSystem := FileSystem memory.
	delegate := PXServerDelegate new.
	delegate dataDirectory: fileSystem workingDirectory / 'data'.
	server := ZnServer on: 0.
	server delegate: delegate.
	server start.

	originalServerUrl := recorder serverUrl.
	originalCategory := recorder category.
	originalExperienceId := recorder experienceId.
	originalParticipantUUID := recorder participantUUID.
	originalTaskOrSurveyId := recorder taskOrSurveyId.
	originalDeliveryBatchSize := recorder deliveryBatchSize.
	originalDeliveryEnabled := recorder deliveryEnabled
]

{ #category : 'running' }
CooHistoryPXServerIntegrationTest >> tearDown [

	recorder deliveryEnabled: false.
	recorder waitForDeliveryProcess.
	recorder deinstall.
	[ PXEventRecorder reset ]
		on: Error
		do: [ "the transport is already gone" nil ].
	server ifNotNil: [ server stop ].
	self restoreRecorderState.
	super tearDown
]

{ #category : 'utilities' }
CooHistoryPXServerIntegrationTest >> eventsDirectoryForParticipant: participantUUID taskOrSurveyId: taskOrSurveyId [

	^ fileSystem workingDirectory / 'data'
		  / 'complishon' / 'complishon'
		  / participantUUID / taskOrSurveyId
]

{ #category : 'utilities' }
CooHistoryPXServerIntegrationTest >> eventsURL [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: 'http://';
			  nextPutAll: NetNameResolver loopBackName;
			  nextPut: $:;
			  print: server serverSocket port;
			  nextPutAll: '/events' ]
]

{ #category : 'running' }
CooHistoryPXServerIntegrationTest >> requiresSuppliedPXServer [
	"The supplied pharo-data-collector PXServer implementation understands
	#dataDirectory: and maps '/events'. Older PX stacks do not; tests that
	cannot run against them are skipped instead of failing."

	(PXServerDelegate new respondsTo: #dataDirectory:) ifTrue: [ ^ self ].

	self skip: 'Requires the supplied pharo-data-collector PXServerDelegate mapping /events'
]

{ #category : 'tests' }
CooHistoryPXServerIntegrationTest >> testCompletionSelectionIsPersistedByPXServer [

	| directory completionFile bytes announcement events completionEvent |
	recorder
		serverUrl: self eventsURL;
		category: #complishon;
		experienceId: 'complishon';
		participantUUID: 'participant-test';
		taskOrSurveyId: 'task-test';
		deliveryBatchSize: 1.
	recorder install.
	recorder enableDelivery.

	recorder enqueueEvent: (Dictionary new
			 at: #kind put: #completion;
			 at: #token put: 'you';
			 at: #index put: 3;
			 at: #selectedItem put: 'yourself';
			 at: #fetchers put: #();
			 at: #choices put: Array with: 'yourself';
			 at: #timestamp put: DateAndTime now asString;
			 yourself).

	recorder waitForDeliveryProcess.
	recorder deliverNow.

	directory := self
		             eventsDirectoryForParticipant: 'participant-test'
		             taskOrSurveyId: 'task-test'.
	completionFile := self waitForOneFileIn: directory.
	self assert: completionFile isNotNil.

	"Unpack the stored EventRecorder payload and verify the event contract."
	bytes := completionFile binaryReadStreamDo: [ :stream | stream upToEnd ].
	announcement := EREventPacking ston unpack: bytes.
	events := announcement data.
	completionEvent := events detect: [ :each |
		                   (each at: #kind) = #completion ].

	self assert: (completionEvent at: #selectedItem) equals: 'yourself'.
	self assert: (completionEvent at: #token) equals: 'you'.
	self assert: (completionEvent at: #index) equals: 3.
	self assert: (completionEvent at: #choices) equals: (Array with: 'yourself').
	self assert: (completionEvent includesKey: #timestamp)
]

{ #category : 'tests' }
CooHistoryPXServerIntegrationTest >> testEventsEndpointAnswersHealthCheck [

	| client |
	client := ZnClient new
		          url: self eventsURL;
		          beOneShot;
		          numberOfRetries: 0;
		          yourself.

	client get.

	self assert: client isSuccess.
	self assert: client contents equals: 'OK' , String crlf
]

{ #category : 'utilities' }
CooHistoryPXServerIntegrationTest >> waitForOneFileIn: aDirectory [

	| deadline |
	deadline := DateAndTime now + 5 seconds.
	[
		aDirectory exists and: [ aDirectory allFiles isNotEmpty ] ]
		whileFalse: [
			DateAndTime now > deadline ifTrue: [ ^ nil ].
			(Delay forMilliseconds: 50) wait ].

	self assert: aDirectory allFiles size equals: 1.
	^ aDirectory allFiles first
]
