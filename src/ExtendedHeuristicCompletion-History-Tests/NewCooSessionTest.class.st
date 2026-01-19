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
	session := CooSession withEntityHandler: CooTemporalHandler new
]

{ #category : 'running' }
NewCooSessionTest >> testAddClassAddsEntry [

	| announcement |
	announcement := ClassAdded new
		classAdded: Point;
		yourself.

	session addNewClassInVocabulary: announcement.

	self assert: session classEntries size equals: 1
]
