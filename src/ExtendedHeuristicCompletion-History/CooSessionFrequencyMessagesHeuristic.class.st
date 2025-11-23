"
A heuristic that suggests message completions using the vocabulary gathered from the current session’s recorded method activity.

"
Class {
	#name : 'CooSessionFrequencyMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Frequency',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Frequency'
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
