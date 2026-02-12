"
This class builds and updates temporal and frequency caches by scraping Git commits, extracting changed methods, and registering their metadata.
"
Class {
	#name : 'HistoryCachePopulator',
	#superclass : 'Object',
	#instVars : [
		'scrapper',
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'examples' }
HistoryCachePopulator class >> comix [

	<script>
	(self populateFromRepo: 'git@github.com:Ducasse/Comix2.git' commits: 5) inspect
]

{ #category : 'examples' }
HistoryCachePopulator class >> mockRepo [

	<script>
	(self populateFromRepo: 'https://github.com/omarabedelkader/test-repo-for-history' commits: 4) inspect
]

{ #category : 'examples' }
HistoryCachePopulator class >> populateFromRepo: aURLString [

	^ self new
		scrapper: (HistoryScrapper fetchRepo: aURLString);
		populateCaches;
		yourself
]

{ #category : 'examples' }
HistoryCachePopulator class >> populateFromRepo: aURLString commits: aNumber [

	^ self new
		scrapper: (HistoryScrapper fetchRepo: aURLString commits: aNumber);
		populateCaches;
		yourself
]

{ #category : 'examples' }
HistoryCachePopulator class >> spec10 [ 

	<script>
	(self populateFromRepo: 'https://github.com/pharo-spec/Spec' commits: 10) inspect

]

{ #category : 'examples' }
HistoryCachePopulator class >> toplo [
	<script>
	
	(self populateFromRepo:  'git@github.com:pharo-graphics/Toplo.git' commits: 500) inspect 
]

{ #category : 'compute population' }
HistoryCachePopulator >> computeDeltaMessageBetween: aNewMethodAst andOld: anOldMethodAst [ 
	"This is a copy of the logic defined in the CooTemporalCache or subclasses.
	For now there is not relationship between the history populator and the cache. 
	We may push the creation of items from the populator to the cache
	but we should be able to indicate that an item is recreated from a git repo or
	 based on the user interaction.
	"
	^ ((aNewMethodAst allChildren select: [ :each | each isMessage ])
			collect: [ :each | each selector ])
		  difference:
		  ((anOldMethodAst allChildren select: [ :each | each isMessage ]) 
				collect: [ :each | each selector ])
]

{ #category : 'compute population' }
HistoryCachePopulator >> extractMethodsFromCommit: aCommit [
	"Extract all method selectors and their ASTs from a commit's diff."
	
	| diff methodInfos |
	methodInfos := OrderedCollection new.
	"for the first commit iceberg was barking."
	aCommit ancestors ifEmpty: [ ^ methodInfos  ].
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
HistoryCachePopulator >> initialize [
	super initialize.
	session := CooSession current.
	
]

{ #category : 'main API' }
HistoryCachePopulator >> populateCaches [
	"Main method to populate both temporal and frequency caches from Git history."
	
	| commits totalMethods |
	commits := self scrapper fetchLatestCommits.
	
	"we order older first"
	commits := commits reversed.
	totalMethods := 0.
	
	Transcript show: 'Populating caches from ', commits size asString, ' commits...'; cr.
	
	commits withIndexDo: [ :commit :index |
		| methodInfos |
		methodInfos := self extractMethodsFromCommit: commit.
		methodInfos do: [ :info |
			"for now we do not manage variable"
			session addMethodItem: info ].
		totalMethods := totalMethods + methodInfos size.
		
		(index \\ 10 = 0) ifTrue: [
			Transcript show: '  Processed ', index asString, ' commits (', totalMethods asString, ' methods)...'; cr ] ].
	
	Transcript 
		show: 'Done! Populated caches with ', totalMethods asString, ' methods from ', commits size asString, ' commits.'; cr;
		show: '  Cache size: ', session size asString; cr
]

{ #category : 'compute population' }
HistoryCachePopulator >> populateCachesWithMethodInfo: aMethodInfo [
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
HistoryCachePopulator >> processAddition: anAddition into: aCollection timestamp: aTimestamp [
	"Process a method addition and add it to the collection."

	| selector ast item deltaMessage |
	selector := self selectorFromNode: anAddition.
	selector ifNil: [ ^ self ].

	ast := self tryParseAST: anAddition leftContents.
	deltaMessage := ast allChildren 
		select: [ :each | each isMessage ] thenCollect: [ :each | each selector ].
	
	
	item := (CooAddedMethodHistoryItem new
		selector: selector;
		nameOfClass: anAddition definition className;
		ast: ast;
		live: false;
		timestamp: aTimestamp;
		yourself).
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	aCollection add: item
	
]

{ #category : 'compute population' }
HistoryCachePopulator >> processModification: aModification into: aCollection timestamp: aTimestamp [
	"Process a method modification and add it to the collection."

	| selector newAst oldAst deltaMessages item | 
	selector := self selectorFromNode: aModification.
	selector ifNil: [ ^ self ].

	newAst := self tryParseAST: aModification leftContents.
	oldAst := self tryParseAST: aModification rightContents.
	
	( newAst isNotNil & oldAst isNotNil )
		ifTrue: [ deltaMessages := self computeDeltaMessageBetween: newAst andOld: oldAst ]
		ifFalse: [  deltaMessages :=  #() ].
	
	item := (CooModifiedMethodHistoryItem new
		selector: selector;
		nameOfClass: aModification definition className;
		ast: newAst;
		live: false;
		timestamp: aTimestamp;
		yourself).
	item deltaMessages: deltaMessages.
	aCollection add: item
]

{ #category : 'accessing' }
HistoryCachePopulator >> scrapper [
	^ scrapper
]

{ #category : 'accessing' }
HistoryCachePopulator >> scrapper: aHistoryScrapper [
	scrapper := aHistoryScrapper
]

{ #category : 'compute population' }
HistoryCachePopulator >> selectorFromNode: aDiffNode [
	"Extract method information from a diff node if it's a method change."
	
	| definition |
	definition := aDiffNode definition.
	(definition isKindOf: IceMethodDefinition) ifFalse: [ ^ nil ].
	
	"We will have probably to handle class definition in a second time"
	
	^ definition selector
]

{ #category : 'accessing' }
HistoryCachePopulator >> session: aHistoryMockSession [ 
	session := aHistoryMockSession
]

{ #category : 'compute population' }
HistoryCachePopulator >> tryParseAST: sourceCode [
	"Try to parse source code into an AST, return nil on failure."
	
	sourceCode ifNil: [ ^ nil ].
	
	^ [ RBParser parseMethod: sourceCode ]
		on: Error
		do: [ :ex | nil ]
]
