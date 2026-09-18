Class {
	#name : 'CooHistoryEventRecorderTest',
	#superclass : 'TestCase',
	#instVars : [
		'recorder',
		'initialSubscriptionNumber'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests-Core',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
CooHistoryEventRecorderTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	recorder := CooHistoryEventRecorder uniqueInstance.

	recorder announcer unsubscribe: recorder.
	initialSubscriptionNumber := recorder announcer numberOfSubscriptions.

	recorder deliveryEnabled: true.
	recorder deliveryBatchSize: 100.

	recorder drainPendingEvents.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testBlockValue [
    | block errBlock result |
    block := [ |str|
        str := 'foo'.
        str, 'bar' ].
    errBlock := [ 'fallback' ].
    result := recorder safeValue: block ifError: errBlock.
    self assert: result equals: 'foobar'
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testBlockValueWhenBlockThrowAnException [
    | block errBlock result |
    block := [ |str|
        str := 'foo'.
        str := str + 1 ].
    errBlock := [ 'fallback' ].
    result := recorder safeValue: block ifError: errBlock.
    self assert: result equals: 'fallback'
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testCategoryFieldValueContainsNonEmptyMetadataStrings [

	| metadata |
	recorder category: #complishon.
	recorder experienceId: 'complishon'.
	recorder participantUUID: UUID new asString.
	recorder taskOrSurveyId: UUID new asString.

	metadata := STON fromString:
		(recorder categoryFieldValue: #complishon).

	self assert: metadata size equals: 4.
	self assert: (metadata at: 'category') equals: 'complishon'.
	self assert: (metadata at: 'experienceId') equals: recorder experienceId asString.
	self assert: (metadata at: 'participantUUID') equals: recorder participantUUID asString.
	self assert: (metadata at: 'taskOrSurveyId') equals: recorder taskOrSurveyId asString.

	#('category' 'experienceId' 'participantUUID' 'taskOrSurveyId') do: [ :eachKey |
		self
			assert: (metadata at: eachKey) isString
			description: eachKey , ' must be a String'.
		self
			deny: (metadata at: eachKey) isEmpty
			description: eachKey , ' must not be empty' ]

]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testClassSideDeliverNowDelegatesToUniqueInstance [

	recorder drainPendingEvents.
	self assert: recorder pendingEvents isEmpty.

	self assert: CooHistoryEventRecorder deliverNow equals: recorder
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeliverNowInBackgroundDoesNotForkWhenProcessAlreadyRunning [
    | firstProcess |
	"we try to fork two times, if the fork is not terminated we will not create another one "
    recorder deliveryEnabled: true.

    firstProcess := Processor activeProcess.
    recorder instVarNamed: 'deliveryProcess' put: firstProcess.

    recorder deliverNowInBackground.

    self assert: recorder deliveryProcess equals: firstProcess.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeliverNowInBackgroundDoesNothingWhenDeliveryDisabled [
    recorder deliveryEnabled: false.
    self assert: recorder deliverNowInBackground equals: recorder
    
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeliverNowInBackgroundForksAProcess [
	"When delivery is enabled, a new process willl be created"
    recorder deliveryEnabled: true.
    recorder deliverNowInBackground.
    self assert: recorder deliveryProcess notNil.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeliverNowWhenDisabled [ 
	recorder deliveryEnabled: false. 
	
	self assert: (recorder deliverNow ) equals: recorder 
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeliverNowWhenEmptyListOfEvents [
	
	recorder drainPendingEvents.
	self assert: recorder pendingEvents isEmpty.
	self assert: (recorder deliverNow ) equals: recorder 
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testEnqueueEventDoesNotDeliverBeforeBatchSize [

	recorder deliveryEnabled: true.
	recorder deliveryBatchSize: 3.

	recorder enqueueEvent: (Dictionary new
			 at: #kind put: #test;
			 yourself).
	recorder enqueueEvent: (Dictionary new
			 at: #kind put: #test;
			 yourself).

	self deny: recorder shouldDeliverPendingEvents.
	self assert: recorder pendingEvents size equals: 2.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testImageCloseSurveyPayloadDictionary [

	| payload event |
	payload := Dictionary new
		at: #surveyName put: 'image-close-survey';
		yourself.

	event := recorder dictionaryForImageCloseSurveyPayload: payload.

	self assert: (event at: #kind) equals: #survey.
	self assert: (event at: #event) equals: #imageCloseSurvey.
	self assert: (event at: #payload) equals: payload.
	self assert: (event includesKey: #timestamp).
	self assert: (event includesKey: #serverUrl).
	self assert: (event includesKey: #category)
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testIncludesInstanceOfDoesNotMatchSubclass [

    | collection |
	"CooHistoryEventRecorderMock is a subInsctance of CooHistoryEventRecorder, it should return false"
    collection := OrderedCollection new
		add: LargeInteger new;
		yourself .
		
    self deny: (recorder includesInstanceOf: LargePositiveInteger in: collection).
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testIncludesInstanceOfReturnsFalseWhenAbsent [
    | collection |

    collection := OrderedCollection new
		add: CooSessionMessagesHeuristic new;
		add: CooSessionVariableHeuristic new;
		yourself .

    self deny: (recorder includesInstanceOf: CooHistoryEventRecorder in: collection).

]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testIncludesInstanceOfReturnsFalseWhenEmpty [
    self deny: (recorder includesInstanceOf: CooSessionMessagesHeuristic in: OrderedCollection new).
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testIncludesInstanceOfReturnsTrueWhenPresent [
    | collection |
    collection := OrderedCollection new
		add: CooSessionMessagesHeuristic new;
		add: CooSessionVariableHeuristic new;
		yourself .
    self assert: (recorder includesInstanceOf: CooSessionMessagesHeuristic in: collection).
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testInstallAuthorizesEventRecorderLogger [

	recorder := CooHistoryEventRecorderMock new.
	recorder install.

	self assert: recorder installed.
	self assert: recorder authorized.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testNewLoggerRejectsMissingParticipantUUID [

	recorder participantUUID: ''.

	self
		should: [ recorder newLogger ]
		raise: Error
		whoseDescriptionIncludes: 'participantUUID'
		description: 'A PX collector must never be created without a participantUUID'
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testPrepareForImageSaveWhenErrorShouldKeepEvents [
 
	| batchSize |
	recorder := CooHistoryEventRecorderMock new. 
	recorder install.
	
	batchSize := recorder deliveryBatchSize.

	1 to: batchSize do:

	[ :i | recorder enqueueEvent: (Dictionary new
			 at: #kind put: #test;
			 yourself).].
	
	recorder prepareForImageSave.

	self assert: recorder pendingEvents size equals: batchSize.
	
	recorder enqueueEvent: (Dictionary new
			 at: #kind put: #test;
			 yourself). 
	
	recorder prepareForImageSave.

	self assert: recorder pendingEvents size equals: batchSize + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testRecordRemoteDeliveryEnabledAttemptsImmediateDelivery [

	recorder := CooHistoryEventRecorderMock new.
	recorder deliveryEnabled: true.
	recorder deliveryBatchSize: 1.
	recorder install.

	recorder recordRemoteDeliveryEnabled.
	recorder waitForDeliveryProcess.

	self assert: recorder loggedEvents size equals: 1.
	self assert: (recorder loggedEvents first at: #kind) equals: #recorder.
	self assert: (recorder loggedEvents first at: #event) equals: #remoteDeliveryEnabled.
	self assert: recorder deliveryAttempts equals: 1.
	self assert: recorder lastDeliveryError notNil.
	self assert: recorder pendingEvents size equals: 1.
	self assert: (recorder pendingEvents first at: #kind) equals: #recorder.
	self assert: (recorder pendingEvents first at: #event) equals: #remoteDeliveryEnabled.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testRecorderEventDictionary [

	| event |
	recorder serverUrl: 'https://example.com/collector'.
	recorder category: #complishon.

	event := recorder dictionaryForRecorderEvent: #remoteDeliveryEnabled.

	self assert: (event at: #kind) equals: #recorder.
	self assert: (event at: #event) equals: #remoteDeliveryEnabled.
	self assert: (event at: #serverUrl) equals: 'https://example.com/collector'.
	self assert: (event at: #category) equals: 'complishon'.
	self assert: (event includesKey: #timestamp).
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testRemoteConfigurationHasNonEmptyTaskOrSurveyId [ 

	| taskOrSurveyId |
	taskOrSurveyId := recorder taskOrSurveyId.

	self
		deny: taskOrSurveyId isNil
		description: 'taskOrSurveyId must never be nil'.

	self assert: taskOrSurveyId isString.
	self deny: taskOrSurveyId isEmpty.

	"It must stay stable on this recorder instance."
	self assert: recorder taskOrSurveyId equals: taskOrSurveyId
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSelectorOf [
	self assert: (recorder selectorOf: (Object >> #printString)) equals: #printString
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSelectorOfAnnouncementWhenMethodIsNil [
	|announcement|
	announcement := MethodAdded new method: (Object >> #printString).
	self assert: (recorder selectorOf: nil announcement: announcement) equals: #printString
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSelectorOfAnnouncementWhenMethodResponds [
	self assert: (recorder selectorOf: (Object >> #printString) announcement: nil) equals: #printString
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSelectorOfAnnouncementWhenNoResponse [
	"We send a random object and a random announcement"
	self assert: (recorder selectorOf: Object new announcement: MethodAdded new) equals: nil
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSelectorOfWhenMethodIsNil [
	self assert: (recorder selectorOf: nil) equals: nil
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSerializePayload [
	| payload result expectedString |

	payload := Dictionary new.
	payload at: 'key' put: 'value'.
	expectedString := STON toString: payload .
	result := recorder serializePayload: payload.

	self assert: result equals: expectedString utf8Encoded.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSend [

	recorder subscribeAnnouncementNamed: #ClassRemoved send: #classRemoved:.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClass [
    | result |
    result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #classAdded:.
    self assert: result equals: recorder.
    self assert: recorder announcer numberOfSubscriptions equals: initialSubscriptionNumber.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelector [
    self assert: (recorder valueFrom: -1  selector: #abs) equals: 1
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelectorWhenException [

    self assert: (recorder valueFrom: '1' selector: #abs) equals: nil
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelectorWhenObjectIsNil [
	
	self assert: (recorder valueFrom: (nil) selector: #increment) equals: nil
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelectorWhenUnknownSelector [
	self assert: (recorder valueFrom: 1 selector: #unknownSelector) equals: nil
	
]
