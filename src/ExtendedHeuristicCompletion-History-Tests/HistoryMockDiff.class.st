Class {
	#name : 'HistoryMockDiff',
	#superclass : 'Object',
	#instVars : [
		'nodes',
		'isEmpty'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'accessing' }
HistoryMockDiff class >> nodes: aCollection [

	^ self new
		  nodes: aCollection;
		  yourself
]

{ #category : 'accessing' }
HistoryMockDiff >> isEmpty [
    ^ isEmpty
]

{ #category : 'accessing' }
HistoryMockDiff >> isEmpty: aBoolean [
    isEmpty := aBoolean
]

{ #category : 'accessing' }
HistoryMockDiff >> nodes: aCollection [
    nodes := aCollection asArray.
    self isEmpty: nodes isEmpty
]

{ #category : 'accessing' }
HistoryMockDiff >> tree [
    ^ HistoryMockDiffTree nodes: nodes
]
