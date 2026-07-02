"
I represent the null object for CooHistoryEventecorder

Iam only instanciated when the user does not consent to send his information to the server.

I subclass CooHistoryEventecorder and re-define the following messages : 
"
Class {
	#name : 'CooNullHistoryEventRecorder',
	#superclass : 'CooHistoryEventRecorder',
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Recorder'
}

{ #category : 'actions' }
CooNullHistoryEventRecorder >> deliverNow [
	^ self
]

{ #category : 'actions' }
CooNullHistoryEventRecorder >> deliverNowInBackground [ 
	^ self
]

{ #category : 'initialization' }
CooNullHistoryEventRecorder >> initialize [

	super initialize.
	deliveryEnabled := false.

]
