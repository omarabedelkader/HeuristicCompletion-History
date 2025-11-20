Class {
	#name : 'CooMessageHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'selector',
		'date',
		'methodClassName',
		'event'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cache2',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cache2'
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
