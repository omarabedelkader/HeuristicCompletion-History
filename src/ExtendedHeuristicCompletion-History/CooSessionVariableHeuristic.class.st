"
Session variables
"
Class {
	#name : 'CooSessionVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Temporal-Classes',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Temporal-Classes'
}

{ #category : 'requests' }
CooSessionVariableHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : 'requests' }
CooSessionVariableHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [
	
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
CooSessionVariableHeuristic >> session [
	^ session ifNil: [ session := CooSessionVariable current ]
]

{ #category : 'accessing' }
CooSessionVariableHeuristic >> session: anObject [
	session := anObject
]
