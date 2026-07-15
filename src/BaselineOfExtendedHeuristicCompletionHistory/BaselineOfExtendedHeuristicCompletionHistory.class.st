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
		spec postLoadDoIt: #postLoad.

		spec
			baseline: 'ExtendedHeuristicCompletionBenchmarks'
			with: [
				spec repository:
					'github://omarabedelkader/HeuristicCompletion-Benchmarks:main/src' ].

		spec
			baseline: 'DSSpyEventRecorder'
			with: [
				spec repository:
					'github://omarabedelkader/DebuggingSpy-EventRecorder:omar' ].

		spec
			baseline: 'ExperimentModel'
			with: [
				spec repository:
					'github://omarabedelkader/ExperimentModel:omar' ].

		spec
			package: 'ExtendedHeuristicCompletion-History'.

		spec
			package: 'ExtendedHeuristicCompletion-History-Recorder'
			with: [
				spec requires: #(
					'ExtendedHeuristicCompletion-History'
					'DSSpyEventRecorder'
					'ExperimentModel'
				) ].

		spec
			package: 'ExtendedHeuristicCompletion-History-Tests'
			with: [
				spec requires:
					'ExtendedHeuristicCompletion-History' ].

		spec
			package: 'ExtendedHeuristicCompletion-History-Benchmarks'
			with: [
				spec requires: #(
					'ExtendedHeuristicCompletion-History'
					'ExtendedHeuristicCompletionBenchmarks'
				) ].

		spec
			package: 'ExtendedHeuristicCompletion-History-Recorder-Tests'
			with: [
				spec requires:
					'ExtendedHeuristicCompletion-History-Recorder' ]
	]
]

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> postLoad [

	self class showHistoryPrivacySetupIfNeeded
]
