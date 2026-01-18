Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec
				baseline: 'ExtendedHeuristicCompletionBenchmarks'
				with: [ spec repository: 'github://omarabedelkader/HeuristicCompletion-Benchmarks/repository' ].

			spec package: 'ExtendedHeuristicCompletion-History' ].
	spec 
		package: 'ExtendedHeuristicCompletion-History-Tests' 
		with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].
	spec 
		package: 'ExtendedHeuristicCompletion-History-Benchmarks' 
		with: [ spec requires: 'ExtendedHeuristicCompletion-History' ]
]

{ #category : 'script' }
BaselineOfExtendedHeuristicCompletionHistory >> postLoad [

	CompletionContext sorterClass: NoSorter
]
