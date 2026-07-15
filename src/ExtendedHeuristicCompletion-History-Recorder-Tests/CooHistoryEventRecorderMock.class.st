Class {
	#name : 'CooHistoryEventRecorderMock',
	#superclass : 'CooHistoryEventRecorder',
	#instVars : [
		'authorized',
		'deliveryAttempts',
		'loggedEvents'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests-Mocks',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#tag : 'Mocks'
}

{ #category : 'logging' }
CooHistoryEventRecorderMock >> authorizeDataSending [

	authorized := true
]

{ #category : 'accessing' }
CooHistoryEventRecorderMock >> authorized [

	^ authorized
]

{ #category : 'logging' }
CooHistoryEventRecorderMock >> deliverDataNow [

	deliveryAttempts := deliveryAttempts + 1.
	self error
]

{ #category : 'logging' }
CooHistoryEventRecorderMock >> deliverLoggerDataNow [

	^ self deliverDataNow
]

{ #category : 'accessing' }
CooHistoryEventRecorderMock >> deliveryAttempts [

	^ deliveryAttempts
]

{ #category : 'initialization' }
CooHistoryEventRecorderMock >> initialize [

	super initialize.
	authorized := false.
	deliveryAttempts := 0.
	loggedEvents := OrderedCollection new
]

{ #category : 'logging' }
CooHistoryEventRecorderMock >> log: anEventDictionary [

	loggedEvents addLast: anEventDictionary
]

{ #category : 'accessing' }
CooHistoryEventRecorderMock >> loggedEvents [

	^ loggedEvents
]

{ #category : 'initialization' }
CooHistoryEventRecorderMock >> newLogger [

	self authorizeDataSending.
	^ self
]
