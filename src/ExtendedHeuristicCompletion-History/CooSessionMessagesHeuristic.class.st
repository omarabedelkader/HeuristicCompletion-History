"
I am an heuristic that autocompletes messages based on a session vocabulary.
"
Class {
	#name : 'CooSessionMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Frequency-Messages',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Frequency-Messages'
}

{ #category : 'requests' }
CooSessionMessagesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isMethod or: [ aNode isMessage ]
]

{ #category : 'requests' }
CooSessionMessagesHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [
	
	^ CoCollectionFetcher onCollection: 
			( self session words collect: [ :each | (NECSelectorEntry contents: each key node: each value) ])
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session [
	^ session ifNil: [ session := CooSession current ]
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session: anObject [
	session := anObject
]
