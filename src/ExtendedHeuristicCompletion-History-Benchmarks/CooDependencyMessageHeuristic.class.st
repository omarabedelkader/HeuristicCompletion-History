"
I am CoDependencyMessageHeuristics with a fetcher that tolerates packages whose dependencies
cannot be computed (see CooDependencySelectorFetcher).
"
Class {
	#name : 'CooDependencyMessageHeuristic',
	#superclass : 'CoDependencyMessageHeuristics',
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'requests' }
CooDependencyMessageHeuristic >> buildFetcherFor: aNode inContext: completionContext [

	^ CooDependencySelectorFetcher new
		  completionClass: completionContext completionClass;
		  astNode: aNode;
		  yourself
]
