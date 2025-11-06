Class {
	#name : 'CooMockClassRemovedAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'classRemoved'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Tests'
}

{ #category : 'instance creation' }
CooMockClassRemovedAnnouncement class >> for: aClassReference [

    ^ self new
        classRemoved: aClassReference;
        yourself
]

{ #category : 'accessing' }
CooMockClassRemovedAnnouncement >> classRemoved [

    ^ classRemoved
]

{ #category : 'accessing' }
CooMockClassRemovedAnnouncement >> classRemoved: aClassReference [

    classRemoved := aClassReference
]
