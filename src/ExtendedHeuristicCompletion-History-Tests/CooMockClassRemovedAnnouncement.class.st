"
Mock class
"
Class {
	#name : 'CooMockClassRemovedAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'classRemoved'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session-Mock'
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
