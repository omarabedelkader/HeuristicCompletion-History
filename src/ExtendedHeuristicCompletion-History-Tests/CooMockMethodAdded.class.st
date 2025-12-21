Class {
	#name : 'CooMockMethodAdded',
	#superclass : 'MethodAnnouncement',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session-Mock'
}

{ #category : 'instance creation' }
CooMockMethodAdded class >> for: aClassReference [

	^ self new
		  method: aClassReference;
		  yourself
]

{ #category : 'accessing' }
CooMockMethodAdded >> methodAdded [

	^ method
]
