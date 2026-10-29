"
I am the history a completion strategy may use while a commit is benchmarked: the session entries
as they were before the commit was loaded.

The session receives the events of a commit while it is checked out, so querying it directly would
let the strategies see the very changes whose call sites are predicted. The runner refreshes me from
the session before each checkout and the history heuristics read me instead of the session.
I answer the protocol the session fetchers use (#selectorEntries and #classEntries).
"
Class {
	#name : 'CooHistorySnapshot',
	#superclass : 'Object',
	#instVars : [
		'selectorEntries',
		'classEntries',
		'selectors',
		'classNames'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'accessing' }
CooHistorySnapshot >> classEntries [

	^ classEntries
]

{ #category : 'accessing' }
CooHistorySnapshot >> classNames [
	"The distinct class names of the history, to tell whether a call site target is in it."

	^ classNames
]

{ #category : 'testing' }
CooHistorySnapshot >> includesClassName: aSymbol [

	^ classNames includes: aSymbol
]

{ #category : 'testing' }
CooHistorySnapshot >> includesSelector: aSymbol [

	^ selectors includes: aSymbol
]

{ #category : 'initialization' }
CooHistorySnapshot >> initialize [

	super initialize.
	selectorEntries := #(  ).
	classEntries := #(  ).
	selectors := Set new.
	classNames := Set new
]

{ #category : 'accessing' }
CooHistorySnapshot >> selectorEntries [

	^ selectorEntries
]

{ #category : 'accessing' }
CooHistorySnapshot >> selectors [
	"The distinct selectors of the history, to tell whether a call site target is in it."

	^ selectors
]

{ #category : 'updating' }
CooHistorySnapshot >> updateFrom: aSession [

	selectorEntries := aSession selectorEntries asArray.
	classEntries := aSession classEntries asArray.
	selectors := (selectorEntries collect: [ :each | each contents asSymbol ]) asSet.
	classNames := (classEntries collect: [ :each | each contents asSymbol ]) asSet
]
