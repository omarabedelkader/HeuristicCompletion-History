Class {
	#name : 'HistoryMockHead',
	#superclass : 'Object',
	#instVars : [
		'walk'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockHead >> walk: anObject [
    walk := anObject
]

{ #category : 'accessing' }
HistoryMockHead >> withCommitWalkDo: aBlock [
    ^ aBlock value: walk
]
