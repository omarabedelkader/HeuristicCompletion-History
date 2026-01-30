"
A scope for benchmarks that filters to only methods that were modified in the populated commits.
This scope iterates through the method history items in the session and yields only the compiled methods that:
1. Were recorded as added or modified in the history
2. Still exist in the current system (can be resolved from className >> selector)
Example usage:
```smalltalk
CoBenchmarkModifiedMethods fromSession: CooSession current
"
Class {
	#name : 'CoBenchmarkModifiedMethods',
	#superclass : 'Object',
	#instVars : [
		'session'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'instance creation' }
CoBenchmarkModifiedMethods class >> fromSession: aSession [

	^ self new
		session: aSession;
		yourself
]

{ #category : 'accessing' }
CoBenchmarkModifiedMethods >> methodDescriptions [
	"Return the method descriptions from the session's program entity handler"

	^ session programEntityHandler methodDescriptions ifNil: [ #() ]
]

{ #category : 'accessing' }
CoBenchmarkModifiedMethods >> methodsDo: aBlock [
	"Iterate through methods that were modified in the populated commits.
	Only yields methods that still exist in the current system."

	| seenMethods |
	seenMethods := Set new.

	self methodDescriptions do: [ :methodItem |
		| className selector method |
		className := methodItem nameOfClass.
		selector := methodItem selector.

		"Skip if we already processed this method (avoid duplicates from multiple modifications)"
		(seenMethods includes: className -> selector) ifFalse: [
			seenMethods add: className -> selector.

			"Try to resolve the actual compiled method"
			method := self resolveMethod: selector inClass: className.
			method ifNotNil: [ aBlock value: method ] ] ]
]

{ #category : 'accessing' }
CoBenchmarkModifiedMethods >> name [
	"Return a name for display purposes"

	^ 'Modified Methods (', self methodDescriptions size asString, ' items)'
]

{ #category : 'accessing' }
CoBenchmarkModifiedMethods >> resolveMethod: aSelector inClass: aClassName [
	"Try to resolve a compiled method from class name and selector.
	Returns nil if the class or method no longer exists."

	| theClass |
	aClassName ifNil: [ ^ nil ].
	aSelector ifNil: [ ^ nil ].

	theClass := self class environment
		at: aClassName asSymbol
		ifAbsent: [ ^ nil ].

	^ theClass
		compiledMethodAt: aSelector
		ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CoBenchmarkModifiedMethods >> session [

	^ session ifNil: [ CooSession current ]
]

{ #category : 'accessing' }
CoBenchmarkModifiedMethods >> session: aSession [

	session := aSession
]
