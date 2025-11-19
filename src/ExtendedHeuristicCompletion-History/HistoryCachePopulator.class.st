"
This class builds and updates temporal and frequency caches by scraping Git commits, extracting changed methods, and registering their metadata.
"
Class {
	#name : 'HistoryCachePopulator',
	#superclass : 'Object',
	#instVars : [
		'scrapper',
		'temporalSession',
		'frequencySession'
	],
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'as yet unclassified' }
HistoryCachePopulator class >> populateFromRepo: aURLString [
	"Populate caches from the given repository URL.
	Usage: HistoryCachePopulator populateFromRepo: 'https://github.com/pharo-spec/Spec'"
	
	^ self new
		scrapper: (HistoryScrapper fetchRepo: aURLString);
		populateCaches;
		yourself
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator class >> populateFromRepo: aURLString commits: aNumber [
	"Populate caches from a specific number of commits.
	Usage: HistoryCachePopulator populateFromRepo: 'https://github.com/pharo-spec/Spec' commits: 50"
	
	^ self new
		scrapper: (HistoryScrapper fetchRepo: aURLString commits: aNumber);
		populateCaches;
		yourself
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator class >> spec10 [ 

	<script>
	(self populateFromRepo: 'https://github.com/pharo-spec/Spec' commits: 10) inspect

]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> extractMethodFromDiffNode: aDiffNode [
	"Extract method information from a diff node if it's a method change."
	
	| definition |
	definition := aDiffNode definition.
	(definition isKindOf: IceMethodDefinition) ifFalse: [ ^ nil ].
	
	^ definition selector
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> extractMethodsFromCommit: aCommit [
	"Extract all method selectors and their ASTs from a commit's diff."
	
	| diff methodInfos |
	methodInfos := OrderedCollection new.
	diff := aCommit diffToParent.
	diff ifNil: [ ^ methodInfos ].
	
	diff tree allChildrenDo: [ :node |
		node value isAddition ifTrue: [
			self processAddition: node value into: methodInfos timestamp: aCommit datetime ].
		node value isModification ifTrue: [
			self processModification: node value into: methodInfos timestamp: aCommit datetime ] ].
	
	^ methodInfos
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> frequencySession [
	^ frequencySession
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> frequencySession: anObject [
	frequencySession := anObject
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> initialize [
	super initialize.
	temporalSession := CooSessionTemporalMessages current.
	frequencySession := CooSessionFrequencyMessages current
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> populateCaches [
	"Main method to populate both temporal and frequency caches from Git history."
	
	| commits totalMethods |
	commits := self scrapper fetchLatestCommits.
	totalMethods := 0.
	
	Transcript show: 'Populating caches from ', commits size asString, ' commits...'; cr.
	
	commits withIndexDo: [ :commit :index |
		| methodInfos |
		methodInfos := self extractMethodsFromCommit: commit.
		methodInfos do: [ :info |
			self populateCachesWithMethodInfo: info ].
		totalMethods := totalMethods + methodInfos size.
		
		(index \\ 10 = 0) ifTrue: [
			Transcript show: '  Processed ', index asString, ' commits (', totalMethods asString, ' methods)...'; cr ] ].
	
	Transcript 
		show: 'Done! Populated caches with ', totalMethods asString, ' methods from ', commits size asString, ' commits.'; cr;
		show: '  Temporal cache size: ', self temporalSession size asString; cr;
		show: '  Frequency cache size: ', self frequencySession size asString; cr
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> populateCachesWithMethodInfo: aMethodInfo [
	"Add a method to both temporal and frequency caches."
	
	| selector ast event timestamp |
	selector := aMethodInfo selector.
	ast := aMethodInfo ast.
	event := aMethodInfo event.
	timestamp := aMethodInfo timestamp.
	
	"Populate temporal cache"
	self temporalSession
		registerSelector: selector
		ast: ast
		event: event
		at: timestamp.
	
	"Populate frequency cache"
	self frequencySession
		registerSelector: selector
		ast: ast
		event: event
		at: timestamp
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> processAddition: anAddition into: aCollection timestamp: aTimestamp [
	"Process a method addition and add it to the collection."
	
	| selector ast |
	selector := self extractMethodFromDiffNode: anAddition.
	selector ifNil: [ ^ self ].
	
	ast := self tryParseAST: anAddition leftContents.
	
	aCollection add: (CooODescriptionItem new
		selector:selector;
		ast: ast;
		event: #added;
		timestamp: aTimestamp;
		yourself)
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> processModification: aModification into: aCollection timestamp: aTimestamp [
	"Process a method modification and add it to the collection."
	
	| selector ast |
	selector := self extractMethodFromDiffNode: aModification.
	selector ifNil: [ ^ self ].
	
	ast := self tryParseAST: aModification leftContents.
	
	aCollection add: 
	(CooODescriptionItem new
		selector:selector;
		ast: ast;
		event: #modified;
		timestamp: aTimestamp;
		yourself)

]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> scrapper [
	^ scrapper
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> scrapper: aHistoryScrapper [
	scrapper := aHistoryScrapper
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> temporalSession [
	^ temporalSession
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> temporalSession: anObject [
	temporalSession := anObject
]

{ #category : 'as yet unclassified' }
HistoryCachePopulator >> tryParseAST: sourceCode [
	"Try to parse source code into an AST, return nil on failure."
	
	sourceCode ifNil: [ ^ nil ].
	
	^ [ RBParser parseMethod: sourceCode ]
		on: Error
		do: [ :ex | nil ]
]
