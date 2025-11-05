Class {
	#name : 'CooSessionTemporalVocabularyCache',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'maximumWeight'
	],
	#category : 'ExtendedHeuristicCompletion-History-Temporal-Classes',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Temporal-Classes'
}

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> association: firstAssociation precedes: secondAssociation [

    | firstSeen secondSeen |
    firstSeen := firstAssociation value.
    secondSeen := secondAssociation value.
    firstSeen = secondSeen ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
    firstSeen ifNil: [ ^ false ].
    secondSeen ifNil: [ ^ true ].
    ^ firstSeen > secondSeen
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> associations [

    ^ self sortedAssociations
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> at: aKey [

    ^ entries at: aKey
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> at: aKey put: aValue [

    entries at: aKey put: aValue.
    self enforceLimit.
    ^ aValue
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> enforceLimit [

    entries size <= maximumWeight ifTrue: [ ^ self ].
    self sortedAssociations
        copyFrom: maximumWeight + 1
        to: entries size
        do: [ :association | entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> includesKey: aKey [

    ^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> initialize [

    super initialize.
    entries := Dictionary new.
    maximumWeight := 1000
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> keys [

    ^ self sortedAssociations collect: [ :association | association key ]
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> maximumWeight: anInteger [

    maximumWeight := anInteger.
    self enforceLimit.
    ^ self
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> removeKey: aKey ifAbsent: aBlock [

    ^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> size [
    ^ entries size
]

{ #category : 'initialization' }
CooSessionTemporalVocabularyCache >> sortedAssociations [

    ^ entries associations
        asSortedCollection: [ :first :second |
            self association: first precedes: second ]
]
