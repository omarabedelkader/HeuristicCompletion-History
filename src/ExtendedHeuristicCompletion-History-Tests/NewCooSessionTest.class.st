Class {
	#name : 'NewCooSessionTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-NewTestForHistory',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'NewTestForHistory'
}

{ #category : 'origins' }
NewCooSessionTest >> cache [

	^ session vocabularyCache
]

{ #category : 'running' }
NewCooSessionTest >> setUp [

	super setUp.
	session := CooXPSession withCache: CooNewTemporalCache new
]
