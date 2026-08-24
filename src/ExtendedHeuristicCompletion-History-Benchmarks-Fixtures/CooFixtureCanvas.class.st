"
Tiny deterministic subject used by the benchmark integration tests.

The methods below contain known callsites:
- renderWidget sends #drawBox
- refreshAll sends #renderWidget and #paintUsing
- paintUsing references the class CooFixturePalette (a variable completion)

CooFixtureHistory replays a matching history so the extractor discovers
exactly these queries, without any Git or network access.
"
Class {
	#name : 'CooFixtureCanvas',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Fixtures',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks-Fixtures'
}

{ #category : 'fixture' }
CooFixtureCanvas >> drawBox [

	^ 256
]

{ #category : 'fixture' }
CooFixtureCanvas >> paintUsing [

	^ CooFixturePalette new
]

{ #category : 'fixture' }
CooFixtureCanvas >> refreshAll [

	self renderWidget.
	^ self paintUsing
]

{ #category : 'fixture' }
CooFixtureCanvas >> renderWidget [

	^ self drawBox
]
