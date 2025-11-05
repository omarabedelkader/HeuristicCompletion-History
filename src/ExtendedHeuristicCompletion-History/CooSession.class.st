"
I implement a session that collects execution information.
I collect the last words in modified methods.

I
"
Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'actions' }
CooSession class >> current [ 

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSession class >> deinstall [
	<script>
	
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooSession allInstances 
		do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'actions' }
CooSession class >> install [

	<script>
	self environment codeChangeAnnouncer when: MethodAdded send: #addNewMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodModified send: #addModifiedMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodRemoved send: #removeMethodFromVocabulary: to: self current.
]

{ #category : 'actions' }
CooSession class >> reset [
	<script>
	Current ifNotNil: [ 
		self environment codeChangeAnnouncer
			unsubscribe: Current.
	Current := nil ]
]

{ #category : 'accessing' }
CooSession >> addMessageInVocabulary: anAnn [

self
                registerSelector: anAnn selectedItem selector
                ast: nil
                event: #selected
                at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSession >> addModifiedMethodInVocabulary: anAnn [

	   self
                registerSelector: anAnn selector
                ast: anAnn newMethod ast
                event: #modified
                at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSession >> addNewMethodInVocabulary: anAnn [

        self
                registerSelector: anAnn selector
                ast: anAnn method ast
                event: #added
                at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSession >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'accessing' }
CooSession >> eventCountKeyFor: anEventSymbol [

        anEventSymbol = #added ifTrue: [ ^ #addedCount ].
        anEventSymbol = #modified ifTrue: [ ^ #modifiedCount ].
        ^ nil
]

{ #category : 'accessing' }
CooSession >> frequencies [

        | result |
        result := Dictionary new.
        vocabularyCache keys do: [ :selector |
                result at: selector put: (self frequencyDictionaryFor: (vocabularyCache at: selector)) ].
        ^ result
]

{ #category : 'accessing' }
CooSession >> frequencyDictionaryFor: anEntry [

        ^ Dictionary new
                at: #added put: (anEntry at: #addedCount ifAbsent: [ 0 ]);
                at: #modified put: (anEntry at: #modifiedCount ifAbsent: [ 0 ]);
                yourself
]

{ #category : 'accessing' }
CooSession >> frequencyForSelector: aSelector [

        (vocabularyCache includesKey: aSelector) ifFalse: [ ^ self newFrequencyDictionary ].
        ^ self frequencyDictionaryFor: (vocabularyCache at: aSelector)
]

{ #category : 'initialization' }
CooSession >> initialize [

	super initialize.
	vocabularyCache := LRUCache new maximumWeight: 1000
]

{ #category : 'accessing' }
CooSession >> newFrequencyDictionary [

        ^ Dictionary new
                at: #added put: 0;
                at: #modified put: 0;
                yourself
]

{ #category : 'accessing' }
CooSession >> newVocabularyEntry [

        ^ Dictionary new
                at: #ast put: nil;
                at: #lastSeen put: nil;
                at: #addedCount put: 0;
                at: #modifiedCount put: 0;
                yourself
]

{ #category : 'accessing' }
CooSession >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

        | entry |
        (vocabularyCache includesKey: aSelector)
                ifFalse: [ vocabularyCache at: aSelector put: self newVocabularyEntry ].
        entry := vocabularyCache at: aSelector.
        self updateEntry: entry withEvent: anEventSymbol.
        anAst ifNotNil: [ entry at: #ast put: anAst ].
        entry at: #lastSeen put: aDateAndTime
]

{ #category : 'accessing' }
CooSession >> removeMethodFromVocabulary: anAnn [

	vocabularyCache removeKey: anAnn selector ifAbsent: [ ]
]

{ #category : 'accessing' }
CooSession >> size [
	^ vocabularyCache size
]

{ #category : 'accessing' }
CooSession >> updateEntry: anEntry withEvent: anEventSymbol [

        | countKey |
        countKey := self eventCountKeyFor: anEventSymbol.
        countKey ifNil: [ ^ self ].
        anEntry at: countKey put: ((anEntry at: countKey ifAbsent: [ 0 ]) + 1)
]

{ #category : 'accessing' }
CooSession >> words [

	^ vocabularyCache keys collect: [ :selector |
                | entry |
                entry := vocabularyCache at: selector.
                selector -> (entry at: #ast ifAbsent: [ nil ])
        ]
]
