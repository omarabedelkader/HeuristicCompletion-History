"
I am CoDependencySelectorFetcher, except that a package whose dependencies cannot be computed
gets no dependency candidates instead of stopping the benchmark.

While a history is replayed, the package dependency analysis can fail on a package that is
not in the image (any more), e.g. #daPackageFor: answering nothing.
"
Class {
	#name : 'CooDependencySelectorFetcher',
	#superclass : 'CoDependencySelectorFetcher',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'accessing' }
CooDependencySelectorFetcher >> dependenciesOf: aPackageName [

	^ [ super dependenciesOf: aPackageName ]
		  on: Error
		  do: [ #(  ) ]
]
