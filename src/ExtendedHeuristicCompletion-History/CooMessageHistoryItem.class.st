Class {
	#name : 'CooMessageHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'selector',
		'date',
		'methodClassName',
		'event',
		'ast',
		'commit',
		'deltaMessages'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'accessing' }
CooMessageHistoryItem >> date [

	^ date
]

{ #category : 'accessing' }
CooMessageHistoryItem >> date: anObject [

	date := anObject
]

{ #category : 'accessing' }
CooMessageHistoryItem >> deltaMessages [
	^ deltaMessages
]

{ #category : 'accessing' }
CooMessageHistoryItem >> deltaMessages: aCollection [ 
	deltaMessages := aCollection
]

{ #category : 'accessing' }
CooMessageHistoryItem >> event: aString [ 
	event := aString
]

{ #category : 'accessing' }
CooMessageHistoryItem >> methodClassName: aClassName [
	methodClassName := aClassName
]

{ #category : 'accessing' }
CooMessageHistoryItem >> selector [

	^ selector
]

{ #category : 'accessing' }
CooMessageHistoryItem >> selector: anObject [

	selector := anObject
]
