Class {
	#name : 'CooODescriptionItem',
	#superclass : 'Object',
	#instVars : [
		'selector',
		'event',
		'ast',
		'timestamp'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cache',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cache'
}

{ #category : 'accessing' }
CooODescriptionItem >> ast [

	^ ast
]

{ #category : 'accessing' }
CooODescriptionItem >> ast: anObject [

	ast := anObject
]

{ #category : 'accessing' }
CooODescriptionItem >> event [

	^ event
]

{ #category : 'accessing' }
CooODescriptionItem >> event: anObject [

	event := anObject
]

{ #category : 'accessing' }
CooODescriptionItem >> selector [

	^ selector
]

{ #category : 'accessing' }
CooODescriptionItem >> selector: anObject [

	selector := anObject
]

{ #category : 'accessing' }
CooODescriptionItem >> timestamp [

	^ timestamp
]

{ #category : 'accessing' }
CooODescriptionItem >> timestamp: anObject [

	timestamp := anObject
]
