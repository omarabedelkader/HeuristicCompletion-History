"
A cache that stores message entries ordered by their modification frequency, removing the least frequently used ones when exceeding a size limit.

"
Class {
	#name : 'CooFrequencyCache',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'maximumWeight'
	],
	#category : 'ExtendedHeuristicCompletion-History-Cache',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Cache'
}

{ #category : 'initialization' }
CooFrequencyCache >> association: firstAssociation precedes: secondAssociation [

	| firstModified secondModified |
	firstModified := self modificationCountFor: firstAssociation value.
	secondModified := self modificationCountFor: secondAssociation value.
	firstModified = secondModified ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
	^ firstModified > secondModified
]

{ #category : 'accessing' }
CooFrequencyCache >> associations [

	^ self sortedAssociations
]

{ #category : 'accessing' }
CooFrequencyCache >> at: aKey [

	^ entries at: aKey
]

{ #category : 'accessing' }
CooFrequencyCache >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'initialization' }
CooFrequencyCache >> enforceLimit [
	"We remove brut force some items."
	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
		entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooFrequencyCache >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooFrequencyCache >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 10000
]

{ #category : 'accessing' }
CooFrequencyCache >> keys [

	^ self associations collect: [ :association | association key ]
]

{ #category : 'accessing' }
CooFrequencyCache >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'initialization' }
CooFrequencyCache >> modificationCountFor: anEntry [

	(anEntry isKindOf: Dictionary) ifFalse: [ ^ 0 ].
	^ anEntry at: #modifiedCount ifAbsent: [ 0 ]
]

{ #category : 'removing' }
CooFrequencyCache >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
CooFrequencyCache >> size [

	^ entries size
]

{ #category : 'accessing' }
CooFrequencyCache >> sortedAssociations [

	^ entries associations asSortedCollection: [ :first :second | self association: first precedes: second ]
]
