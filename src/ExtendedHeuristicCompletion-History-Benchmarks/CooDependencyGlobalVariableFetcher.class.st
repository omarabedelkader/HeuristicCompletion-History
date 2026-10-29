"
I am CoDependencyGlobalVariableFetcher, except that I skip the dependencies that are not loaded.

While a history is replayed, a package can declare a dependency on a package that is not in
the image (yet, or any more): the original sends #definedClasses to nil and stops the benchmark.
"
Class {
	#name : 'CooDependencyGlobalVariableFetcher',
	#superclass : 'CoDependencyGlobalVariableFetcher',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'enumerating' }
CooDependencyGlobalVariableFetcher >> entriesDo: aBlock [

	| dependentClassNames |
	completionClass ifNil: [ ^ self ].

	self packageLocalClasses: aBlock.

	dependentClassNames := SortedCollection sortUsing: [ :a :b | a <= b ].
	(self dependenciesOf: package name) do: [ :packageName |
		(organizer packageNamed: packageName ifAbsent: [ nil ]) ifNotNil: [ :dependency |
			dependentClassNames addAll: (dependency definedClasses collect: [ :each | each name ]) ] ].
	dependentClassNames do: [ :depClassName |
		aBlock value: ((CoGlobalEntry contents: depClassName node: nil)
				 fetcherName: self class name;
				 yourself) ]
]
