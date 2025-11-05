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

	self addVocabulary: anAnn selectedItem selector  at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSession >> addModifiedMethodInVocabulary: anAnn [

	self addVocabulary: (anAnn selector -> anAnn newMethod ast) at: DateAndTime now
]

{ #category : 'vocabulary' }
CooSession >> addNewMethodInVocabulary: anAnn [
	
	self addVocabulary: (anAnn selector -> anAnn method ast) at: DateAndTime now 
]

{ #category : 'vocabulary' }
CooSession >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'initialization' }
CooSession >> initialize [

	super initialize.
	vocabularyCache := LRUCache new maximumWeight: 1000
]

{ #category : 'accessing' }
CooSession >> removeMethodFromVocabulary: anAnn [

        | selector |
        selector := anAnn selector.
        (vocabularyCache keys select: [ :each | each key = selector ])
                do: [ :each | vocabularyCache removeKey: each ifAbsent: [ ] ].
]

{ #category : 'accessing' }
CooSession >> size [
	^ vocabularyCache size
]

{ #category : 'accessing' }
CooSession >> words [

	^ vocabularyCache keys
]
