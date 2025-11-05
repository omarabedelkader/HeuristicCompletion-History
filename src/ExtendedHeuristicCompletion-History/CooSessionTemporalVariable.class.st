"
A session manager that records recently added variables, keeping track of their creation times to enable temporally based variable completion.

"
Class {
	#name : 'CooSessionTemporalVariable',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Classes-Temporal',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Classes-Temporal'
}

{ #category : 'accessing' }
CooSessionTemporalVariable class >> current [ 

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSessionTemporalVariable class >> deinstall [
	<script>
	
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooSessionTemporalVariable allInstances 
		do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'actions' }
CooSessionTemporalVariable class >> install [

	<script>
	self environment codeChangeAnnouncer when: ClassAdded send: #addNewVariableInVocabulary: to: self current
]

{ #category : 'initialization' }
CooSessionTemporalVariable class >> reset [
	<script>
	Current ifNotNil: [ 
		self environment codeChangeAnnouncer
			unsubscribe: Current.
	Current := nil ]
]

{ #category : 'adding' }
CooSessionTemporalVariable >> addNewVariableInVocabulary: anAnn [
	
	self addVocabulary: (anAnn classAdded -> anAnn classAdded) at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalVariable >> addVariableInVocabulary: anAnn [

	self addVocabulary: anAnn selectedItem class at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalVariable >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'initialization' }
CooSessionTemporalVariable >> initialize [

	super initialize.
	vocabularyCache := CooCachTemporal new maximumWeight: 1000
]

{ #category : 'accessing' }
CooSessionTemporalVariable >> size [
	^ vocabularyCache size
]

{ #category : 'matching' }
CooSessionTemporalVariable >> words [

	^ vocabularyCache keys
]
