"
A cache that stores message entries ordered by their modification frequency, removing the least frequently used ones when exceeding a size limit.

"
Class {
	#name : 'CooCachFrequency',
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
CooCachFrequency >> association: firstAssociation precedes: secondAssociation [

	| firstModified secondModified |
	firstModified := self modificationCountFor: firstAssociation value.
	secondModified := self modificationCountFor: secondAssociation value.
	firstModified = secondModified ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
	^ firstModified > secondModified
]

{ #category : 'accessing' }
CooCachFrequency >> associations [

	^ self sortedAssociations
]

{ #category : 'accessing' }
CooCachFrequency >> at: aKey [

	^ entries at: aKey
]

{ #category : 'accessing' }
CooCachFrequency >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'initialization' }
CooCachFrequency >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
		entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooCachFrequency >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachFrequency >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 1000
]

{ #category : 'accessing' }
CooCachFrequency >> keys [

	^ self associations collect: [ :association | association key ]
]

{ #category : 'accessing' }
CooCachFrequency >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'initialization' }
CooCachFrequency >> modificationCountFor: anEntry [

	(anEntry isKindOf: Dictionary) ifFalse: [ ^ 0 ].
	^ anEntry at: #modifiedCount ifAbsent: [ 0 ]
]

{ #category : 'removing' }
CooCachFrequency >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
CooCachFrequency >> size [

	^ entries size
]

{ #category : 'accessing' }
CooCachFrequency >> sortedAssociations [

	^ entries associations asSortedCollection: [ :first :second | self association: first precedes: second ]
]
