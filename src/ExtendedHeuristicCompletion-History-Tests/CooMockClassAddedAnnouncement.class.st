"
Mock class
"
Class {
	#name : 'CooMockClassAddedAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'classAdded'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-History-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History-Mock'
}

{ #category : 'instance creation' }
CooMockClassAddedAnnouncement class >> for: aClassReference [

    ^ self new
        classAdded: aClassReference;
        yourself
]

{ #category : 'accessing' }
CooMockClassAddedAnnouncement >> classAdded [

    ^ classAdded
]

{ #category : 'accessing' }
CooMockClassAddedAnnouncement >> classAdded: aClassReference [

    classAdded := aClassReference
]
