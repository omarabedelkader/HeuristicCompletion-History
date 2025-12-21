"
This class builds and updates temporal and frequency caches by scraping Git commits, extracting changed methods, and registering their metadata.
"
Class {
	#name : 'NewHistoryCachePopulator',
	#superclass : 'Object',
	#instVars : [
		'scrapper',
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'instance creation' }
NewHistoryCachePopulator class >> populateFromRepo: aURLString [
	"Populate caches from the given repository URL.
	Usage: HistoryCachePopulator populateFromRepo: 'https://github.com/pharo-spec/Spec'"
	
	^ self new
		scrapper: (HistoryScrapper fetchRepo: aURLString);
		populateCaches;
		yourself
]

{ #category : 'instance creation' }
NewHistoryCachePopulator class >> populateFromRepo: aURLString commits: aNumber [
	"Populate caches from a specific number of commits.
	Usage: HistoryCachePopulator populateFromRepo: 'https://github.com/pharo-spec/Spec' commits: 50"
	
	^ self new
		scrapper: (HistoryScrapper fetchRepo: aURLString commits: aNumber);
		populateCaches;
		yourself
]

{ #category : 'examples' }
NewHistoryCachePopulator class >> spec10 [ 

	<script>
	(self populateFromRepo: 'https://github.com/pharo-spec/Spec' commits: 10) inspect

]

{ #category : 'examples' }
NewHistoryCachePopulator class >> toplo [
	<script>
		(self populateFromRepo:  'git@github.com:pharo-graphics/Toplo.git') inspect 
]

{ #category : 'compute population' }
NewHistoryCachePopulator >> extractMethodFromDiffNode: aDiffNode [
	"Extract method information from a diff node if it's a method change."
	
	| definition |
	definition := aDiffNode definition.
	(definition isKindOf: IceMethodDefinition) ifFalse: [ ^ nil ].
	
	"We will have probably to handle class definition in a second time"
	
	^ definition selector
]

{ #category : 'compute population' }
NewHistoryCachePopulator >> extractMethodsFromCommit: aCommit [
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

{ #category : 'initialization' }
NewHistoryCachePopulator >> initialize [
	super initialize.
	session := CooSession current.
	
]

{ #category : 'main API' }
NewHistoryCachePopulator >> populateCaches [
	"Main method to populate both temporal and frequency caches from Git history."
	
	| commits totalMethods |
	commits := self scrapper fetchLatestCommits.
	totalMethods := 0.
	
	Transcript show: 'Populating caches from ', commits size asString, ' commits...'; cr.
	
	commits withIndexDo: [ :commit :index |
		| methodInfos |
		methodInfos := self extractMethodsFromCommit: commit.
		methodInfos do: [ :info |
			"for now we do not manage variable"
			session cache addMethodItem: info ].
		totalMethods := totalMethods + methodInfos size.
		
		(index \\ 10 = 0) ifTrue: [
			Transcript show: '  Processed ', index asString, ' commits (', totalMethods asString, ' methods)...'; cr ] ].
	
	Transcript 
		show: 'Done! Populated caches with ', totalMethods asString, ' methods from ', commits size asString, ' commits.'; cr;
		show: '  Temporal cache size: ', self temporalSession size asString; cr;
		show: '  Frequency cache size: ', self frequencySession size asString; cr
]

{ #category : 'compute population' }
NewHistoryCachePopulator >> populateCachesWithMethodInfo: aMethodInfo [
	"Add a method to both temporal and frequency caches."

	| selector ast event timestamp |
	selector := aMethodInfo selector.
	ast := aMethodInfo ast.	
	timestamp := aMethodInfo timestamp.

	session
		registerSelector: selector
		ast: ast
		event: event
		at: timestamp
]

{ #category : 'compute population' }
NewHistoryCachePopulator >> processAddition: anAddition into: aCollection timestamp: aTimestamp [
	"Process a method addition and add it to the collection."

	| selector ast |
	selector := self extractMethodFromDiffNode: anAddition.
	selector ifNil: [ ^ self ].

	ast := self tryParseAST: anAddition leftContents.

	aCollection add: (CooAddedMethodHistoryItem new
		selector: selector;
		ast: ast;
		live: false;
		timestamp: aTimestamp;
		yourself)
]

{ #category : 'compute population' }
NewHistoryCachePopulator >> processModification: aModification into: aCollection timestamp: aTimestamp [
	"Process a method modification and add it to the collection."

	| selector ast |
	selector := self extractMethodFromDiffNode: aModification.
	selector ifNil: [ ^ self ].

	ast := self tryParseAST: aModification leftContents.

	aCollection add: (CooModifiedMethodHistoryItem new
			 selector: selector;
			 ast: ast;
			 live: false;
			 timestamp: aTimestamp;
			 yourself)
]

{ #category : 'accessing' }
NewHistoryCachePopulator >> scrapper [
	^ scrapper
]

{ #category : 'accessing' }
NewHistoryCachePopulator >> scrapper: aHistoryScrapper [
	scrapper := aHistoryScrapper
]

{ #category : 'accessing' }
NewHistoryCachePopulator >> session: aHistoryMockSession [ 
	session := aHistoryMockSession
]

{ #category : 'compute population' }
NewHistoryCachePopulator >> tryParseAST: sourceCode [
	"Try to parse source code into an AST, return nil on failure."
	
	sourceCode ifNil: [ ^ nil ].
	
	^ [ RBParser parseMethod: sourceCode ]
		on: Error
		do: [ :ex | nil ]
]
