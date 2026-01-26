"
I am an heuristic that autocompletes messages based on a session defined and modified methods.
"
Class {
	#name : 'CooSessionMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'requests' }
CooSessionMessagesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isMethod or: [ aNode isMessage ]
]

{ #category : 'requests' }
CooSessionMessagesHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [

	^ CooMessageSessionFetcher new astNode: aMessageNode; yourself
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session [
	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session: anObject [
	session := anObject
]
