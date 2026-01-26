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
CooSessionVariableHeuristic >> buildFetcherFor: aVariableNode inContext: aContext [

	^ CooVariableSessionFetcher new astNode: aVariableNode ; yourself 
	
]

{ #category : 'accessing' }
CooSessionVariableHeuristic >> session [
	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooSessionVariableHeuristic >> session: anObject [
	session := anObject
]
