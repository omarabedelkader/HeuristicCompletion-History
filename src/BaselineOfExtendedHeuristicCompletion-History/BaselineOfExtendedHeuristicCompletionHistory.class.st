Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletion-History',
	#package : 'BaselineOfExtendedHeuristicCompletion-History'
}

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> baseline: spec [
	<baseline>
	
	spec for: #common do: [ 
		spec package: 'HeuristicCompletion-Model-History'.
		]

]
