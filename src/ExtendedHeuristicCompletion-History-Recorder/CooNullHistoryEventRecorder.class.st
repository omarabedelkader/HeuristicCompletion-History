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
