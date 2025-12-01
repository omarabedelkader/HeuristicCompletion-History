"
I am an heuristic that autocompletes messages based on a session vocabulary.
"
Class {
	#name : 'CoxSessionMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'requests' }
CoxSessionMessagesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isMethod or: [ aNode isMessage ]
]

{ #category : 'requests' }
CoxSessionMessagesHeuristic >> buildFetcherFor: aMessageNode 
	inContext: aContext [
	
		| fetcher |
		fetcher := CoCollectionFetcher new.
      ^ fetcher
				 collection: (self session selectors collect: [ :each |
                               (NECSelectorEntry contents: each node: aMessageNode) 
											fetcher: fetcher ])
]

{ #category : 'accessing' }
CoxSessionMessagesHeuristic >> session [
	^ session ifNil: [ session := CooXPSession current ]
]

{ #category : 'accessing' }
CoxSessionMessagesHeuristic >> session: anObject [
	session := anObject
]
