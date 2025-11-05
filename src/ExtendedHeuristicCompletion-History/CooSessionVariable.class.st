Class {
	#name : 'CooSessionVariable',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Temporal-Classes',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Temporal-Classes'
}

{ #category : 'accessing' }
CooSessionVariable class >> current [ 

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSessionVariable class >> deinstall [
	<script>
	
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooSessionVariable allInstances 
		do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'actions' }
CooSessionVariable class >> install [
	<script>
	
	self environment codeChangeAnnouncer
		when: ClassAdded 
		send: #addNewVariableInVocabulary: 
		to: self current.
	"
	This does not work for now because we are expecting a node and the menu does not give us a node
	in addition we do not get the."
	"self environment codeChangeAnnouncer
		when: CompletionItemSelected
		send: #addMessageInVocabulary: 
		to: self current."
]

{ #category : 'initialization' }
CooSessionVariable class >> reset [
	<script>
	Current ifNotNil: [ 
		self environment codeChangeAnnouncer
			unsubscribe: Current.
	Current := nil ]
]

{ #category : 'adding' }
CooSessionVariable >> addNewVariableInVocabulary: anAnn [
	
	self addVocabulary: (anAnn classAdded -> anAnn classAdded) at: DateAndTime now
]

{ #category : 'adding' }
CooSessionVariable >> addVariableInVocabulary: anAnn [

	self addVocabulary: anAnn selectedItem class at: DateAndTime now
]

{ #category : 'adding' }
CooSessionVariable >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'initialization' }
CooSessionVariable >> initialize [

	super initialize.
	vocabularyCache := LRUCache new maximumWeight: 1000
]

{ #category : 'accessing' }
CooSessionVariable >> size [
	^ vocabularyCache size
]

{ #category : 'matching' }
CooSessionVariable >> words [

	^ vocabularyCache keys
]
