"
I order selection items based on the frequences that were selected by the user. 
But the frequencies is taken into account so that the most recent has a good likehood to be the next one. 

The idea is that if the user selects 50 times OrderedCollection the next one has a high chance to be OrderedCollection. But it after 50 times OrderedCollection the user selects two times OrderedDictionary
then may be OrderedDictionary should have a good likehood to be proposed to the users. 

So there is a mix between mere frequencies and temporal aspects of the user behavior
"
Class {
	#name : 'CooMostRecentFrequencyHandler',
	#superclass : 'CooUserSelectionHandler',
	#instVars : [
		'completionFrequences'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'tracking' }
CooMostRecentFrequencyHandler >> handleNewSelectionItem: aSelectionItem addedTo: aCollection [

	self incrementUsageFor: aSelectionItem selectedItemString
]

{ #category : 'tracking' }
CooMostRecentFrequencyHandler >> incrementUsageFor: aString [
	"using a dictionary is probably not efficient because after we will sort the key based on their frequency"

	completionFrequences at: aString ifAbsentPut: [ 0 ].
	completionFrequences at: aString put: (completionFrequences at: aString) + 1. "The following expression acts as a flattener over the previous choices. 
	This way the user is not forced to leave with selection made in the last century."
	completionFrequences keysAndValuesDo: [ :k :v |
		k = aString ifFalse: [ completionFrequences at: k put: (completionFrequences at: k) * 0.5 ] ]
]

{ #category : 'initialization' }
CooMostRecentFrequencyHandler >> initialize [

	super initialize.
	"using a dictionary may be the best data structure because after we will sort the item based on their frequency."
	completionFrequences := Dictionary new
]

{ #category : 'tracking' }
CooMostRecentFrequencyHandler >> sortedRecentChoices [
	
	| sorted |
	sorted := SortedCollection sortBlock: [ :a :b |
			(a value = b value)
				ifTrue: [ a key < b key ]
				ifFalse: [ a value > b value ] ].
	sorted addAll: completionFrequences associations.
	 
	^ sorted collect: [ :each | each key ].

	
	
]

{ #category : 'tracking' }
CooMostRecentFrequencyHandler >> sortedUserVocabulary [

	| lst |
	lst := self sortedRecentChoices.
	^ lst first: (lst size min: 5)
]
