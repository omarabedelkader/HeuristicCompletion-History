Class {
	#name : 'CooSessionVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#classVars : [
		'SessionClass'
	],
	#category : 'HeuristicCompletion-Model-History-History-Fetcher',
	#package : 'HeuristicCompletion-Model-History',
	#tag : 'History-Fetcher'
}

{ #category : 'requests' }
CooSessionVariableHeuristic >> appliesForNode: aNode inContext: aContext [ 

    "Be conservative: only when we are in a variable/global context.
     Many variable nodes are class refs (uppercase first)."
    ^ aNode isVariable or: [ aNode isGlobal ]
]

{ #category : 'requests' }
CooSessionVariableHeuristic >> buildFetcherFor: aNode inContext: aContext [ 

    | prefix entries |
    prefix := aContext completionToken ifNil: [ '' ].
    entries := self session globalEntriesForPrefix: prefix limit: 20 inContext: aContext.
    ^ CoCollectionFetcher onCollection: entries
]

{ #category : 'requests' }
CooSessionVariableHeuristic >> session [

	^ session ifNil: [ session := self sessionClass current ]
]

{ #category : 'requests' }
CooSessionVariableHeuristic >> session: aSession [ 
	session := aSession
]

{ #category : 'as yet unclassified' }
CooSessionVariableHeuristic >> sessionClass [

	^ SessionClass ifNil: [ SessionClass := CooTemporalHistorySession ]
]

{ #category : 'as yet unclassified' }
CooSessionVariableHeuristic >> sessionClass: aClass [

	SessionClass := aClass
]
