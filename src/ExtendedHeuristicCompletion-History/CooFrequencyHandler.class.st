"
I count each time a method or a class is added, modified, removed for now. 

When a method is added or modified I increase its counter. 
When it is removed I remove its entry (because I do not want to see it again at all - because we could if everything is zero). 


"
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
	
	"to be changed"
	(#(#added #modified) includes: anItem event) 
		ifTrue: [ 
			classFrequencyDictionary 
				at: key
				ifPresent: [:v  | classFrequencyDictionary at: key put: v + 1 ]
				ifAbsentPut: [ 1 ] ].
	
 	(anItem event = #removed)
		ifTrue: [ 
			"The problem could be removing two methods with the same name so the ifAbsent is important"
			classFrequencyDictionary removeKey: key ifAbsent: [  ]
		
		  ]
	 

]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewMethodItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
	
	| key |
	key :=  anItem selector.
	
	"to be changed"
	(#(#added #modified) includes: anItem event) 
		ifTrue: [ 
			selectorFrequenceDictionary 
				at: key
				ifPresent: [:v  | selectorFrequenceDictionary at: key put: v + 1 ]
				ifAbsentPut: [ 1 ] ].
	
 	(anItem event = #removed)
		ifTrue: [ 
			"The problem could be removing two methods with the same name so the ifAbsent is important"
			selectorFrequenceDictionary removeKey: key ifAbsent: [  ]
		
		  ]
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
