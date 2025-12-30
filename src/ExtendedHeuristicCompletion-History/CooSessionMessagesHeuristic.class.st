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
CooSessionMessagesHeuristic >> buildFetcherFor: aMessageNode 
	inContext: aContext [
	
		| fetcher matchingSelectors token |
		matchingSelectors := OrderedCollection new.
		"this is stupid to go over all the selectors but let us try I want to see if I get better results.
		Normally this is not needed since there is a filter: 
		look into configureFetcher: aFetcher forNode: aNode
		" 
		
		token := aContext completionToken.
		self session selectors do: [ :each | (each beginsWith: token) 
				ifTrue: [ matchingSelectors 
						add:  ((NECSelectorEntry contents: each node: aMessageNode) 
											fetcher: fetcher ) ] ].

		fetcher := CoCollectionFetcher new.    
		^ fetcher collection: matchingSelectors
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session [
	^ session ifNil: [ session := CooXPSession current ]
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session: anObject [
	session := anObject
]
