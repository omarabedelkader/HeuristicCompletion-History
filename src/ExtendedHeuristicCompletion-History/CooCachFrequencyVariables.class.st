"
I'm a cach vocab
"
Class {
	#name : 'CooCachFrequencyVariables',
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
CooCachFrequencyVariables >> association: firstAssociation precedes: secondAssociation [

	| firstModified secondModified |
	firstModified := self modificationCountFor: firstAssociation value.
	secondModified := self modificationCountFor: secondAssociation value.
	firstModified = secondModified
	ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
	^ firstModified > secondModified
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> associations [

	^ self sortedAssociations
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> at: aKey [

	^ entries at: aKey
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	(self sortedAssociations
		copyFrom: maximumWeight + 1
		to: entries size)
		do: [ :association | entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 1000
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> keys [

	^ self associations collect: [ :association | association key ]
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> modificationCountFor: anEntry [

	(anEntry isKindOf: Dictionary)
	ifFalse: [ ^ 0 ].
	^ anEntry at: #modifiedCount ifAbsent: [ 0 ]
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> size [

	^ entries size
]

{ #category : 'initialization' }
CooCachFrequencyVariables >> sortedAssociations [

	^ entries associations
	asSortedCollection: [ :first :second |
	self association: first precedes: second ]
]
