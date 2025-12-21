"
I'm a simple datastructure like object that represents history event.
live means that I have been created during a live session and not during a replay.
"
Class {
	#name : 'CooHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'date',
		'commit',
		'event',
		'className',
		'live'
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

{ #category : 'initialization' }
CooHistoryItem >> initialize [ 

	super initialize.
	live := true
]

{ #category : 'accessing' }
CooHistoryItem >> nameOfClass [

	^ className
]

{ #category : 'accessing' }
CooHistoryItem >> nameOfClass: aClassName [

	className := aClassName
]
