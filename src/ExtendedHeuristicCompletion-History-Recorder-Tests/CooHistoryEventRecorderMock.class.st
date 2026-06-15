Class {
	#name : 'CooHistoryEventRecorderMock',
	#superclass : 'CooHistoryEventRecorder',
	#instVars : [
		'counter'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests'
}

{ #category : 'accessing' }
CooHistoryEventRecorderMock >> counter [ 
	^ counter
]

{ #category : 'setter' }
CooHistoryEventRecorderMock >> counter: aNumber [ 
	counter := aNumber 
]

{ #category : 'accessing' }
CooHistoryEventRecorderMock >> environment [ 
	^ self class environment copyWithout: #STON
]

{ #category : 'operations' }
CooHistoryEventRecorderMock >> increment [ 
	counter := counter + 1
]

{ #category : 'initialization' }
CooHistoryEventRecorderMock >> initialize [ 
	super initialize.
	counter := 0
]
