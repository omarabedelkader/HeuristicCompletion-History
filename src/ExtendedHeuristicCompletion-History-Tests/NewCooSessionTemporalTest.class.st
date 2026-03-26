Class {
	#name : 'NewCooSessionTemporalTest',
	#superclass : 'NewCooSessionTest',
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session'
}

{ #category : 'running' }
NewCooSessionTemporalTest >> modifiedMethodAnnouncement [

	^ MethodModified
		  methodChangedFrom: self class >> #ourOriginalPrintString
		  to: self class >> #ourModifiedPrintString
		  oldProtocol: 'toto'
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> ourModifiedPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString.
	
	The following body is garbage"

	self testComputeMessages.
	^ self printStringLimitedTo: 50000
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> ourOriginalPrintString [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString.
	
	The following body is garbage it is just to compute the diff between two method versions."

	^ self printStringLimitedTo: 50000
]

{ #category : 'running' }
NewCooSessionTemporalTest >> removedMethodAnnouncement [

	^ MethodRemoved new
		  methodOrigin: NewCooSessionTemporalTest;
		  method: NewCooSessionTemporalTest >> #ourModifiedPrintString
]

{ #category : 'tests - announcements' }
NewCooSessionTemporalTest >> testAnnouncementAddModifiedMethodComputesMessageDiff [

	| announcement |
	announcement := self modifiedMethodAnnouncement.

	session addModifiedMethodInVocabulary: announcement.
	self 
		assert: session programEntityHandler methodDescriptions first deltaMessages asArray 
		equals: #( #testComputeMessages )
]

{ #category : 'tests - announcements' }
NewCooSessionTemporalTest >> testAnnouncementAddModifiedMethodRegistersEntry [

	| announcement |
	announcement := MethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.

	session addModifiedMethodInVocabulary: announcement.
	self 
		assert: session programEntityHandler selectorEntries size 
		equals: 1
]

{ #category : 'tests - announcements' }
NewCooSessionTemporalTest >> testAnnouncementAddNewMethodRegistersEntry [

	| announcement |
	announcement := MethodAdded new
		method: Point >> #degrees;
		yourself.

	session addNewMethodInVocabulary: announcement.
	self 
		assert: session programEntityHandler selectorEntries size 
		equals: 1
]

{ #category : 'tests - announcements' }
NewCooSessionTemporalTest >> testAnnouncementAddNewVariableAnnouncementRegistersEntry [

	| announcement entry |
	announcement := ClassAdded new
		classAdded: NewCooSessionTemporalTest;
		yourself.
	session addNewClassInVocabulary: announcement.

	entry := session programEntityHandler classDescriptions first.

	self 
		assert: session programEntityHandler classEntries size 
		equals: 1
]

{ #category : 'tests - announcements' }
NewCooSessionTemporalTest >> testAnnouncementAddedAndRemovedTheSameMethod [
	| announcement |
	announcement := self removedMethodAnnouncement.
	session removeMethodFromVocabulary: announcement.
	
	announcement := self modifiedMethodAnnouncement.
	session addModifiedMethodInVocabulary: announcement.
	
	
	self 
		assert: session programEntityHandler methodDescriptions first deltaMessages asArray
		equals: #( #testComputeMessages )
]

{ #category : 'tests - changing handler' }
NewCooSessionTemporalTest >> testChangeHandler [

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
	
	self assert: session selectorEntries size equals: 4.
	session shiftHandlerTo: CooFrequencyHandler new. 
	
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#degrees #debt) asOrderedCollection 

	


]

{ #category : 'tests - changing handler' }
NewCooSessionTemporalTest >> testChangeHandlerToTheSame [

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
	
	self assert: session selectorEntries size equals: 4.
	self assert: session methodDescriptions size equals: 4.
	
	session shiftHandlerTo: CooTemporalHandler new. 
	
	self assert: session selectorEntries size equals: 4.
	self assert: session methodDescriptions size equals: 4.
	
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#degrees #degrees #degrees #debt) asOrderedCollection 

	


]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> testComputeMessages [

	| announcement |
	announcement := MethodModified
	                methodChangedFrom: self class >> #ourOriginalPrintString
	                to: self class >> #ourModifiedPrintString
	                oldProtocol: 'toto'.

	self 
		assert: (session computeDeltaMessageOf: announcement) asArray 
		equals: #( #testComputeMessages )
]

{ #category : 'tests - compute' }
NewCooSessionTemporalTest >> testComputeMessagesOfSimilarMethods [

	| announcement |
	announcement := MethodModified methodChangedFrom: self class >> #ourOriginalPrintString to: (self class >> #ourOriginalPrintString) oldProtocol: 'toto'.

	self assert: (session computeDeltaMessageOf: announcement) isEmpty
]

{ #category : 'tests - announcements' }
NewCooSessionTemporalTest >> testHandlerChanges [

	| anns |
	anns := { 
		MethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.
		MethodModified methodChangedFrom: Point >> #degrees to: (Point >> #degrees) copy oldProtocol: 'toto'.
		}.
	
	anns do: [ :each | 
		session addModifiedMethodInVocabulary: each ].
	
	self 
		assert: session programEntityHandler selectorEntries size 
		equals: 2.
	
]

{ #category : 'tests - changing handler' }
NewCooSessionTemporalTest >> testLowLevelHandlerPopulation [

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
	
	self assert: session selectorEntries size equals: 4.
	self 
		assert: (session selectorEntries collect: [ :each | each selector ])
		equals: #(#debt #degrees #degrees #degrees) asOrderedCollection 

	


]

{ #category : 'tests - changing handler' }
NewCooSessionTemporalTest >> testLowLevelSessionPopulation [

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
		        yourself}.
	
	anns do: [ :each | 
		session addMethodItem: each ].
	
	self assert: session classDescriptions size equals: 0.
	self assert: session methodDescriptions size equals: 2.
	


]

{ #category : 'running' }
NewCooSessionTemporalTest >> testSessionNewCreatesAndEmptySession [


	self assert: session classDescriptions size equals: 0
]
