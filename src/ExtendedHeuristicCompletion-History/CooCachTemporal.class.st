"
A cache that stores message entries ordered by their most recent access time, removing the oldest ones when the size limit is exceeded.

"
Class {
	#name : 'CooCachTemporal',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'maximumWeight',
		'insertionOrder',
		'orderCounter'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cach',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cach'
}

{ #category : 'initialization' }
CooCachTemporal >> association: firstAssociation precedes: secondAssociation [

	| firstEntry secondEntry firstSeen secondSeen firstOrder secondOrder |
	firstEntry := firstAssociation value.
	secondEntry := secondAssociation value.
	firstSeen := firstEntry at: #lastSeen ifAbsent: [ nil ].
	secondSeen := secondEntry at: #lastSeen ifAbsent: [ nil ].
firstSeen = secondSeen ifTrue: [
    firstOrder := self orderFor: firstAssociation key.
    secondOrder := self orderFor: secondAssociation key.
    firstOrder = secondOrder ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
    ^ firstOrder > secondOrder ].
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

        | entry |
        entry := entries at: aKey.
        self recordAccessOf: aKey.
        ^ entry
]

{ #category : 'accessing' }
CooCachTemporal >> at: aKey put: aValue [

        entries at: aKey put: aValue.
        self recordInsertionOf: aKey.
        self enforceLimit.
        ^ aValue
]

{ #category : 'accessing' }
CooCachTemporal >> enforceLimit [
        entries size <= maximumWeight ifTrue: [ ^ self ].
        (self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
                | key |
                key := association key.
                entries removeKey: key ifAbsent: [ ].
                insertionOrder removeKey: key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooCachTemporal >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachTemporal >> initialize [

        super initialize.
        entries := Dictionary new.
        insertionOrder := Dictionary new.
        orderCounter := 0.
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

{ #category : 'initialization' }
CooCachTemporal >> nextOrderValue [

        ^ orderCounter := orderCounter + 1
]

{ #category : 'initialization' }
CooCachTemporal >> orderFor: aKey [

        ^ insertionOrder at: aKey ifAbsent: [ 0 ]
]

{ #category : 'initialization' }
CooCachTemporal >> recordAccessOf: aKey [

        (insertionOrder includesKey: aKey) ifTrue: [ insertionOrder at: aKey put: self nextOrderValue ]
]

{ #category : 'initialization' }
CooCachTemporal >> recordInsertionOf: aKey [

        insertionOrder at: aKey put: self nextOrderValue
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
