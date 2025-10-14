"
I am the interface with the System's CompletionEngine, following the API of CompletionContext (entries, entryCount, activateEntryAt:, etc).
I delegate the calculation of the entries completely to a complishon object which is lazily built by a complishon builder.
The complishonBuilder instance can be specialized or replaced to change the search heuristics.
"
Class {
	#name : 'CooCompletionContext',
	#superclass : 'Object',
	#instVars : [
		'engine',
		'source',
		'position',
		'completionTokenStart',
		'completionBuilder',
		'completionClass',
		'completion',
		'completionToken'
	],
	#category : 'HeuristicCompletion-Model-History-History-Fetcher',
	#package : 'HeuristicCompletion-Model-History',
	#tag : 'History-Fetcher'
}

{ #category : 'class initialization' }
CooCompletionContext class >> engine: aCompletionEngine class: aClass source: aString position: anInteger [

	^ self new
		completionClass: aClass;
		engine: aCompletionEngine;
		source: aString;
		position: anInteger;
		yourself
]

{ #category : 'activation' }
CooCompletionContext >> activateEntryAt: anIndex [

	| entry |
	self halt.
	entry := self entries at: anIndex.
	'.' traceCr.
	[ entry activateOn: self ] ensure: [ "Record selection into the session history."
		CooTemporalHistorySession current completionSelected: entry in: self ].
	^ entry
]

{ #category : 'testing' }
CooCompletionContext >> completion [

	completion ifNotNil: [ ^ completion ].
	completion := self completionBuilder
		completionContext: self;
		buildCompletion.
	completion filter: (CoBeginsWithFilter caseSensitive: NECPreferences caseSensitive filterString: self completionToken).
	^ completion
]

{ #category : 'accessing' }
CooCompletionContext >> completion: anObject [
	completion := anObject
]

{ #category : 'accessing' }
CooCompletionContext >> completionAt: aNumber [
	| entry |

	entry := (self entries at: aNumber) contents asSymbol separateKeywords.
	^ NECEntry spaceAfterCompletion
		ifTrue: [ entry, ' ' ]
		ifFalse: [ entry ]
]

{ #category : 'accessing' }
CooCompletionContext >> completionBuilder [
	^ completionBuilder
]

{ #category : 'accessing' }
CooCompletionContext >> completionBuilder: anUndefinedObject [
	completionBuilder := anUndefinedObject
]

{ #category : 'accessing' }
CooCompletionContext >> completionClass [

	^ completionClass
]

{ #category : 'accessing' }
CooCompletionContext >> completionClass: aClass [

	^ completionClass := aClass
]

{ #category : 'accessing' }
CooCompletionContext >> completionToken [

	^ completionToken
]

{ #category : 'accessing' }
CooCompletionContext >> completionTokenStart [

	^ completionTokenStart
]

{ #category : 'accessing' }
CooCompletionContext >> doItContext [

	^ engine doItContext
]

{ #category : 'accessing' }
CooCompletionContext >> doItRequestor [

	^ engine doItRequestor
]

{ #category : 'accessing' }
CooCompletionContext >> engine [
	^ engine
]

{ #category : 'accessing' }
CooCompletionContext >> engine: anObject [
	engine := anObject.
	completionTokenStart := anObject completionTokenStart.
	completionToken := anObject completionToken
]

{ #category : 'accessing' }
CooCompletionContext >> entries [

	^ self completion first: 20
]

{ #category : 'accessing' }
CooCompletionContext >> entryCount [
	^ self entries size
]

{ #category : 'accessing' }
CooCompletionContext >> environmentAt: aString ifPresent: aBlockClosure [

	^ self systemNavigation environmentAt: aString ifPresent: aBlockClosure
]

{ #category : 'testing' }
CooCompletionContext >> hasEntries [

	^ self completion notEmpty
]

{ #category : 'menu' }
CooCompletionContext >> hasMessage [

	^ false
]

{ #category : 'initialization' }
CooCompletionContext >> initialize [

	super initialize.
	completionBuilder := CoASTHeuristicsResultSetBuilder initializeOnContext: self
]

{ #category : 'testing' }
CooCompletionContext >> isScripting [

	^ engine isNotNil and: [ engine isScripting ]
]

{ #category : 'narrowing' }
CooCompletionContext >> narrowWith: aString [

	completionToken := aString.
	self completion replaceFilterWith: (CoBeginsWithFilter caseSensitive: NECPreferences caseSensitive filterString: aString)
]

{ #category : 'accessing' }
CooCompletionContext >> position [
	^ position
]

{ #category : 'accessing' }
CooCompletionContext >> position: anObject [
	position := anObject
]

{ #category : 'replacing' }
CooCompletionContext >> replaceTokenInEditorWith: aString [

	engine replaceTokenInEditorWith: aString
]

{ #category : 'accessing' }
CooCompletionContext >> source [
	^ source
]

{ #category : 'accessing' }
CooCompletionContext >> source: anObject [
	source := anObject
]

{ #category : 'accessing' }
CooCompletionContext >> systemNavigation [

	^ CoSystemEnvironment new
]

{ #category : 'accessing' }
CooCompletionContext >> title [

	^ ''
]

{ #category : 'accessing' }
CooCompletionContext >> variableBindingNames [

	^ self engine variableBindingNames
]
