"
I order selection items based on the frequences that were selected by the user. 
But the frequencies is taken into account so that the most recent has a good likehood to be the next one. 

The idea is that if the user selects 50 times OrderedCollection the next one has a high chance to be OrderedCollection. But it after 50 times OrderedCollection the user selects two times OrderedDictionary
then may be OrderedDictionary should have a good likehood to be proposed to the users. 

So there is a mix between mere frequencies and temporal aspects of the user behavior
"
Class {
	#name : 'CooDualMostRecentFrequencyHandler',
	#superclass : 'CooUserSelectionHandler',
	#instVars : [
		'lowercasedCompletionFrequences',
		'uppercasedCompletionFrequences'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> handleNewSelectionItem: aSelectionItem addedTo: aCollection [

	aSelectionItem token first isLowercase 
		ifTrue: [self incrementLowercasedUsageFor: aSelectionItem selectedItemEntry]
		ifFalse: [self incrementUppercasedUsageFor: aSelectionItem selectedItemEntry]
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> incrementLowercasedUsageFor: anEntry [
	"using a dictionary is probably not efficient because after we will sort the key based on their frequency"

	"we keep the entry and not just its contents because entries are typed so we can later filter the one for global or method"

	| key |
	key := anEntry contents.
	lowercasedCompletionFrequences at: key ifAbsentPut: [ 0 -> anEntry ].
	lowercasedCompletionFrequences at: key put: (lowercasedCompletionFrequences at: key) key + 1 -> anEntry. "The following expression acts as a flattener over the previous choices. 
	This way the user is not forced to leave with selection made in the last century."
	lowercasedCompletionFrequences keysAndValuesDo: [ :k :v |
			k = key ifFalse: [
					lowercasedCompletionFrequences
						at: k
						put: (lowercasedCompletionFrequences at: k) key * 0.5 -> (lowercasedCompletionFrequences at: k) value ] ]
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> incrementUppercasedUsageFor: anEntry [
	"using a dictionary is probably not efficient because after we will sort the key based on their frequency"

	"we keep the entry and not just its contents because entries are typed so we can later filter the one for global or method"

	| key |
	key := anEntry contents.
	uppercasedCompletionFrequences at: key ifAbsentPut: [ 0 -> anEntry ].
	uppercasedCompletionFrequences at: key put: (uppercasedCompletionFrequences at: key) key + 1 -> anEntry. "The following expression acts as a flattener over the previous choices. 
	This way the user is not forced to leave with selection made in the last century."
	uppercasedCompletionFrequences keysAndValuesDo: [ :k :v |
			k = key ifFalse: [
					uppercasedCompletionFrequences
						at: k
						put: (uppercasedCompletionFrequences at: k) key * 0.5 -> (uppercasedCompletionFrequences at: k) value ] ]
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> incrementUsageFor: anEntry [
	"using a dictionary is probably not efficient because after we will sort the key based on their frequency"
	"we keep the entry and not just its contents because entries are typed so we can later filter the one for global or method"

	| key |
	key := anEntry contents.
	lowercasedCompletionFrequences at: key ifAbsentPut: [ 0 -> anEntry ].
	lowercasedCompletionFrequences at: key put: ((lowercasedCompletionFrequences at: key) key + 1 -> anEntry). 
	
	
	"The following expression acts as a flattener over the previous choices. 
	This way the user is not forced to leave with selection made in the last century."
	lowercasedCompletionFrequences keysAndValuesDo: [ :k :v |
		k = key ifFalse: [ lowercasedCompletionFrequences at: k put: ((lowercasedCompletionFrequences at: k) key * 0.5 -> (lowercasedCompletionFrequences at: k) value )] ]
]

{ #category : 'initialization' }
CooDualMostRecentFrequencyHandler >> initialize [

	super initialize.
	"using a dictionary may be the best data structure because after we will sort the item based on their frequency."
	uppercasedCompletionFrequences := Dictionary new.
	lowercasedCompletionFrequences := Dictionary new. 
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> sortedRecentChoices [
	
	| sorted |
	sorted := SortedCollection sortBlock: [ :a :b |
			(a value key = b value key)
				ifTrue: [ a key < b key ]
				ifFalse: [ a value key > b value key] ].
	sorted addAll: lowercasedCompletionFrequences associations.
	"now we will return the entry with the original fetcher as the one that filled up the completion
	but in fact here this is the mostRecenetFrequenceHandler that in fact sort the entries.
	So may be we could wrap the information to say 
			(MostRecent.... (original one)). Alternatively we could add a primary fetcher and a secondary in the nec entry."
	^ sorted collect: [ :each | each value value ].

	
	
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> sortedRecentLowercasedChoices [
	
	| sorted |
	sorted := SortedCollection sortBlock: [ :a :b |
			(a value key = b value key)
				ifTrue: [ a key < b key ]
				ifFalse: [ a value key > b value key] ].
	sorted addAll: lowercasedCompletionFrequences associations.
	"now we will return the entry with the original fetcher as the one that filled up the completion
	but in fact here this is the mostRecenetFrequenceHandler that in fact sort the entries.
	So may be we could wrap the information to say 
			(MostRecent.... (original one)). Alternatively we could add a primary fetcher and a secondary in the nec entry."
	^ sorted collect: [ :each | each value value ].

	
	
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> sortedRecentUppercasedChoices [
	
	| sorted |
	sorted := SortedCollection sortBlock: [ :a :b |
			(a value key = b value key)
				ifTrue: [ a key < b key ]
				ifFalse: [ a value key > b value key] ].
	sorted addAll: uppercasedCompletionFrequences associations.
	"now we will return the entry with the original fetcher as the one that filled up the completion
	but in fact here this is the mostRecenetFrequenceHandler that in fact sort the entries.
	So may be we could wrap the information to say 
			(MostRecent.... (original one)). Alternatively we could add a primary fetcher and a secondary in the nec entry."
	^ sorted collect: [ :each | each value value ].

	
	
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> sortedUserEntries [

	| lst |
	lst := self sortedRecentChoices.
	^ lst first: (lst size min: 5)
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> sortedUserLowercasedEntries [

	| lst |
	lst := self sortedRecentLowercasedChoices.
	^ lst first: (lst size min: 5)
]

{ #category : 'tracking' }
CooDualMostRecentFrequencyHandler >> sortedUserUppercasedEntries [

	| lst |
	lst := self sortedRecentUppercasedChoices.
	^ lst first: (lst size min: 5)
]
