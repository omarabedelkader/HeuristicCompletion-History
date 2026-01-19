Class {
	#name : 'CooFrequencyHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'classFrequencyDictionary',
		'selectorFrequenceDictionary'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooFrequencyHandler >> classEntries [

	^ (classFrequencyDictionary associations  
			sort: [ :a1 :a2 | a1 value > a2 value ]) 
			collect: [ :each | (NECGlobalEntry contents: each key node: nil) fetcher: self ]
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewClassItem: anItem addedTo: aCollection [

	| key |
	key := anItem nameOfClass.
	
	classFrequencyDictionary 
		at: key 
		ifPresent: [ :v  | classFrequencyDictionary at: key put: v + 1 ]
		ifAbsentPut: [ 1 ]
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewMethodItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
	
	| key |
	key :=  anItem selector.
	selectorFrequenceDictionary 
		at: key
		ifPresent: [:v  | selectorFrequenceDictionary at: key put: v + 1 ]
		ifAbsentPut: [ 1 ]
 
]

{ #category : 'matching' }
CooFrequencyHandler >> initialize [

	super initialize.
	classFrequencyDictionary := Dictionary new.
	selectorFrequenceDictionary := Dictionary new
]

{ #category : 'matching' }
CooFrequencyHandler >> selectorEntries [

	^ (selectorFrequenceDictionary associations  
			sort: [ :a1 :a2 | a1 value > a2 value ]) 
			collect: [ :each | (NECSelectorEntry contents: each key node: nil) fetcher: self ]
]
