Class {
	#name : 'CooVariableHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'className',
		'date',
		'event',
		'commit'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'accessing' }
CooVariableHistoryItem >> commit [

	^ commit
]

{ #category : 'accessing' }
CooVariableHistoryItem >> commit: anObject [

	commit := anObject
]

{ #category : 'accessing' }
CooVariableHistoryItem >> date [

	^ date
]

{ #category : 'accessing' }
CooVariableHistoryItem >> date: anObject [

	date := anObject
]

{ #category : 'accessing' }
CooVariableHistoryItem >> event [

	^ event
]

{ #category : 'accessing' }
CooVariableHistoryItem >> event: anObject [

	event := anObject
]

{ #category : 'accessing' }
CooVariableHistoryItem >> nameOfClass [

	^ className
]

{ #category : 'accessing' }
CooVariableHistoryItem >> nameOfClass: aClassName [

	className := aClassName
]
