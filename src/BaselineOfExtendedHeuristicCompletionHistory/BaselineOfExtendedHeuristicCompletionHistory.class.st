Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: 'ExtendedHeuristicCompletion-History' ].
				spec package: 'ExtendedHeuristicCompletion-History-Tests' with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].
]
