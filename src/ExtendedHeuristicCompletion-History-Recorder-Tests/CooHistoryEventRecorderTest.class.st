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
