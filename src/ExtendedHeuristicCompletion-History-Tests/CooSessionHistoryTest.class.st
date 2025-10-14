Class {
	#name : 'CooSessionHistoryTest',
	#superclass : 'CoMiniTestCase',
	#instVars : [
		'session',
		'context'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Tests'
}

{ #category : 'running' }
CooSessionHistoryTest >> setUp [ 

    super setUp.
    session := CooTemporalHistorySession new.
    context := CooDummyContext new completionClass: Object; yourself
]

{ #category : 'running' }
CooSessionHistoryTest >> testCompletionSelectedRecordsHistoryItem [ 

    | entry item |
    entry := NECSelectorEntry contents: 'histFoo' node: nil.
    session completionSelected: entry in: context.
    item := session history at: 'histFoo'.
    self assert: item notNil.
    self assert: item count equals: 1.
    self assert: item kind equals: #message
]

{ #category : 'running' }
CooSessionHistoryTest >> testGlobalEntriesRankByFrequency [ 

    | g1 g2 results |
    g1 := NECGlobalEntry contents: 'GG1' node: nil.
    g2 := NECGlobalEntry contents: 'GG2' node: nil.
    session completionSelected: g1 in: context.
    session completionSelected: g2 in: context.
    session completionSelected: g2 in: context.
    results := session globalEntriesForPrefix: 'GG' limit: 2 inContext: context.
    self assert: (results first contents) equals: 'GG2'.
    self assert: (results second contents) equals: 'GG1'
]

{ #category : 'running' }
CooSessionHistoryTest >> testMessageEntriesRankByFrequency [ 

    | e1 e2 results |
    e1 := NECSelectorEntry contents: 'fooBar' node: nil.
    e2 := NECSelectorEntry contents: 'fooBaz' node: nil.
    session completionSelected: e1 in: context.
    session completionSelected: e2 in: context.
    session completionSelected: e2 in: context.
    results := session messageEntriesForPrefix: 'foo' limit: 2 inContext: context.
    self assert: (results first contents) equals: 'fooBaz'.
    self assert: (results second contents) equals: 'fooBar'
]
