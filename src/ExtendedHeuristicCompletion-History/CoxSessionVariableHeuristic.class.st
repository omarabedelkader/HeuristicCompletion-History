"
A heuristic that offers variable name completions based on the most recently used variables tracked in the current temporal session.

"
Class {
	#name : 'CoxSessionVariableHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'requests' }
CoxSessionVariableHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isVariable
]

{ #category : 'requests' }
CoxSessionVariableHeuristic >> buildFetcherFor: aVariableNode 
	inContext: aContext [
	
		| fetcher |
		fetcher := CoCollectionFetcher new.
      ^ fetcher
				 collection: (self session variableNames collect: [ :each |
                               (NECGlobalEntry contents: each node: aVariableNode) 
											fetcher: fetcher ])
]

{ #category : 'accessing' }
CoxSessionVariableHeuristic >> session [
	^ session ifNil: [ session := CooXPSession current ]
]

{ #category : 'accessing' }
CoxSessionVariableHeuristic >> session: anObject [
	session := anObject
]
