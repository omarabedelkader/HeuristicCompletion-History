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
CooHistoryEventRecorderTest >> testEnqueueEventAddsToPendingEvents [
    | item ann event |
    recorder drainPendingEvents.
    ann := ClassAdded new.
    item := CooAddedClassHistoryItem new
        nameOfClass: 'MyClass';
        timestamp: DateAndTime now;
        yourself.
    event := recorder dictionaryForClassItem: item announcement: ann.
    recorder enqueueEvent: event.
    self assert: recorder pendingEvents size equals: 1.
    self assert: recorder pendingEvents last equals: event.
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
CooHistoryEventRecorderTest >> testEnqueueEventPreservesOrder [
    | item1 item2 ann1 ann2 event1 event2 |
    recorder drainPendingEvents.
    ann1 := ClassAdded new.
    ann2 := ClassAdded new.
    item1 := CooAddedClassHistoryItem new
        nameOfClass: 'MyClass';
        timestamp: DateAndTime now;
        yourself.
    item2 := CooAddedClassHistoryItem new
        nameOfClass: 'AnotherClass';
        timestamp: DateAndTime now;
        yourself.
    event1 := recorder dictionaryForClassItem: item1 announcement: ann1.
    event2 := recorder dictionaryForClassItem: item2 announcement: ann2.
    recorder enqueueEvent: event1.
    recorder enqueueEvent: event2.
    self assert: recorder pendingEvents size equals: 2.
    self assert: recorder pendingEvents first equals: event1.
    self assert: recorder pendingEvents last equals: event2.
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
CooHistoryEventRecorderTest >> testInstallAuthorizesEventRecorderLogger [

	recorder := CooHistoryEventRecorderMock new.
	recorder install.

	self assert: recorder installed.
	self assert: recorder authorized.
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
CooHistoryEventRecorderTest >> testRequeueEvents [
    | events ann1 ann2 item1 item2 |
    recorder drainPendingEvents.
    self assert: recorder pendingEvents isEmpty.

    ann1 := MethodAdded new.
    ann2 := ClassAdded new.

    item1 := CooAddedMethodHistoryItem new
        nameOfClass: 'MyClass';
        selector: #myMethod;
        timestamp: DateAndTime now;
        deltaMessages: #();
        yourself.

    item2 := CooAddedClassHistoryItem new
        nameOfClass: 'AnotherClass';
        timestamp: DateAndTime now;
        yourself.

    events := OrderedCollection new.
    events add: (recorder dictionaryForMethodItem: item1 announcement: ann1).
    events add: (recorder dictionaryForClassItem: item2 announcement: ann2).

    recorder requeueEvents: events.

    self assert: recorder pendingEvents size equals: 2.
    self assert: recorder pendingEvents first equals: events first.
    self assert: recorder pendingEvents second equals: events second.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testRequeueEventsPreservesOrder [
    | events existingEvents ann1 ann2 ann3 item1 item2 item3 |
    recorder drainPendingEvents.
    self assert: recorder pendingEvents isEmpty.

    ann1 := MethodAdded new.
    ann2 := ClassAdded new.
    ann3 := MethodAdded new.

    item1 := CooAddedMethodHistoryItem new
        nameOfClass: 'MyClass';
        selector: #myMethod;
        timestamp: DateAndTime now;
        deltaMessages: #();
        yourself.
    item2 := CooAddedClassHistoryItem new
        nameOfClass: 'AnotherClass';
        timestamp: DateAndTime now;
        yourself.
    item3 := CooAddedMethodHistoryItem new
        nameOfClass: 'ThirdClass';
        selector: #thirdMethod;
        timestamp: DateAndTime now;
        deltaMessages: #();
        yourself.

    existingEvents := OrderedCollection new.
    existingEvents add: (recorder dictionaryForMethodItem: item3 announcement: ann3).
    recorder requeueEvents: existingEvents.
    self assert: recorder pendingEvents size equals: 1.

    events := OrderedCollection new.
    events add: (recorder dictionaryForMethodItem: item1 announcement: ann1).
    events add: (recorder dictionaryForClassItem: item2 announcement: ann2).
    recorder requeueEvents: events.

    self assert: recorder pendingEvents size equals: 3.
    self assert: recorder pendingEvents first equals: events first.
    self assert: (recorder pendingEvents at: 2) equals: events second.
    self assert: recorder pendingEvents last equals: existingEvents first.
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
