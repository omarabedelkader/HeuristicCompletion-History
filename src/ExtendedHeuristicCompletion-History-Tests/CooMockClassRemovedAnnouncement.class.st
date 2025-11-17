"
Mock class
"
Class {
	#name : 'CooMockClassRemovedAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'classRemoved'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-History-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History-Mock'
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
