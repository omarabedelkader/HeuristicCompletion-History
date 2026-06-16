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
	recorder := CooHistoryEventRecorder uniqueInstance.

	"never reset subscription, it will damage the image"
	recorder announcer: CooHistoryEventRecorder codeChangeAnnouncer.

	initialSubscriptionNumber := recorder announcer numberOfSubscriptions.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testAddClassItem [
    | ann item classDescriptions|
	classDescriptions := recorder session classDescriptions.
   ann := ClassAdded new.
   ann classAdded: OrderedCollection.
   recorder addClassItemOf: CooAddedClassHistoryItem
		from: ann
      	selectors: #(classAdded classAffected affectedClass behaviorAffected behavior).
	
	self assert: (recorder session classDescriptions first) nameOfClass equals: 'OrderedCollection'
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testAddClassItemWithoutClassName [
    | ann classDescriptions|
	classDescriptions := recorder session classDescriptions.
    ann := ClassAdded new.

    recorder addClassItemOf: CooAddedClassHistoryItem
             from: ann
             selectors: #().
    self assert: (recorder session classDescriptions) equals: classDescriptions .
]

{ #category : 'running' }
CooHistoryEventRecorderTest >> testAstOfCompiledMethodReturnsAst [
   | method result expected|

   Object compile: 'foo ^ 0'.
   method := Object >> #foo.

   result := recorder astOf: method.
	expected := OCParser parseMethod: 'foo ^ 0'.

   self assert: result equals: expected.
    Object removeSelector: #foo.
]

{ #category : 'running' }
CooHistoryEventRecorderTest >> testAstOfNilReturnsNil [
    self assert: (recorder astOf: nil) isNil.
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
    recorder deliverNowInBackground.
    firstProcess := recorder deliveryProcess.
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
CooHistoryEventRecorderTest >> testDeltaMessagesForNilNewAstReturnsEmpty [
	|oldAST|
	oldAST := OCParser parseMethod: '
	foo 
		^1.
	'.
    self assert: (recorder deltaMessagesFor: nil oldAst: oldAST) equals: #().
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeltaMessagesForNilOldAstReturnsAllNewMessages [
    | newAst result |

    newAst := OCParser parseMethod: 'foo
        ^ self bar + self baz'.

    result := recorder deltaMessagesFor: newAst oldAst: nil.

    self assert: (result includes: #bar).
    self assert: (result includes: #baz).
    self assert: (result includes: #+).
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeltaMessagesForReturnsEmptyWhenNoNewMessages [
    | newAst oldAst result |
    newAst := OCParser parseMethod: '
		foo
        ^ self bar
		'.
    oldAst := OCParser parseMethod: '
		foo
        ^ self bar + self baz
		'.
		
    result := recorder deltaMessagesFor: newAst oldAst: oldAst.
    self assert: result isEmpty.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeltaMessagesForReturnsOnlyNewMessages [
    | newAst oldAst result |

    newAst := OCParser parseMethod: '
			foo
        		^ self bar + self baz + self another
		'.

    oldAst := OCParser parseMethod: '
			foo
        		^ self bar + self baz
		'.
		
    result := recorder deltaMessagesFor: newAst oldAst: oldAst.

    self assert: (result includes: #another).
    self assert: (result includes: #bar) not.
    self assert: (result includes: #baz) not.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testDeltaMessagesForWhenMethodShrinks [
    | newAst oldAst result |

	"We do difference, when the new method is shrinked, we should get an empty list of messages"

	newAst := OCParser parseMethod: '
		foo
        ^ self bar
	'.
    oldAst := OCParser parseMethod: '
		foo
        ^ self bar + self baz + self another
	'.
    result := recorder deltaMessagesFor: newAst oldAst: oldAst.

    self assert: result isEmpty.
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
CooHistoryEventRecorderTest >> testInstallCompletionHeuristicsAddsAtFront [
    recorder installCompletionHeuristics.
	
	self assert: CoASTHeuristicsResultSetBuilder messagesHeuristic first class equals: CooSessionMessagesHeuristic.
	self assert: CoASTHeuristicsResultSetBuilder variablesHeuristic first class equals: CooSessionVariableHeuristic.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testInstallCompletionHeuristicsIsIdempotent [

    recorder installCompletionHeuristics.
    recorder installCompletionHeuristics.

    self assert: (CoASTHeuristicsResultSetBuilder messagesHeuristic 
        select: [ :each | each class == CooSessionMessagesHeuristic ]) size equals: 1.
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

{ #category : 'running' }
CooHistoryEventRecorderTest >> testMethodItemFrom [
	| ann |
	ann := MethodAdded new. 
	ann method: (Object >> #printString).

	recorder addMethodItemOf: CooModifiedMethodHistoryItem from: ann oldMethod: (Object >> #printString).
	
	self assert: (recorder session methodDescriptions) first selector equals: 'printString'
]

{ #category : 'running' }
CooHistoryEventRecorderTest >> testMethodItemFromNil [ 
	
	|methodDescription|
	methodDescription := recorder session methodDescriptions.
	self assert: (recorder addMethodItemOf: CooAddedClassHistoryItem new from: nil oldMethod: nil) equals: recorder .
	self assert: (recorder session methodDescriptions) equals: methodDescription
]

{ #category : 'running' }
CooHistoryEventRecorderTest >> testMethodItemFromWithoutSelector [
	| ann methodDescription |
	
	methodDescription := recorder session methodDescriptions.
	ann := MethodAdded new. 
	ann method: CompiledMethod new.
	
	self assert: (recorder addMethodItemOf: CooModifiedMethodHistoryItem from: ann oldMethod: nil) equals: recorder.
	self assert: (recorder session methodDescriptions) equals: methodDescription
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

	recorder subscribeAnnouncementNamed: #MethodRemoved send: #methodRemoved:.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
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
