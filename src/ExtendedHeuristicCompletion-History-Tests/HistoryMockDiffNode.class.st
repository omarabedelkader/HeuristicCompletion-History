Class {
	#name : 'HistoryMockDiffNode',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockDiffNode class >> value: anObject [
    ^ self new
        value: anObject;
        yourself
]

{ #category : 'accessing' }
HistoryMockDiffNode >> value [
    ^ value
]

{ #category : 'accessing' }
HistoryMockDiffNode >> value: anObject [
    value := anObject
]
