"
A heuristic that provides variable name completions using the vocabulary gathered from the current session’s tracked variable activity.

"
Class {
	#name : 'CooSessionFrequencyVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Variables-Frequency',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Variables-Frequency'
}

{ #category : 'requests' }
CooSessionFrequencyVariableHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : 'requests' }
CooSessionFrequencyVariableHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [

	^ CoCollectionFetcher onCollection: (self session words collect: [ :each |
				   | key node |
				   each isAssociation
					   ifTrue: [
							   key := each key.
							   node := each value ]
					   ifFalse: [
							   key := each.
							   node := nil ].
				   NECVariableEntry
					   contents: (key isString
							    ifTrue: [ key ]
							    ifFalse: [ key asString ])
					   node: node ])
]

{ #category : 'requests' }
CooSessionFrequencyVariableHeuristic >> session [

	^ session ifNil: [ session := CooSessionFrequencyVariable current ]
]

{ #category : 'requests' }
CooSessionFrequencyVariableHeuristic >> session: anObject [

	session := anObject
]
