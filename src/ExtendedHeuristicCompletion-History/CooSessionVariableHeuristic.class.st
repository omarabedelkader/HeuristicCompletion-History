"
A heuristic that offers variable name completions based on the most recently used variables tracked in the current temporal session.

"
Class {
	#name : 'CooSessionVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'requests' }
CooSessionVariableHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : 'requests' }
CooSessionVariableHeuristic >> buildFetcherFor: aVariableNode 
	inContext: aContext [
	
		| fetcher |
		fetcher := CoCollectionFetcher new.
      ^ fetcher
				 collection: (self session classEntries collect: [ :each |
					"we should indicate that the fetcher is  composed from an existing one and the session"
                              (each node: aVariableNode)
											fetcher: fetcher ])
]

{ #category : 'accessing' }
CooSessionVariableHeuristic >> session [
	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooSessionVariableHeuristic >> session: anObject [
	session := anObject
]
