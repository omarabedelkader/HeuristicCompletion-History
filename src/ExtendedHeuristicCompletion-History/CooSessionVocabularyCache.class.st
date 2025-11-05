"
I'm a cach vocab
"
Class {
	#name : 'CooSessionVocabularyCache',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'maximumWeight'
	],
	#category : 'ExtendedHeuristicCompletion-History-Frequency-Messages',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Frequency-Messages'
}

{ #category : 'initialization' }
CooSessionVocabularyCache >> association: firstAssociation precedes: secondAssociation [

	| firstModified secondModified |
	firstModified := self modificationCountFor: firstAssociation value.
	secondModified := self modificationCountFor: secondAssociation value.
	firstModified = secondModified
	ifTrue: [ ^ firstAssociation key asString <= secondAssociation key asString ].
	^ firstModified > secondModified
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> associations [

	^ self sortedAssociations
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> at: aKey [

	^ entries at: aKey
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> at: aKey put: aValue [

	entries at: aKey put: aValue.
	self enforceLimit.
	^ aValue
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> enforceLimit [

	entries size <= maximumWeight ifTrue: [ ^ self ].
	self sortedAssociations
	copyFrom: maximumWeight + 1
	to: entries size
	do: [ :association | entries removeKey: association key ifAbsent: [ ] ]
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> includesKey: aKey [

	^ entries includesKey: aKey
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> initialize [

	super initialize.
	entries := Dictionary new.
	maximumWeight := 1000
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> keys [

	^ self associations collect: [ :association | association key ]
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> maximumWeight: anInteger [

	maximumWeight := anInteger.
	self enforceLimit.
	^ self
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> modificationCountFor: anEntry [

	(anEntry isKindOf: Dictionary)
	ifFalse: [ ^ 0 ].
	^ anEntry at: #modifiedCount ifAbsent: [ 0 ]
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> removeKey: aKey ifAbsent: aBlock [

	^ entries removeKey: aKey ifAbsent: aBlock
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> size [

	^ entries size
]

{ #category : 'initialization' }
CooSessionVocabularyCache >> sortedAssociations [

	^ entries associations
	asSortedCollection: [ :first :second |
	self association: first precedes: second ]
]
