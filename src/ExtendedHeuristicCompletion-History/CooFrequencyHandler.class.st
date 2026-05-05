"
I am a superclass for classes that use frequency strategy.
"
Class {
	#name : 'CooFrequencyHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'classFrequencyDictionary',
		'selectorFrequenceDictionary',
		'classToMethodsMap'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'override' }
CooFrequencyHandler >> classEntries [

	^ (classFrequencyDictionary associations sort: [ :a1 :a2 | a1 value > a2 value ]) collect: [ :each |
			  (CoGlobalEntry contents: each key node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Frequency' ]
]

{ #category : 'accessing' }
CooFrequencyHandler >> classToMethodsMap [ 
	^ classToMethodsMap 
]

{ #category : 'accessing' }
CooFrequencyHandler >> frequencyOfClass: aClass [
	^ classFrequencyDictionary at: aClass value
]

{ #category : 'accessing' }
CooFrequencyHandler >> frequencyOfMethod: aSelector [
	^ selectorFrequenceDictionary at: aSelector value
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewClassItem: anItem [

	| key classes|
	key := anItem nameOfClass.
	(#(#added #modified) includes: anItem event) 
		ifTrue: [ 
			classFrequencyDictionary 
				at: key
				ifPresent: [:v  | classFrequencyDictionary at: key put: v + 1 ]
				ifAbsentPut: [ 1 ] ].
			"We initialize the new correspending OrderedCollection if it is a new class"
			classToMethodsMap at: key 
			ifAbsentPut: Set new.
	
 	(anItem event = #removed)
		ifTrue: [ 
			classFrequencyDictionary removeKey: key ifAbsent: [  ].
			classFrequencyDictionary removeKey: (key, ' class') asSymbol ifAbsent: [  ].
			"extract the methods of the class in question, 
			for each method we decrement its frequency
			We don't need the correspendance item anymore, we should delete it 
			"
			classes := classToMethodsMap at:key value.
			classes do: [ :m | (selectorFrequenceDictionary includesKey: m) ifTrue: [ selectorFrequenceDictionary at: m put: (selectorFrequenceDictionary at: m) - 1 ] ].
			classToMethodsMap removeKey: key
			]
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewMethodItem: anItem [

	self subclassResponsibility
]

{ #category : 'initialization' }
CooFrequencyHandler >> initialize [ 
	
	super initialize .
	classFrequencyDictionary := Dictionary new.
	selectorFrequenceDictionary := Dictionary new.
	classToMethodsMap := Dictionary new.
	
	
]

{ #category : 'override' }
CooFrequencyHandler >> selectorEntries [

	^ (selectorFrequenceDictionary associations sort: [ :a1 :a2 | a1 value > a2 value ]) collect: [ :each |
			  (CoSelectorEntry contents: each key node: nil)
				  sessionItem: each;
				  fetcherName: 'Session Frequency' ]
]

{ #category : 'accessing' }
CooFrequencyHandler >> selectorFrequencies [ 
	^ selectorFrequenceDictionary values
]
