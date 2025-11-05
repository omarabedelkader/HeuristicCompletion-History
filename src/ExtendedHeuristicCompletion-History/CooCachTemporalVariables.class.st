"
Temporal cach
"
Class {
	#name : 'CooCachTemporalVariables',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'maximumWeight'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cach',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cach'
}

{ #category : 'initialization' }
CooCachTemporalVariables >> association: firstAssociation precedes: secondAssociation [

    | firstSeen secondSeen |
    firstSeen := firstAssociation value.
    secondSeen := secondAssociation value.
    firstSeen = secondSeen ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
    firstSeen ifNil: [ ^ false ].
    secondSeen ifNil: [ ^ true ].
    ^ firstSeen > secondSeen
]

{ #category : 'initialization' }
CooCachTemporalVariables >> associations [

    ^ self sortedAssociations
]

{ #category : 'initialization' }
CooCachTemporalVariables >> at: aKey [

    ^ entries at: aKey
]

{ #category : 'initialization' }
CooCachTemporalVariables >> at: aKey put: aValue [

    entries at: aKey put: aValue.
    self enforceLimit.
    ^ aValue
]

{ #category : 'initialization' }
CooCachTemporalVariables >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations
		copyFrom: maximumWeight + 1
		to: entries size)
		do: [ :association | entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'initialization' }
CooCachTemporalVariables >> includesKey: aKey [

    ^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachTemporalVariables >> initialize [

    super initialize.
    entries := Dictionary new.
    maximumWeight := 1000
]

{ #category : 'initialization' }
CooCachTemporalVariables >> keys [

    ^ self sortedAssociations collect: [ :association | association key ]
]

{ #category : 'initialization' }
CooCachTemporalVariables >> maximumWeight: anInteger [

    maximumWeight := anInteger.
    self enforceLimit.
    ^ self
]

{ #category : 'initialization' }
CooCachTemporalVariables >> removeKey: aKey ifAbsent: aBlock [

    ^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'initialization' }
CooCachTemporalVariables >> size [
    ^ entries size
]

{ #category : 'initialization' }
CooCachTemporalVariables >> sortedAssociations [

    ^ entries associations
        asSortedCollection: [ :first :second |
            self association: first precedes: second ]
]
