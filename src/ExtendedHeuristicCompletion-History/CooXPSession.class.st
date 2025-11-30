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

{ #category : 'adding' }
CooXPSession >> addModifiedMethodInVocabulary: anAnn [

	vocabularyCache addModifiedMethodInVocabulary: anAnn 
]

{ #category : 'adding' }
CooXPSession >> addNewMethodInVocabulary: anAnn [

	vocabularyCache addNewMethodInVocabulary: anAnn
]

{ #category : 'adding' }
CooXPSession >> addNewVariableInVocabulary: aCooMockClassAddedAnnouncement [ 

	vocabularyCache addNewVariableInVocabulary: aCooMockClassAddedAnnouncement 
]

{ #category : 'adding' }
CooXPSession >> removeMethodFromVocabulary: aMethodRemovedAnnouncement [ 

	vocabularyCache removeMethodFromVocabulary: aMethodRemovedAnnouncement 
]

{ #category : 'accessing' }
CooXPSession >> vocabularyCache [
	^ vocabularyCache 
]

{ #category : 'matching' }
CooXPSession >> words [
	^ vocabularyCache selectors
]
