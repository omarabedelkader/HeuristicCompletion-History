Class {
	#name : 'CooMockMethodAdded',
	#superclass : 'MethodAnnouncement',
	#category : 'ExtendedHeuristicCompletion-History-Tests-History-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'History-Mock'
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
