Class {
	#name : 'HistoryMockCommit',
	#superclass : 'Object',
	#instVars : [
		'diff',
		'datetime',
		'author',
		'shortId',
		'comment'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Gitscrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Gitscrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockCommit class >> diff: aDiff [
    ^ self new
        diff: aDiff;
        yourself
]

{ #category : 'accessing' }
HistoryMockCommit >> author [
    ^ author ifNil: [ 'Mock Author' ]
]

{ #category : 'accessing' }
HistoryMockCommit >> author: aString [
    author := aString
]

{ #category : 'accessing' }
HistoryMockCommit >> comment [
    ^ comment ifNil: [ 'Mock message' ]
]

{ #category : 'accessing' }
HistoryMockCommit >> comment: aString [
    comment := aString
]

{ #category : 'accessing' }
HistoryMockCommit >> datetime [
    ^ datetime ifNil: [ DateAndTime now ]
]

{ #category : 'accessing' }
HistoryMockCommit >> datetime: aDateAndTime [
    datetime := aDateAndTime
]

{ #category : 'accessing' }
HistoryMockCommit >> diff [
    ^ diff
]

{ #category : 'accessing' }
HistoryMockCommit >> diff: aDiff [
    diff := aDiff
]

{ #category : 'accessing' }
HistoryMockCommit >> diffToParent [
    ^ diff
]

{ #category : 'accessing' }
HistoryMockCommit >> shortId [
    ^ shortId ifNil: [ 'mock' ]
]

{ #category : 'accessing' }
HistoryMockCommit >> shortId: aString [
    shortId := aString
]
