Class {
	#name : 'HistoryMockCommitWalk',
	#superclass : 'Object',
	#instVars : [
		'maxNumber',
		'commits'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockCommitWalk >> commits [
    ^ commits ifNil: [ #() ]
]

{ #category : 'accessing' }
HistoryMockCommitWalk >> commits: aCollection [
    commits := aCollection
]

{ #category : 'accessing' }
HistoryMockCommitWalk >> maxNumber [
    ^ maxNumber ifNil: [ 0 ]
]

{ #category : 'accessing' }
HistoryMockCommitWalk >> maxNumber: aNumber [
    maxNumber := aNumber
]
