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

        self
                registerClass: anAnn classAdded -> anAnn classAdded
                event: #added
                at: DateAndTime now
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> addVariableInVocabulary: anAnn [

        self
                registerClass: anAnn selectedItem class
                event: #selected
                at: DateAndTime now
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> addVocabulary: aString at: aDateAndTime [

	        self
                registerClass: aString
                event: #added
                at: aDateAndTime
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> eventCountKeyFor: anEventSymbol [

        anEventSymbol = #added ifTrue: [ ^ #addedCount ].
        anEventSymbol = #selected ifTrue: [ ^ #selectedCount ].
        ^ nil
]

{ #category : 'initialization' }
CooSessionFrequencyVariable >> initialize [

	super initialize.
	vocabularyCache := CooCachFrequency new maximumWeight: 1000
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> newVocabularyEntry [

        ^ Dictionary new
                at: #addedCount put: 0;
                at: #selectedCount put: 0;
                at: #lastSeen put: nil;
                yourself
]

{ #category : 'adding' }
CooSessionFrequencyVariable >> registerClass: aClassReference event: anEventSymbol at: aDateAndTime [

        | entry |
        (vocabularyCache includesKey: aClassReference)
                ifFalse: [ vocabularyCache at: aClassReference put: self newVocabularyEntry ].
        entry := vocabularyCache at: aClassReference.
        self updateEntry: entry withEvent: anEventSymbol.
        entry at: #lastSeen put: aDateAndTime
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

{ #category : 'adding' }
CooSessionFrequencyVariable >> updateEntry: anEntry withEvent: anEventSymbol [

        | countKey |
        countKey := self eventCountKeyFor: anEventSymbol.
        countKey ifNil: [ ^ self ].
        anEntry at: countKey put: ((anEntry at: countKey ifAbsent: [ 0 ]) + 1)
]

{ #category : 'matching' }
CooSessionFrequencyVariable >> words [

	^ vocabularyCache keys
]
