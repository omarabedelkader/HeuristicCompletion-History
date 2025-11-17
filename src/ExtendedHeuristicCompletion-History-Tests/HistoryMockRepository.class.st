Class {
	#name : 'HistoryMockRepository',
	#superclass : 'Object',
	#instVars : [
		'head',
		'fetchCount'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockRepository >> fetch [
    fetchCount := (fetchCount ifNil: [ 0 ]) + 1
]

{ #category : 'accessing' }
HistoryMockRepository >> fetchCount [
    ^ fetchCount ifNil: [ 0 ]
]

{ #category : 'accessing' }
HistoryMockRepository >> head [
    ^ head
]

{ #category : 'accessing' }
HistoryMockRepository >> head: anObject [
    head := anObject
]
