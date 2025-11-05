"
A session manager that tracks and stores recently added variables by recording their creation times for frequency-based completion.

"
Class {
	#name : 'CooSessionFrequencyVariable',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Classes-Frequency',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Classes-Frequency'
}

{ #category : 'accessing' }
CooSessionFrequencyVariable class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSessionFrequencyVariable class >> deinstall [

	<script>
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooSessionFrequencyVariable allInstances do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'actions' }
CooSessionFrequencyVariable class >> install [

	<script>
	self environment codeChangeAnnouncer
		when: ClassAdded send: #addNewVariableInVocabulary: to: self current;
		when: ClassRemoved send: #removeVariableFromVocabulary: to: self current
]

{ #category : 'actions' }
CooSessionFrequencyVariable class >> reset [

	<script>
	Current ifNotNil: [
			self environment codeChangeAnnouncer unsubscribe: Current.
			Current := nil ]
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> addNewVariableInVocabulary: anAnn [

	self addVocabulary: anAnn classAdded -> anAnn classAdded at: DateAndTime now
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> addVariableInVocabulary: anAnn [

	self addVocabulary: anAnn selectedItem class at: DateAndTime now
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'initialization' }
CooSessionFrequencyVariable >> initialize [

	super initialize.
	vocabularyCache := CooCachFrequency new maximumWeight: 1000
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> removeVariableFromVocabulary: anAnn [

        | removedAssociation |
        removedAssociation := anAnn classRemoved -> anAnn classRemoved.
        vocabularyCache removeKey: removedAssociation ifAbsent: [ ]
]

{ #category : 'accessing' }
CooSessionFrequencyVariable >> size [

	^ vocabularyCache size
]

{ #category : 'matching' }
CooSessionFrequencyVariable >> words [

	^ vocabularyCache keys
]
