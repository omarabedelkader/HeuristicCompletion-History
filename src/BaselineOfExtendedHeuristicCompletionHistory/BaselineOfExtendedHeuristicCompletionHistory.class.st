Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'private' }
BaselineOfExtendedHeuristicCompletionHistory class >> showHistoryPrivacySetupIfNeeded [

	[
		(Delay forMilliseconds: 500) wait.

		World ifNotNil: [
			CooHistorySettings firstLaunchCompleted ifFalse: [
				WorldMorph doOneCycle.
				CooHistorySettings openFirstLaunchSetup ] ]
	] fork
]

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec
			package: 'ExtendedHeuristicCompletion-History'.
		spec
			package: 'ExtendedHeuristicCompletion-History-Tests'
			with: [
				spec requires:
					'ExtendedHeuristicCompletion-History' ].
	
		spec
			group: 'Core' 
			with: #( 'ExtendedHeuristicCompletion-History' );
			group: 'Tests'
			with: #('ExtendedHeuristicCompletion-History-Tests' ); 
			group: 'default' 
			with: #( 'Core' 'Tests' );
			group: 'full' 
			with: #( 'default' ) ]

]
