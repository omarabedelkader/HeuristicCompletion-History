Class {
	#name : 'CooCachFrequencyMessages',
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
CooCachFrequencyMessages >> association: firstAssociation precedes: secondAssociation [

	| firstModified secondModified |
	firstModified := self modificationCountFor: firstAssociation value.
	secondModified := self modificationCountFor: secondAssociation value.
	firstModified = secondModified ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
	^ firstModified > secondModified
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> associations [

	^ self sortedAssociations
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> at: aKey [

	^ entries at: aKey
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'initialization' }
CooCachFrequencyMessages >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations copyFrom: maximumWeight + 1 to: entries size) do: [ :association |
		entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'testing' }
CooCachFrequencyMessages >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachFrequencyMessages >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 1000
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> keys [

	^ self associations collect: [ :association | association key ]
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'initialization' }
CooCachFrequencyMessages >> modificationCountFor: anEntry [

	(anEntry isKindOf: Dictionary) ifFalse: [ ^ 0 ].
	^ anEntry at: #modifiedCount ifAbsent: [ 0 ]
]

{ #category : 'removing' }
CooCachFrequencyMessages >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> size [

	^ entries size
]

{ #category : 'accessing' }
CooCachFrequencyMessages >> sortedAssociations [

	^ entries associations asSortedCollection: [ :first :second | self association: first precedes: second ]
]
