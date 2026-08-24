"
Builds the deterministic history of the fixture subject and exposes it as a
CooHistoryBenchmarkRepository with a custom replay block, so integration
tests run the full experiment infrastructure without cloning repositories.
"
Class {
	#name : 'CooFixtureHistory',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Fixtures',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Fixtures'
}

{ #category : 'fixture' }
CooFixtureHistory class >> addMethodItemNamed: aSelector inClass: aClassName deltaMessages: aCollection to: aSession [

	| item |
	item := CooAddedMethodHistoryItem new
		        selector: aSelector;
		        nameOfClass: aClassName;
		        ast: nil;
		        live: false;
		        timestamp: DateAndTime now;
		        yourself.
	item deltaMessages: aCollection.
	aSession addMethodItem: item
]

{ #category : 'fixture' }
CooFixtureHistory class >> populateSession: aSession [
	"Replays the complete fixture history. Window semantics: anything above 0
	replays the whole deterministic history."

	self addMethodItemNamed: #drawBox inClass: 'CooFixtureCanvas' deltaMessages: #(  ) to: aSession.
	self addMethodItemNamed: #renderWidget inClass: 'CooFixtureCanvas' deltaMessages: #( drawBox ) to: aSession.
	self addMethodItemNamed: #paintUsing inClass: 'CooFixtureCanvas' deltaMessages: #(  ) to: aSession.
	self addMethodItemNamed: #refreshAll inClass: 'CooFixtureCanvas'
		deltaMessages: #( renderWidget paintUsing )
		to: aSession.

	aSession addClassItem: (CooAddedClassHistoryItem new
			 nameOfClass: 'CooFixturePalette';
			 live: false;
			 timestamp: DateAndTime now;
			 yourself)
]

{ #category : 'fixture' }
CooFixtureHistory class >> repository [

	^ self repositoryWithReplayBlock: [ :session :window |
		  window > 0 ifTrue: [ self populateSession: session ] ]
]

{ #category : 'fixture' }
CooFixtureHistory class >> repositoryWithReplayBlock: aBlock [

	^ CooHistoryBenchmarkRepository
		  name: 'Fixture'
		  url: 'fixture://image-local'
		  replayBlock: aBlock
]
