Class {
	#name : 'CooXPSession',
	#superclass : 'CooSession',
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'adding' }
CooXPSession >> addNewMethodInVocabulary: anAnn [

	vocabularyCache addNewMethodInVocabulary: anAnn
]

{ #category : 'accessing' }
CooXPSession >> vocabularyCache [
	^ vocabularyCache 
]
