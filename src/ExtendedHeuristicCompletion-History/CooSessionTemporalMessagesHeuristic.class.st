"
A heuristic that suggests message completions based on the most recently used methods recorded in the current temporal session.

"
Class {
	#name : 'CooSessionTemporalMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Temporal',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Temporal'
}

{ #category : 'requests' }
CooSessionTemporalMessagesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isMethod or: [ aNode isMessage ]
]

{ #category : 'requests' }
CooSessionTemporalMessagesHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [
	"We generate a list based on the previous selectors"
	
	^ CoCollectionFetcher onCollection:
		  (self session words collect: [ :each | NECSelectorEntry contents: each key node: each value ])
]

{ #category : 'requests' }
CooSessionTemporalMessagesHeuristic >> session [

	^ session ifNil: [ session := CooSessionTemporalMessages current ]
]

{ #category : 'requests' }
CooSessionTemporalMessagesHeuristic >> session: anObject [

	session := anObject
]
