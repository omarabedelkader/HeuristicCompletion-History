"
A heuristic that offers variable name completions based on the most recently used variables tracked in the current temporal session.

"
Class {
	#name : 'CoxSessionVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'requests' }
CoxSessionVariableHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : 'requests' }
CoxSessionVariableHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [
	
        ^ CoCollectionFetcher onCollection:
                        (self session words collect: [ :each |
                                | key node |
                                each isAssociation
                                        ifTrue: [ key := each key. node := each value ]
                                        ifFalse: [ key := each. node := nil ].
                                NECVariableEntry
                                        contents: (key isString
                                                ifTrue: [ key ]
                                                ifFalse: [ key asString ])
                                        node: node ])
]

{ #category : 'accessing' }
CoxSessionVariableHeuristic >> session [
	^ session ifNil: [ session := CooSessionTemporalVariable current ]
]

{ #category : 'accessing' }
CoxSessionVariableHeuristic >> session: anObject [
	session := anObject
]
