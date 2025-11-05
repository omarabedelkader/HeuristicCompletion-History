"
I am an heuristic that autocompletes messages based on a session vocabulary.
"
Class {
	#name : 'CooSessionFrequencyMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Messages-Frequency',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Messages-Frequency'
}

{ #category : 'requests' }
CooSessionFrequencyMessagesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isMethod or: [ aNode isMessage ]
]

{ #category : 'requests' }
CooSessionFrequencyMessagesHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [
	
	^ CoCollectionFetcher onCollection: 
			( self session words collect: [ :each | (NECSelectorEntry contents: each key node: each value) ])
]

{ #category : 'accessing' }
CooSessionFrequencyMessagesHeuristic >> session [
	^ session ifNil: [ session := CooSessionFrequencyMessages current ]
]

{ #category : 'accessing' }
CooSessionFrequencyMessagesHeuristic >> session: anObject [
	session := anObject
]
