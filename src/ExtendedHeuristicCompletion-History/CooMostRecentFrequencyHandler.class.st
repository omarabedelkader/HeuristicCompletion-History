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

	self incrementUsageFor: aSelectionItem selectedItemEntry
]

{ #category : 'tracking' }
CooMostRecentFrequencyHandler >> incrementUsageFor: anEntry [
	"using a dictionary is probably not efficient because after we will sort the key based on their frequency"
	"we keep the entry and not just its contents because entries are typed so we can later filter the one for global or method"

	| key |
	key := anEntry contents.
	completionFrequences at: key ifAbsentPut: [ 0 -> anEntry ].
	completionFrequences at: key put: ((completionFrequences at: key) key + 1 -> anEntry). 
	
	
	"The following expression acts as a flattener over the previous choices. 
	This way the user is not forced to leave with selection made in the last century."
	completionFrequences keysAndValuesDo: [ :k :v |
		k = key ifFalse: [ completionFrequences at: k put: ((completionFrequences at: k) key * 0.5 -> anEntry )] ]
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
			(a value key = b value key)
				ifTrue: [ a key < b key ]
				ifFalse: [ a value key > b value key] ].
	sorted addAll: completionFrequences associations.
	 
	"now we will return the entry with the original fetcher as the one that filled up the completion
	but in fact here this is the mostRecenetFrequenceHandler that in fact sort the entries.
	So may be we could wrap the information to say 
			(MostRecent.... (original one)). Alternatively we could add a primary fetcher and a secondary in the nec entry."
	^ sorted collect: [ :each | each value value ].

	
	
]

{ #category : 'tracking' }
CooMostRecentFrequencyHandler >> sortedUserVocabulary [

	| lst |
	lst := self sortedRecentChoices.
	^ lst first: (lst size min: 5)
]
