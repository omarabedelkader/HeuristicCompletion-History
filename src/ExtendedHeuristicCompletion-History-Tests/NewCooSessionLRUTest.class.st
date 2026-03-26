Class {
	#name : 'NewCooSessionLRUTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'running' }
NewCooSessionLRUTest >> setUp [

	super setUp.
	session := CooSession new programEntityHandler: CooLRUHandler new
]

{ #category : 'tests' }
NewCooSessionLRUTest >> testHandler [

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

{ #category : 'tests' }
NewCooSessionLRUTest >> testHandlerSaturate [

	2 timesRepeat: [ 
		1 to: 1000 do: [ :i |
		session addMethodItem: (CooModifiedMethodHistoryItem new
		        selector: (#degrees, i asString) asSymbol;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself)
			]].
	
	100 timesRepeat: [ 	
		session addMethodItem: (CooModifiedMethodHistoryItem new
		        selector: #debt;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself) ].
		100 timesRepeat: [ 	
		session addMethodItem: (CooModifiedMethodHistoryItem new
		        selector: #debt2;
		        live: true;
		        timestamp: DateAndTime now;
		        nameOfClass: 'Point';
		        yourself) ].
		
	
	self assert: session selectorEntries size equals: 1000.
	
	self assert: ((session selectorEntries collect: [ :each | each selector ]) includesAll: { #debt . #debt2} ).
	
	self deny: ((session selectorEntries collect: [ :each | each selector ]) includesAll: { #degrees1 . #degrees2 })


]
