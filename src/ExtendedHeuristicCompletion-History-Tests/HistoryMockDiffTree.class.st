Class {
	#name : 'HistoryMockDiffTree',
	#superclass : 'Object',
	#instVars : [
		'nodes'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockDiffTree class >> nodes: aCollection [
    ^ self new
        nodes: aCollection;
        yourself
]

{ #category : 'accessing' }
HistoryMockDiffTree >> allChildrenDo: aBlock [
    nodes do: [ :each | aBlock value: (HistoryMockDiffNode value: each) ]
]

{ #category : 'accessing' }
HistoryMockDiffTree >> nodes: aCollection [
    | nodes |
nodes := aCollection asArray
]
