Class {
	#name : 'CooHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'date',
		'commit',
		'event',
		'className'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'accessing' }
CooHistoryItem >> date [

	^ date
]

{ #category : 'accessing' }
CooHistoryItem >> date: anObject [

	date := anObject
]

{ #category : 'accessing' }
CooHistoryItem >> event [

	^ event
]

{ #category : 'accessing' }
CooHistoryItem >> event: aString [ 
	event := aString
]

{ #category : 'accessing' }
CooHistoryItem >> nameOfClass [

	^ className
]

{ #category : 'accessing' }
CooHistoryItem >> nameOfClass: aClassName [

	className := aClassName
]
