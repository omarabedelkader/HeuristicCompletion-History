"
A cache that stores message entries ordered by their most recent access time, removing the oldest ones when the size limit is exceeded.

"
Class {
	#name : 'CooCachTemporalMessages',
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
CooCachTemporalMessages >> association: firstAssociation precedes: secondAssociation [

| firstEntry secondEntry firstSeen secondSeen |
firstEntry := firstAssociation value.
secondEntry := secondAssociation value.
firstSeen := firstEntry at: #lastSeen ifAbsent: [ nil ].
secondSeen := secondEntry at: #lastSeen ifAbsent: [ nil ].
firstSeen = secondSeen ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
firstSeen ifNil: [ ^ false ].
secondSeen ifNil: [ ^ true ].
^ firstSeen > secondSeen
]

{ #category : 'accessing' }
CooCachTemporalMessages >> associations [

	^ self sortedAssociations
]

{ #category : 'accessing' }
CooCachTemporalMessages >> at: aKey [

	^ entries at: aKey
]

{ #category : 'accessing' }
CooCachTemporalMessages >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'accessing' }
CooCachTemporalMessages >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
		entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooCachTemporalMessages >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachTemporalMessages >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 1000
]

{ #category : 'accessing' }
CooCachTemporalMessages >> keys [

	^ self sortedAssociations collect: [ :association | association key ]
]

{ #category : 'accessing' }
CooCachTemporalMessages >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'removing' }
CooCachTemporalMessages >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
CooCachTemporalMessages >> size [

	^ entries size
]

{ #category : 'accessing' }
CooCachTemporalMessages >> sortedAssociations [

	^ entries associations asSortedCollection: [ :first :second | self association: first precedes: second ]
]
