"
Minimal completion context used by CooHistoryBenchmarkQueryRunner.

The upstream benchmark framework relies on a context class that is not part
of any published repository, so this experiment defines its own explicit
context implementing exactly the protocol required by
CoASTResultSetBuilder and the completion heuristics:
completionToken, completionTokenStart, isScripting, completionClass,
doItContext, doItRequestor and variableBindingNames.

The benchmark never runs inside a playground or an editor engine, hence
isScripting answers false and no do-it information is available.
"
Class {
	#name : 'CooBenchmarkCompletionContext',
	#superclass : 'Object',
	#instVars : [
		'callsite',
		'position',
		'completionToken',
		'completionTokenStart',
		'completionClass'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Execution',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Execution'
}

{ #category : 'instance creation' }
CooBenchmarkCompletionContext class >> forCallsite: aNode position: anInteger token: aString inClass: aClass [

	^ self new
		  callsite: aNode;
		  position: anInteger;
		  completionToken: aString;
		  completionTokenStart: anInteger;
		  completionClass: aClass;
		  yourself
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> callsite [

	^ callsite
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> callsite: aNode [

	callsite := aNode
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> completionClass [

	^ completionClass
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> completionClass: aClass [

	completionClass := aClass
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> completionToken [

	^ completionToken
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> completionToken: aString [

	completionToken := aString
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> completionTokenStart [

	^ completionTokenStart
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> completionTokenStart: anInteger [

	completionTokenStart := anInteger
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> doItContext [

	^ nil
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> doItRequestor [

	^ nil
]

{ #category : 'testing' }
CooBenchmarkCompletionContext >> isScripting [

	^ false
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> position [

	^ position
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> position: anInteger [

	position := anInteger
]

{ #category : 'printing' }
CooBenchmarkCompletionContext >> printOn: aStream [

	super printOn: aStream.
	aStream
		nextPutAll: ' token: ';
		nextPutAll: completionToken asString
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> title [

	^ ''
]

{ #category : 'accessing' }
CooBenchmarkCompletionContext >> variableBindingNames [

	^ #(  )
]
