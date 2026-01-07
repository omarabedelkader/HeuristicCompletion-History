Class {
	#name : 'NewCooSessionTest',
	#superclass : 'TestCase',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'origins' }
NewCooSessionTest >> programEntityHandler [

	^ session programEntityHandler
]

{ #category : 'running' }
NewCooSessionTest >> setUp [

	super setUp.
	session := CooXPSession withCache: CooTemporalCache new
]
