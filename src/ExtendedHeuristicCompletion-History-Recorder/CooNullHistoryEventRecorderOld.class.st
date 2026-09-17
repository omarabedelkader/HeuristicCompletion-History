"
I represent the null value for the recorder.
I am meant to be used when the user does not give their consent to send their data to the remote server.
I do not record items nor send them to the remote.

I can be instantiated either when the image starts and the user selects NO on the popup, or when the user disables this extension from the settings menu, or manually via CooSession >> disableDelivery.
"
Class {
	#name : 'CooNullHistoryEventRecorderOld',
	#superclass : 'CooHistoryEventRecorder',
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'actions' }
CooNullHistoryEventRecorderOld >> deliverNow [ 
	^ self
]

{ #category : 'actions' }
CooNullHistoryEventRecorderOld >> deliverNowInBackground [ 
	^ self
]

{ #category : 'actions' }
CooNullHistoryEventRecorderOld >> deliveryEnabled [ 

	^ false
]

{ #category : 'actions' }
CooNullHistoryEventRecorderOld >> disableDelivery [
	CooSession current recorder: self class uniqueInstance
]

{ #category : 'actions' }
CooNullHistoryEventRecorderOld >> enableDelivery [
	CooSession current recorder: CooHistoryEventRecorder uniqueInstance 
]

{ #category : 'initialization' }
CooNullHistoryEventRecorderOld >> initialize [ 
	super initialize.
	deliveryEnabled := false.
]

{ #category : 'actions' }
CooNullHistoryEventRecorderOld >> install [

	self deinstall.

	
	Iceberg announcer unsubscribe: self.
	

	installed := true.
	
	logger := nil.
	

	^ self
]
