"
I am an heuristic that autocompletes messages based on a session vocabulary.
"
Class {
	#name : 'CooSessionMessagesHeuristic',
	#superclass : 'CoASTNodeFetcherHeuristic',
	#instVars : [
		'session'
	],
	#classVars : [
		'SessionClass'
	],
	#category : 'HeuristicCompletion-Model-History-History-Fetcher',
	#package : 'HeuristicCompletion-Model-History',
	#tag : 'History-Fetcher'
}

{ #category : 'requests' }
CooSessionMessagesHeuristic >> appliesForNode: aNode inContext: aContext [

	^ aNode isMethod or: [ aNode isMessage ]
]

{ #category : 'requests' }
CooSessionMessagesHeuristic >> buildFetcherFor: aMessageNode inContext: aContext [

	| prefix entries |
	prefix := aContext completionToken ifNil: [ '' ].
	entries := self session
		           messageEntriesForPrefix: prefix
		           limit: 20
		           inContext: aContext.
	^ CoCollectionFetcher onCollection: entries
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session [

	^ session ifNil: [ session := self sessionClass current ]
]

{ #category : 'accessing' }
CooSessionMessagesHeuristic >> session: anObject [
	session := anObject
]

{ #category : 'as yet unclassified' }
CooSessionMessagesHeuristic >> sessionClass [

	^ SessionClass ifNil: [ SessionClass := CooTemporalHistorySession ]
]

{ #category : 'as yet unclassified' }
CooSessionMessagesHeuristic >> sessionClass: aClass [

	SessionClass := aClass
]
