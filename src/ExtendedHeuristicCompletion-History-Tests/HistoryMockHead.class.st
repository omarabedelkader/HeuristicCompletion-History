Class {
	#name : 'HistoryMockHead',
	#superclass : 'Object',
	#instVars : [
		'walk'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockHead >> walk: anObject [
    walk := anObject
]

{ #category : 'accessing' }
HistoryMockHead >> withCommitWalkDo: aBlock [
    ^ aBlock value: walk
]
