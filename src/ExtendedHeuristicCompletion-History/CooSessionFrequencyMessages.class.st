"
A session manager that tracks message usage by recording and updating the frequency and timing of method additions and modifications.

"
Class {
	#name : 'CooSessionFrequencyMessages',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Messages-Frequency',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Messages-Frequency'
}

{ #category : 'actions' }
CooSessionFrequencyMessages class >> current [ 

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSessionFrequencyMessages class >> deinstall [
	<script>
	
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooSessionFrequencyMessages allInstances 
		do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'actions' }
CooSessionFrequencyMessages class >> install [

	<script>
	self environment codeChangeAnnouncer when: MethodAdded send: #addNewMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodModified send: #addModifiedMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodRemoved send: #removeMethodFromVocabulary: to: self current.
]

{ #category : 'actions' }
CooSessionFrequencyMessages class >> reset [
	<script>
	Current ifNotNil: [ 
		self environment codeChangeAnnouncer
			unsubscribe: Current.
	Current := nil ]
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> addMessageInVocabulary: anAnn [

self
                registerSelector: anAnn selectedItem selector
                ast: nil
                event: #selected
                at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSessionFrequencyMessages >> addModifiedMethodInVocabulary: anAnn [

	   self
                registerSelector: anAnn selector
                ast: anAnn newMethod ast
                event: #modified
                at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSessionFrequencyMessages >> addNewMethodInVocabulary: anAnn [

        self
                registerSelector: anAnn selector
                ast: anAnn method ast
                event: #added
                at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSessionFrequencyMessages >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> eventCountKeyFor: anEventSymbol [

        anEventSymbol = #added ifTrue: [ ^ #addedCount ].
        anEventSymbol = #modified ifTrue: [ ^ #modifiedCount ].
        ^ nil
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> frequencies [

        | result |
        result := Dictionary new.
        vocabularyCache keys do: [ :selector |
                result at: selector put: (self frequencyDictionaryFor: (vocabularyCache at: selector)) ].
        ^ result
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> frequencyDictionaryFor: anEntry [

        ^ Dictionary new
                at: #added put: (anEntry at: #addedCount ifAbsent: [ 0 ]);
                at: #modified put: (anEntry at: #modifiedCount ifAbsent: [ 0 ]);
                yourself
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> frequencyForSelector: aSelector [

        (vocabularyCache includesKey: aSelector) ifFalse: [ ^ self newFrequencyDictionary ].
        ^ self frequencyDictionaryFor: (vocabularyCache at: aSelector)
]

{ #category : 'initialization' }
CooSessionFrequencyMessages >> initialize [

	super initialize.
	vocabularyCache := CooCachFrequencyMessages new maximumWeight: 1000
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> newFrequencyDictionary [

        ^ Dictionary new
                at: #added put: 0;
                at: #modified put: 0;
                yourself
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> newVocabularyEntry [

        ^ Dictionary new
                at: #ast put: nil;
                at: #lastSeen put: nil;
                at: #addedCount put: 0;
                at: #modifiedCount put: 0;
                yourself
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

        | entry |
        (vocabularyCache includesKey: aSelector)
                ifFalse: [ vocabularyCache at: aSelector put: self newVocabularyEntry ].
        entry := vocabularyCache at: aSelector.
        self updateEntry: entry withEvent: anEventSymbol.
        anAst ifNotNil: [ entry at: #ast put: anAst ].
        entry at: #lastSeen put: aDateAndTime
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> removeMethodFromVocabulary: anAnn [

	vocabularyCache removeKey: anAnn selector ifAbsent: [ ]
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> size [
	^ vocabularyCache size
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> updateEntry: anEntry withEvent: anEventSymbol [

        | countKey |
        countKey := self eventCountKeyFor: anEventSymbol.
        countKey ifNil: [ ^ self ].
        anEntry at: countKey put: ((anEntry at: countKey ifAbsent: [ 0 ]) + 1)
]

{ #category : 'accessing' }
CooSessionFrequencyMessages >> words [

	^ vocabularyCache keys collect: [ :selector |
                | entry |
                entry := vocabularyCache at: selector.
                selector -> (entry at: #ast ifAbsent: [ nil ])
        ]
]
