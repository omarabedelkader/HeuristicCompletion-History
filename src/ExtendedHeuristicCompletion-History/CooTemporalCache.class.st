"
A cache that stores message entries ordered by their most recent access time, removing the oldest ones when the size limit is exceeded.

"
Class {
	#name : 'CooTemporalCache',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'maximumWeight',
		'insertionOrder',
		'orderCounter'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cache',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cache'
}

{ #category : 'initialization' }
CooTemporalCache >> association: firstAssociation precedes: secondAssociation [

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
CooTemporalCache >> associations [

	^ self sortedAssociations
]

{ #category : 'accessing' }
CooTemporalCache >> at: aKey [

        | entry |
        entry := entries at: aKey.
        self recordAccessOf: aKey.
        ^ entry
]

{ #category : 'accessing' }
CooTemporalCache >> at: aKey put: aValue [

        entries at: aKey put: aValue.
        self recordInsertionOf: aKey.
        self enforceLimit.
        ^ aValue
]

{ #category : 'accessing' }
CooTemporalCache >> enforceLimit [
        entries size <= maximumWeight ifTrue: [ ^ self ].
        (self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
                | key |
                key := association key.
                entries removeKey: key ifAbsent: [ ].
                insertionOrder removeKey: key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooTemporalCache >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooTemporalCache >> initialize [

	super initialize.
	entries := Dictionary new.
	insertionOrder := Dictionary new.
	orderCounter := 0.
	maximumWeight := 1000
]

{ #category : 'accessing' }
CooTemporalCache >> keys [

	^ self sortedAssociations collect: [ :association | association key ]
]

{ #category : 'accessing' }
CooTemporalCache >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'initialization' }
CooTemporalCache >> nextOrderValue [

        ^ orderCounter := orderCounter + 1
]

{ #category : 'initialization' }
CooTemporalCache >> orderFor: aKey [

        ^ insertionOrder at: aKey ifAbsent: [ 0 ]
]

{ #category : 'initialization' }
CooTemporalCache >> recordAccessOf: aKey [

        (insertionOrder includesKey: aKey) ifTrue: [ insertionOrder at: aKey put: self nextOrderValue ]
]

{ #category : 'initialization' }
CooTemporalCache >> recordInsertionOf: aKey [

        insertionOrder at: aKey put: self nextOrderValue
]

{ #category : 'removing' }
CooTemporalCache >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
CooTemporalCache >> size [

	^ entries size
]

{ #category : 'accessing' }
CooTemporalCache >> sortedAssociations [

	^ entries associations asSortedCollection: [ :first :second | self association: first precedes: second ]
]
