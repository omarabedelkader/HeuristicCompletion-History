"
Session variables
"
Class {
	#name : 'CooSessionTemporalVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Classes-Temporal',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Classes-Temporal'
}

{ #category : 'requests' }
CooSessionTemporalVariableHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : 'requests' }
CooSessionTemporalVariableHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [
	
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
CooSessionTemporalVariableHeuristic >> session [
	^ session ifNil: [ session := CooSessionTemporalVariable current ]
]

{ #category : 'accessing' }
CooSessionTemporalVariableHeuristic >> session: anObject [
	session := anObject
]
