Class {
	#name : 'CooZnClientMock',
	#superclass : 'ZnClient',
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests'
}

{ #category : 'operations' }
CooZnClientMock >> put [ 
	"do nothing"
]

{ #category : 'operations' }
CooZnClientMock >> response [ 
	^ ZnResponse ok: (ZnEntity text: 'ok')
]
