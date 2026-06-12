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
	recorder := CooHistoryEventRecorder new.
	recorder announcer: CooHistoryEventRecorder codeChangeAnnouncer.
	"never reset subscription, it will damage the image"
	initialSubscriptionNumber := recorder announcer numberOfSubscriptions.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenAddingMethod [

	recorder subscribeAnnouncementNamed: #MethodAdded send: #methodAdded:.
	
	Object compile: 'foo ^ 0'.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenAnnoncementIsNotRecognized [
	| result |
	
	result := recorder subscribeAnnouncementNamed: #Something send: #methodAdded:.
	
	Object compile: 'foo ^ 0'.

	self assert: result equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenNotAnnouncementClass [ 
	
	| result |
	
	
	result := recorder subscribeAnnouncementNamed: #OrderedCollection send: #methodAdded:.
	
	Object compile: 'foo ^ 0'.
	
	self assert: (result) equals: recorder .
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber .
]

{ #category : 'tests' }
CooHistoryEventRecorderTest >> testSubscribeAnnouncementNamedSendWhenRemovingMethod [

	recorder subscribeAnnouncementNamed: #MethodRemoved send: #methodRemoved:.
	
	Object compile: 'foo ^ 0'.
	
	self assert: (recorder announcer numberOfSubscriptions ) equals: initialSubscriptionNumber + 1.
]
