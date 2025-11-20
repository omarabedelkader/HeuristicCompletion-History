"
A session manager that tracks message activity over time, recording when methods are added or modified to support temporally based autocompletion.


#### Implementation questions.

Questions: I do not really understand the use of a dictionary in the context of a sequence because temporal means that we will want to take into account more frequent first 

So why not having 

	entry1 entry2 ..... entryn
	
then when the user type x we select the entries with x* and pass them to the fetcher. 

I have to think about it.


"
Class {
	#name : 'CooSessionTemporalMessages',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Messages-Temporal',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Messages-Temporal'
}

{ #category : 'accessing' }
CooSessionTemporalMessages class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'accessing' }
CooSessionTemporalMessages class >> deinstall [

	<script>
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooSessionTemporalMessages allInstances do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'accessing' }
CooSessionTemporalMessages class >> install [

	<script>
	self environment codeChangeAnnouncer when: MethodAdded send: #addNewMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodModified send: #addModifiedMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodRemoved send: #removeMethodFromVocabulary: to: self current
]

{ #category : 'accessing' }
CooSessionTemporalMessages class >> reset [

	<script>
	Current ifNotNil: [
			self environment codeChangeAnnouncer unsubscribe: Current.
			Current := nil ]
]

{ #category : 'adding' }
CooSessionTemporalMessages >> addMessageInVocabulary: anAnn [

	self
		registerSelector: anAnn selectedItem selector
		ast: nil
		event: #selected
		at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalMessages >> addModifiedMethodInVocabulary: anAnn [

	self
		registerSelector: anAnn selector
		ast: anAnn newMethod ast
		event: #modified
		at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalMessages >> addNewMethodInVocabulary: anAnn [

	self
		registerSelector: anAnn selector
		ast: anAnn method ast
		event: #added
		at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalMessages >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'adding' }
CooSessionTemporalMessages >> eventCountKeyFor: anEventSymbol [

	anEventSymbol = #added ifTrue: [ ^ #incrementAdded].
	anEventSymbol = #modified ifTrue: [ ^ #incrementModified ].
	^ nil
]

{ #category : 'adding' }
CooSessionTemporalMessages >> frequencies [

	| result |
	result := Dictionary new.
	vocabularyCache keys do: [ :selector | result at: selector put: (self frequencyDictionaryFor: (vocabularyCache at: selector)) ].
	^ result
]

{ #category : 'adding' }
CooSessionTemporalMessages >> frequencyDictionaryFor: anEntry [

	^ Dictionary new
		  at: #added put: (anEntry at: #addedCount ifAbsent: [ 0 ]);
		  at: #modified put: (anEntry at: #modifiedCount ifAbsent: [ 0 ]);
		  yourself
]

{ #category : 'adding' }
CooSessionTemporalMessages >> frequencyForSelector: aSelector [

	(vocabularyCache includesKey: aSelector) 
		ifFalse: [ ^ self newFrequencyDictionary ].
	^ self frequencyDictionaryFor: (vocabularyCache at: aSelector)
]

{ #category : 'adding' }
CooSessionTemporalMessages >> initialize [

	super initialize.
	vocabularyCache := CooTemporalCache new maximumWeight: 1000
]

{ #category : 'adding' }
CooSessionTemporalMessages >> newFrequencyDictionary [

	^ Dictionary new
		  at: #added put: 0;
		  at: #modified put: 0;
		  yourself
]

{ #category : 'adding' }
CooSessionTemporalMessages >> newVocabularyEntry [

	^ CooCountingODescriptionItem new
		
]

{ #category : 'adding' }
CooSessionTemporalMessages >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	| entry |
	(vocabularyCache includesKey: aSelector) 
		ifFalse: [ vocabularyCache at: aSelector put: self newVocabularyEntry ].
	entry := vocabularyCache at: aSelector.
	self updateEntry: entry withEvent: anEventSymbol.
	anAst ifNotNil: [ entry ast: anAst ].
	entry lastSeen: aDateAndTime
]

{ #category : 'adding' }
CooSessionTemporalMessages >> removeMethodFromVocabulary: anAnn [

	vocabularyCache removeKey: anAnn selector ifAbsent: [ ]
]

{ #category : 'adding' }
CooSessionTemporalMessages >> size [

	^ vocabularyCache size
]

{ #category : 'adding' }
CooSessionTemporalMessages >> updateEntry: anEntry withEvent: anEventSymbol [

	| countKey |
	countKey := self eventCountKeyFor: anEventSymbol.
	countKey ifNil: [ ^ self ].
	anEntry perform: countKey
]

{ #category : 'adding' }
CooSessionTemporalMessages >> words [

	^ vocabularyCache keys collect: [ :selector |
			  | entry |
			  entry := vocabularyCache at: selector.
			  selector -> (entry at: #ast ifAbsent: [ nil ]) ]
]
