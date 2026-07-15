"
I represent the null value for the recorder.
I am meant to be used when the user does not give their consent to send their data to the remote server.
I do not record items nor send them to the remote.

I can be instantiated either when the image starts and the user selects NO on the popup, or when the user disables this extension from the settings menu, or manually via CooSession >> disableDelivery.
"
Class {
	#name : 'CooNullHistoryEventRecorder',
	#superclass : 'CooHistoryEventRecorder',
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'actions' }
CooNullHistoryEventRecorder >> deliverNow [ 
	^ self
]

{ #category : 'actions' }
CooNullHistoryEventRecorder >> deliverNowInBackground [ 
	^ self
]

{ #category : 'actions' }
CooNullHistoryEventRecorder >> deliveryEnabled [ 

	^ false
]

{ #category : 'actions' }
CooNullHistoryEventRecorder >> disableDelivery [
	CooSession current recorder: self class uniqueInstance
]

{ #category : 'actions' }
CooNullHistoryEventRecorder >> enableDelivery [
	CooSession current recorder: CooHistoryEventRecorder uniqueInstance 
]

{ #category : 'initialization' }
CooNullHistoryEventRecorder >> initialize [ 
	super initialize.
	deliveryEnabled := false.
]

{ #category : 'actions' }
CooNullHistoryEventRecorder >> install [

	self deinstall.

	
	Iceberg announcer unsubscribe: self.
	

	installed := true.
	
	logger := nil.
	

	^ self
]
