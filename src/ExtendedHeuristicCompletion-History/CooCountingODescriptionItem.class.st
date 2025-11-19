Class {
	#name : 'CooCountingODescriptionItem',
	#superclass : 'CooODescriptionItem',
	#instVars : [
		'lastSeen',
		'addedCount',
		'modifiedCount',
		'selectedCount'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cache',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cache'
}

{ #category : 'accessing' }
CooCountingODescriptionItem >> addedCount [

	^ addedCount
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> addedCount: anObject [

	addedCount := anObject
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> incrementAdded [

	addedCount := addedCount + 1
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> incrementModified [

	modifiedCount := modifiedCount + 1
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> incrementSelected [

	selectedCount := selectedCount + 1
]

{ #category : 'initialization' }
CooCountingODescriptionItem >> initialize [

	super initialize.
	addedCount := 0.
	modifiedCount := 0.
	selectedCount := 0
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> lastSeen [

	^ lastSeen
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> lastSeen: anObject [

	lastSeen := anObject
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> modifiedCount [

	^ modifiedCount
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> modifiedCount: anObject [

	modifiedCount := anObject
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> selectedCount [

	^ selectedCount
]

{ #category : 'accessing' }
CooCountingODescriptionItem >> selectedCount: aNumber [

	selectedCount := aNumber
]
