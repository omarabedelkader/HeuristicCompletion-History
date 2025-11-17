Class {
	#name : 'HistoryMockCommitWalk',
	#superclass : 'Object',
	#instVars : [
		'maxNumber',
		'commits'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
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
