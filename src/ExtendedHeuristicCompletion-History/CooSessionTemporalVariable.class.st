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
	self environment codeChangeAnnouncer when: ClassAdded send: #addNewVariableInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: ClassRemoved send: #removeVariableFromVocabulary: to: self current
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

	    self
                registerClass: (anAnn classAdded -> anAnn classAdded)
                event: #added
                at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalVariable >> addVariableInVocabulary: anAnn [

	       self
                registerClass: anAnn selectedItem class
                event: #selected
                at: DateAndTime now
]

{ #category : 'adding' }
CooSessionTemporalVariable >> addVocabulary: aString at: aDateAndTime [

	      self
                registerClass: aString
                event: #added
                at: aDateAndTime
]

{ #category : 'initialization' }
CooSessionTemporalVariable >> initialize [

	super initialize.
	vocabularyCache := CooTemporalCache new maximumWeight: 1000
]

{ #category : 'adding' }
CooSessionTemporalVariable >> newVocabularyEntry [

        ^ Dictionary new
                at: #event put: nil;
                at: #lastSeen put: nil;
                yourself

]

{ #category : 'adding' }
CooSessionTemporalVariable >> registerClass: aClassReference event: anEventSymbol at: aDateAndTime [

        | entry |
        (vocabularyCache includesKey: aClassReference)
                ifFalse: [ vocabularyCache at: aClassReference put: self newVocabularyEntry ].
        entry := vocabularyCache at: aClassReference.
        entry at: #event put: anEventSymbol.
        entry at: #lastSeen put: aDateAndTime
]

{ #category : 'adding' }
CooSessionTemporalVariable >> removeVariableFromVocabulary: anAnn [

        | removedAssociation |
        removedAssociation := anAnn classRemoved -> anAnn classRemoved.
        vocabularyCache removeKey: removedAssociation ifAbsent: [ ]
]

{ #category : 'accessing' }
CooSessionTemporalVariable >> size [
	^ vocabularyCache size
]

{ #category : 'matching' }
CooSessionTemporalVariable >> words [

	^ vocabularyCache keys
]
