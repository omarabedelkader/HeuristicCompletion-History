Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'script' }
BaselineOfExtendedHeuristicCompletionHistory class >> postLoad [

	CompletionContext sorterClass: NoSorter
]

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> baseline: spec [

	<baseline>
	spec postLoadDoIt: #postLoad.
	spec for: #common do: [ spec package: 'ExtendedHeuristicCompletion-History' ].
				spec package: 'ExtendedHeuristicCompletion-History-Tests' with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].
]
