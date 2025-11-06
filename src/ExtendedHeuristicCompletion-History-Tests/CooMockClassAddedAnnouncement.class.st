Class {
	#name : 'CooMockClassAddedAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'classAdded'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Tests'
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
