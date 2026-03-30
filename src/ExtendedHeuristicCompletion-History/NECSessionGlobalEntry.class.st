Class {
	#name : 'NECSessionGlobalEntry',
	#superclass : 'NECGlobalEntry',
	#instVars : [
		'sessionItem'
	],
	#category : 'ExtendedHeuristicCompletion-History-NEC',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'NEC'
}

{ #category : 'accessing' }
NECSessionGlobalEntry >> sessionItem [

	^ sessionItem
]

{ #category : 'accessing' }
NECSessionGlobalEntry >> sessionItem: anObject [

	sessionItem := anObject
]
