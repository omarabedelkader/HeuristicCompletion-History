"
WHAT TO TEST: an immutable description of one benchmark completion query.

One query is one callsite in one method of one class: the expected full
candidate (a selector or a class name), the AST node representing the
callsite, and provenance information. Queries are extracted once per
repository and shared by every configuration so that treatment comparisons
remain paired.
"
Class {
	#name : 'CooHistoryBenchmarkQuery',
	#superclass : 'Object',
	#instVars : [
		'targetKind',
		'className',
		'methodSelector',
		'expectedCandidate',
		'astNode',
		'position',
		'sourceCommit'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Query',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Query'
}

{ #category : 'comparing' }
CooHistoryBenchmarkQuery >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self species = anObject species ifFalse: [ ^ false ].
	^ self targetKind = anObject targetKind and: [
		  self className = anObject className and: [
			  self methodSelector = anObject methodSelector and: [
				  self expectedCandidate = anObject expectedCandidate and: [
					  self position = anObject position ] ] ] ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> astNode [

	^ astNode
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> astNode: aNode [

	astNode := aNode
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> className [

	^ className
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> className: aString [

	className := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> expectedCandidate [

	^ expectedCandidate
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> expectedCandidate: anObject [

	expectedCandidate := anObject
]

{ #category : 'comparing' }
CooHistoryBenchmarkQuery >> hash [

	^ (self targetKind hash
	   bitXor: self className hash)
	  bitXor: (self methodSelector hash bitXor: self expectedCandidate hash)
]

{ #category : 'testing' }
CooHistoryBenchmarkQuery >> isSelectorTarget [

	^ targetKind = #selector
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> methodSelector [

	^ methodSelector
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> methodSelector: aSymbol [

	methodSelector := aSymbol
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> position [

	^ position
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> position: anInteger [

	position := anInteger
]

{ #category : 'printing' }
CooHistoryBenchmarkQuery >> printOn: aStream [

	aStream
		nextPutAll: targetKind asString;
		nextPutAll: ' ';
		nextPutAll: className asString;
		nextPutAll: '>>';
		print: methodSelector;
		nextPutAll: ' expecting ';
		print: expectedCandidate
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> sourceCommit [

	^ sourceCommit
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> sourceCommit: aString [

	sourceCommit := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> targetKind [

	^ targetKind
]

{ #category : 'accessing' }
CooHistoryBenchmarkQuery >> targetKind: aSymbol [

	targetKind := aSymbol
]
