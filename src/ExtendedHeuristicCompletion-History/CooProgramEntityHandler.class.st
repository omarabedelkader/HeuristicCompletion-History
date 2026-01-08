Class {
	#name : 'CooProgramEntityHandler',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'accessing - computed' }
CooProgramEntityHandler >> computeDeltaMessageBetween: aNewMethodAst andOld: anOldMethodAst [

	^ ((aNewMethodAst allChildren select: [ :each | each isMessage ])
			collect: [ :each | each selector ])
		  difference:
		  ((anOldMethodAst allChildren select: [ :each | each isMessage ]) 
				collect: [ :each | each selector ])
]

{ #category : 'accessing - computed' }
CooProgramEntityHandler >> computeDeltaMessageOf: aMethodModifiedAnnouncement [

	^ self 
		computeDeltaMessageBetween: aMethodModifiedAnnouncement method ast
		andOld: aMethodModifiedAnnouncement oldMethod ast 
	
]

{ #category : 'accessing' }
CooProgramEntityHandler >> size [ 

	^ 0
]
