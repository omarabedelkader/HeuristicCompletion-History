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
	(self populateFromRepo: 'https://github.com/Ducasse/Comix2.git' commits: 5) inspect
]

{ #category : 'examples' }
HistoryCachePopulator class >> mockRepo [

	<script>
	(self populateFromRepo: 'https://github.com/omarabedelkader/test-repo-for-history' commits: 4) inspect
]

{ #category : 'examples' }
HistoryCachePopulator class >> populateFromRepo: aURLString [

	^ (self repo: aURLString)
		  populateCaches;
		  yourself
]

{ #category : 'examples' }
HistoryCachePopulator class >> populateFromRepo: aURLString commits: aNumber [

	^ self new
		scrapper: (HistoryScrapper repo: aURLString commits: aNumber);
		populateCaches;
		yourself
]

{ #category : 'examples' }
HistoryCachePopulator class >> repo: aURLString [

	^ self new
		  scrapper: (HistoryScrapper repo: aURLString);
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
	
	(self populateFromRepo:  'https://github.com/pharo-graphics/Toplo.git' commits: 500) inspect 
]

{ #category : 'compute population' }
HistoryCachePopulator >> classNameFromDefinition: aDefinition [

	^ aDefinition className, (aDefinition classIsMeta ifTrue: [ ' class' ] ifFalse: [ '' ])
	
]

{ #category : 'forBenchmarks' }
HistoryCachePopulator >> commitsForHead: aNumber [

	^ self scrapper commitsFromHead: aNumber
	
]

{ #category : 'utils' }
HistoryCachePopulator >> computeDeltaMessageBetween: aNewMethodAst andOld: anOldMethodAst [ 
	"This is a copy of the logic defined in the CooTemporalCache or subclasses.
	For now there is not relationship between the history populator and the cache. 
	We may push the creation of items from the populator to the cache
	but we should be able to indicate that an item is recreated from a git repo or
	 based on the user interaction.
	"
	^ (CooMethodHistoryItem messageCompletionSelectorsFromAST: aNewMethodAst)
		  difference:
		  (CooMethodHistoryItem messageCompletionSelectorsFromAST: anOldMethodAst)
]

{ #category : 'compute population' }
HistoryCachePopulator >> extractClassesFromCommit: aCommit [
	"Extract all method selectors and their ASTs from a commit's diff."

	| diff classInfos |
	classInfos := OrderedCollection new. "for the first commit iceberg was barking."
	aCommit ancestors ifEmpty: [ ^ classInfos ].
	diff := aCommit diffToParent.
	diff ifNil: [ ^ classInfos ].

	diff tree allChildrenDo: [ :node |
			node definition isClassDefinition ifTrue: [
					node value isRemoval ifTrue: [ self processClassRemoval: node value into: classInfos timestamp: aCommit datetime ].
					node value isAddition ifTrue: [ self processClassAddition: node value into: classInfos timestamp: aCommit datetime ].
					node value isModification ifTrue: [ self processClassModification: node value into: classInfos timestamp: aCommit datetime ] ] ].

	^ classInfos 
]

{ #category : 'compute population' }
HistoryCachePopulator >> extractMethodsFromCommit: aCommit [
	"Extract all method selectors and their ASTs from a commit's diff."

	| diff methodInfos |
	methodInfos := OrderedCollection new. "for the first commit iceberg was barking."
	aCommit ancestors ifEmpty: [ ^ methodInfos ].
	diff := aCommit diffToParent.
	diff ifNil: [ ^ methodInfos ].

	diff tree allChildrenDo: [ :node |
			node definition isMethodDefinition ifTrue: [
					node value isRemoval ifTrue: [ self processMethodRemoval: node value into: methodInfos timestamp: aCommit datetime ].
					node value isAddition ifTrue: [ self processMethodAddition: node value into: methodInfos timestamp: aCommit datetime ].
					node value isModification ifTrue: [ self processMethodModification: node value into: methodInfos timestamp: aCommit datetime ] ] ].

	^ methodInfos 
]

{ #category : 'initialization' }
HistoryCachePopulator >> initialize [
	super initialize.
	session := CooSession current.
	
]

{ #category : 'forBenchmarks' }
HistoryCachePopulator >> loadFromOldToNewCommit: commit [
 			| infos |
			Transcript cr; show: 'Loading and importing '; show: commit printString.
			
			commit checkoutWithStrategy: IceCheckoutAlreadyLoadedPackages new.			
			infos := self extractMethodsFromCommit: commit.
			infos do: [ :info | session addMethodItem: info ].
			infos := self extractClassesFromCommit: commit.
			infos do: [ :info | session addClassItem: info ]
]

{ #category : 'main API' }
HistoryCachePopulator >> populateCaches [
	"Main method to populate both temporal and frequency caches from Git history."
	
	| commits totalMethods |
	commits := self scrapper fetchLatestCommits.
	
	"we order older first!"
	commits := commits reversed.
	totalMethods := 0.
	
	Transcript show: 'Populating caches from ', commits size asString, ' commits...'; cr.
	
	commits withIndexDo: [ :commit :index |
		
		| methodInfos |
		methodInfos := self extractMethodsFromCommit: commit.
		methodInfos do: [ :info |
			session addMethodItem: info ].
		totalMethods := totalMethods + methodInfos size.
		]
]

{ #category : 'forBenchmarks' }
HistoryCachePopulator >> populateForBenchmarkCommits: aNumber [

	| commits infos |
	commits := self commitsFromHead: aNumber.
	commits reverseDo: [ :commit |
			Transcript
				cr;
				show: 'Loading commits: ' , commit printString;
				cr.
			commit checkoutAllPackages.
			infos := self extractMethodsFromCommit: commit.
			infos do: [ :info | session addMethodItem: info ].
			infos := self extractClassesFromCommit: commit.
			infos do: [ :info | session addClassItem: info ] ]
]

{ #category : 'compute population' }
HistoryCachePopulator >> processClassAddition: anIceAddition into: aCollection timestamp: aDateAndTime [ 
	| item |
	item := (CooAddedClassHistoryItem new
		nameOfClass: anIceAddition definition name;
		live: false;
		timestamp: aDateAndTime;
		yourself).
	aCollection add: item
	
]

{ #category : 'compute population' }
HistoryCachePopulator >> processClassModification: anIceModification into: aCollection timestamp: aDateAndTime [ 
	
	| item |
	item := (CooModifiedClassHistoryItem new
		nameOfClass: anIceModification definition name;
		live: false;
		timestamp: aDateAndTime;
		yourself).
	aCollection add: item
	
]

{ #category : 'compute population' }
HistoryCachePopulator >> processClassRemoval: anIceRemoval into: aCollection timestamp: aDateAndTime [ 
	| item |
	item := (CooRemovedClassHistoryItem new
		nameOfClass: anIceRemoval definition name;
		live: false;
		timestamp: aDateAndTime;
		yourself).
	aCollection add: item
	
]

{ #category : 'compute population' }
HistoryCachePopulator >> processMethodAddition: anAddition into: aCollection timestamp: aTimestamp [
	"Process a method addition and add it to the collection."

	| selector ast item deltaMessage |
	selector := self selectorFromNode: anAddition.
	selector ifNil: [ ^ self ].

	ast := self tryParseAST: anAddition leftContents.
	deltaMessage := CooMethodHistoryItem messageCompletionSelectorsFromAST: ast.


	item := CooAddedMethodHistoryItem new
		        selector: selector;
		        nameOfClass: (self classNameFromDefinition: anAddition definition);
		        ast: ast;
		        live: false;
		        timestamp: aTimestamp;
		        yourself.
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
	aCollection add: item
]

{ #category : 'compute population' }
HistoryCachePopulator >> processMethodModification: aModification into: aCollection timestamp: aTimestamp [
	"Process a method modification and add it to the collection."

	| selector newAst oldAst deltaMessages item |
	selector := self selectorFromNode: aModification.
	selector ifNil: [ ^ self ].

	newAst := self tryParseAST: aModification leftContents.
	oldAst := self tryParseAST: aModification rightContents.

	newAst isNotNil & oldAst isNotNil
		ifTrue: [ deltaMessages := self computeDeltaMessageBetween: newAst andOld: oldAst ]
		ifFalse: [ deltaMessages := #(  ) ].

	item := CooModifiedMethodHistoryItem new
		        selector: selector;
		        nameOfClass: (self classNameFromDefinition: aModification definition);
		        ast: newAst;
		        live: false;
		        timestamp: aTimestamp;
		        yourself.
	item deltaMessages: deltaMessages.
	aCollection add: item
]

{ #category : 'compute population' }
HistoryCachePopulator >> processMethodRemoval: aRemoval into: aCollection timestamp: aTimestamp [
	"Process a method addition and add it to the collection."

	| selector ast item deltaMessage |
	selector := self selectorFromNode: aRemoval.
	selector ifNil: [ ^ self ].

	ast := self tryParseAST: aRemoval rightContents.
	deltaMessage := CooMethodHistoryItem messageCompletionSelectorsFromAST: ast.


	item := CooRemovedMethodHistoryItem new
		        selector: selector;
		        nameOfClass: (self classNameFromDefinition: aRemoval definition);
		        ast: ast;
		        live: false;
		        timestamp: aTimestamp;
		        yourself.
	deltaMessage ifNotEmpty: [ item deltaMessages: deltaMessage ].
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

{ #category : 'accessing' }
HistoryCachePopulator >> session [

	^ session
]

{ #category : 'utils' }
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

{ #category : 'utils' }
HistoryCachePopulator >> tryParseAST: sourceCode [
	"Try to parse source code into an AST, return nil on failure."
	
	sourceCode ifNil: [ ^ nil ].
	
	^ [ RBParser parseMethod: sourceCode ]
		on: Error
		do: [ :ex | nil ]
]
