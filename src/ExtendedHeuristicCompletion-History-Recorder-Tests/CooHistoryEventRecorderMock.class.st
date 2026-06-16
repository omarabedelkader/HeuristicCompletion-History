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

{ #category : 'operations' }
CooHistoryEventRecorderMock >> increment [ 
	counter := counter + 1
]

{ #category : 'initialization' }
CooHistoryEventRecorderMock >> initialize [ 
	super initialize.
	counter := 0
]

{ #category : 'actions' }
CooHistoryEventRecorderMock >> putBytes: aByteArray category: aCategory [
    | client entity |
    entity := self multipartEntityForBytes: aByteArray category: aCategory.
    client := OrderedCollection new.
    client
        beOneShot;
        timeout: 5;
        numberOfRetries: 0;
        url: self serverUrl;
        enforceHttpSuccess: true;
        entity: entity.
    client put.
    ^ client response
]
