Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistoryForBenchmarks',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistoryForBenchmarks >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec postLoadDoIt: #postLoad.

		spec
			baseline: 'ExtendedHeuristicCompletionBenchmarks'
			with: [ spec repository: 'github://omarabedelkader/HeuristicCompletion-Benchmarks:main/src' ].
		spec
			package: 'ExtendedHeuristicCompletion-History';		
			package: 'ExtendedHeuristicCompletion-History-Tests'
			with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].

		spec
			package: 'ExtendedHeuristicCompletion-History-Benchmarks'
			with: [ spec requires: #(
					'ExtendedHeuristicCompletion-History'
					'ExtendedHeuristicCompletionBenchmarks'
				) ].
	]
]
