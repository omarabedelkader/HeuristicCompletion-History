Class {
	#name : 'CooFrequencyHandler',
	#superclass : 'CooProgramEntityHandler',
	#instVars : [
		'classFrequencyDictionary'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'matching' }
CooFrequencyHandler >> classEntries [

	self haltOnce.
	^ classDescriptions collect: [ :each | (NECGlobalEntry contents: each className node: nil) fetcher: CooFrequencyHandler name ]
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewClassItem: anItem addedTo: aCollection [

	self halt.
]

{ #category : 'matching' }
CooFrequencyHandler >> handleNewMethodItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
	
	self halt.
]

{ #category : 'matching' }
CooFrequencyHandler >> initialize [

	super initialize.
	classFrequencyDictionary := Dictionary new.
]
