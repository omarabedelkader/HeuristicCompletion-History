Class {
	#name : 'CooHistoryEventRecorderTest',
	#superclass : 'TestCase',
	#instVars : [
		'recorder',
		'initialSubscriptionNumber'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests'
}

{ #category : 'running' }
CooHistoryEventRecorderTest >> setUp [
	super setUp.

	"Put here a common initialization logic for tests"
	recorder := CooHistoryEventRecorderMock uniqueInstance.
	recorder announcer: CooHistoryEventRecorder codeChangeAnnouncer.
	"never reset subscription, it will damage the image"

	initialSubscriptionNumber := recorder announcer numberOfSubscriptions.
]

{ #category : 'running' }
CooHistoryEventRecorderTest >> tearDown [ 
	recorder := nil.
	super tearDown
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
CooHistoryEventRecorderTest >> testMessageSelectorsInNilReturnsEmpty [
    self assert: (recorder messageSelectorsIn: nil) equals: #().
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testMessageSelectorsInNoMessageSends [
    | ast result |

    ast := OCParser parseMethod: 'myMethod
        ^ 42'.
    result := recorder messageSelectorsIn: ast.
    self assert: result isEmpty.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testMessageSelectorsInReturnsSelectorsFromAst [
    | ast result |
    ast := OCParser parseMethod: 
        'foo 
            | x |
            x := self bar.
            x := x baz + x bar.
            ^ x printString
        '.
    result := recorder messageSelectorsIn: ast.

    self assert: result isNotEmpty.
    self assert: (result includes: #bar).
    self assert: (result includes: #baz).
    self assert: (result includes: #+).
    self assert: (result includes: #printString).
	"foo is a method node"
    self assert: (result includes: #foo) not.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testMethodFromReturnsCompiledMethod [
    | ann result |

    ann := MethodAdded new.
    ann method: (Object >> #printString).

    result := recorder methodFrom: ann.

    self assert: result notNil.
    self assert: result selector equals: #printString.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testMethodFromReturnsNilWhenNoValidMethod [
    | ann result |

    ann := MethodAdded new.

    result := recorder methodFrom: ann.
    self assert: result isNil.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testNormalizedClassNameFromNilReturnsNil [
    self assert: (recorder normalizedClassNameFrom: nil) isNil.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testNormalizedClassNameFromObjectWithName [
    self assert: (recorder normalizedClassNameFrom: OrderedCollection) equals: 'OrderedCollection'.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testNormalizedClassNameFromObjectWithoutName [
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testNormalizedClassNameFromObsoleteClass [
    "strips the AnObsolete prefix"
    | mock |
    mock := CoMockClass new.
    mock name: 'AnObsoleteMyClass'.
    self assert: (recorder normalizedClassNameFrom: mock) equals: 'MyClass'.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testOldMethodFromReturnsCompiledMethod [

    | ann result compiledMethod |

    compiledMethod := Object >> #printString.
    ann := MethodModified new.
    ann oldMethod: compiledMethod.
    result := recorder oldMethodFrom: ann.
    self assert: result notNil.
    self assert: result selector equals: #printString.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testOldMethodFromWithNonCompatibleAnnouncement [

    | ann result compiledMethod |
	"We just useed another subclass of MethodAnnouncement, wee could also try with nil or any other class"
    compiledMethod := Object >> #printString.
    ann := MethodAdded new.
    ann method: compiledMethod.

    result := recorder oldMethodFrom: ann.
    self assert: result isNil.

]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testRecordClassItem [
    | item ann |
    recorder drainPendingEvents.
    self assert: recorder pendingEvents isEmpty.

    ann := ClassAdded new.
    item := CooAddedClassHistoryItem new
        nameOfClass: 'MyClass';
        timestamp: DateAndTime now;
        yourself.

    recorder recordClassItem: item announcement: ann.

    self assert: recorder session classDescriptions first equals: item.

    self assert: recorder pendingEvents size equals: 1.
    self assert: (recorder pendingEvents first at: #kind) equals: #class.
    self assert: (recorder pendingEvents first at: #className) equals: 'MyClass'.
    self assert: (recorder pendingEvents first at: #announcementClass) equals: ann class name.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testRecordMethodItem [
    | item ann |
    recorder drainPendingEvents.
    self assert: recorder pendingEvents isEmpty.

    ann := MethodAdded new.
    item := CooAddedMethodHistoryItem new
        nameOfClass: 'MyClass';
        selector: #myMethod;
        timestamp: DateAndTime now;
        deltaMessages: #();
        yourself.

    recorder recordMethodItem: item announcement: ann.

    self assert: recorder session methodDescriptions first equals: item.

    self assert: recorder pendingEvents size equals: 1.
    self assert: (recorder pendingEvents first at: #kind) equals: #method.
    self assert: (recorder pendingEvents first at: #className) equals: 'MyClass'.
    self assert: (recorder pendingEvents first at: #selector) equals: #myMethod asString.
    self assert: (recorder pendingEvents first at: #announcementClass) equals: ann class name.
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
	
	recorder := CooHistoryEventRecorderMock new. 

	payload := Dictionary new.
	payload at: 'key' put: 'value'.
	expectedString := STON toString: payload .
	result := recorder serializePayload: payload.

	self assert: result equals: expectedString utf8Encoded.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenAddingClass [

	recorder subscribeAnnouncementNamed: #ClassAdded send: #classAdded:.

	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenAddingMethod [

	recorder subscribeAnnouncementNamed: #MethodAdded send: #methodAdded:.

	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenModifiyingMethod [

	recorder subscribeAnnouncementNamed: #MethodModified send: #methodModified:.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClassWhenAddingClass [ 
	
	| result |
	
	
	result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #classAdded:.
	
	
	self assert: (result) equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClassWhenAddingMethod [ 
	
	| result |
	
	
	result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #methodAdded:.
	
	
	self assert: (result) equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClassWhenModifiyingMethod [ 
	
	| result |
	
	
	result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #methodModified:.
	
	self assert: (result) equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClassWhenRemovingClass [ 
	
	| result |
	
	
	result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #classRemoved:.
	
	self assert: (result) equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClassWhenRemovingMethod [ 
	
	| result |
	
	
	result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #methodRemoved:.
	
	self assert: (result) equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenRemovingClass [

	recorder subscribeAnnouncementNamed: #ClassRemoved send: #classRemoved:.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenRemovingMethod [

	recorder subscribeAnnouncementNamed: #MethodRemoved send: #MethodRemoved:.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelector [
    self assert: (recorder valueFrom: CooHistoryEventRecorderMock new selector: #increment) counter equals: 1
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelectorWhenException [
	|object|
	object := CooHistoryEventRecorderMock new counter: '1'.
    self assert: (recorder valueFrom: object selector: #increment) equals: nil
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelectorWhenObjectIsNil [
	
	self assert: (recorder valueFrom: (nil) selector: #increment) equals: nil
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testValueFromSelectorWhenUnknownSelector [
	self assert: (recorder valueFrom: (CooHistoryEventRecorderMock new) selector: #unknownSelector) equals: nil
	
]
