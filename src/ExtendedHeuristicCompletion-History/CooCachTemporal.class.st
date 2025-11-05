"
A cache that stores message entries ordered by their most recent access time, removing the oldest ones when the size limit is exceeded.

"
Class {
	#name : 'CooCachTemporal',
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
CooCachTemporal >> association: firstAssociation precedes: secondAssociation [

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
CooCachTemporal >> associations [

	^ self sortedAssociations
]

{ #category : 'accessing' }
CooCachTemporal >> at: aKey [

	^ entries at: aKey
]

{ #category : 'accessing' }
CooCachTemporal >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'accessing' }
CooCachTemporal >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
		entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooCachTemporal >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachTemporal >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 1000
]

{ #category : 'accessing' }
CooCachTemporal >> keys [

	^ self sortedAssociations collect: [ :association | association key ]
]

{ #category : 'accessing' }
CooCachTemporal >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'removing' }
CooCachTemporal >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
CooCachTemporal >> size [

	^ entries size
]

{ #category : 'accessing' }
CooCachTemporal >> sortedAssociations [

	^ entries associations asSortedCollection: [ :first :second | self association: first precedes: second ]
]
