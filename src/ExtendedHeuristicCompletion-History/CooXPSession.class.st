Class {
	#name : 'CooXPSession',
	#superclass : 'CooSession',
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'instance creation' }
CooXPSession class >> withXPCache [

	^ self new 
		vocabularyCache: CooNewTemporalCache new; 
		yourself
]
