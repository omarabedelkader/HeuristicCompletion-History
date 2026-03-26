Class {
	#name : 'NewCooSessionFrequencyTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'running' }
NewCooSessionFrequencyTest >> setUp [

	super setUp.
	session := CooSession new programEntityHandler: CooFrequencyHandler new
]

{ #category : 'running' }
NewCooSessionFrequencyTest >> testHandler [

	| anns |
	anns := { 
		
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #degrees;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself.
		CooModifiedMethodHistoryItem new
		        selector: #debt;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself}.
	
	anns do: [ :each | 
		session addMethodItem: each ].
	
	self assert: session selectorEntries size equals: 2.
	
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#degrees #debt) asOrderedCollection 

	


]
