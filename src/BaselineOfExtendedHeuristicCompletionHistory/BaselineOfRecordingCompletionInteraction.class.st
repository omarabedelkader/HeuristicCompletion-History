Class {
	#name : 'BaselineOfRecordingCompletionInteraction',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'private' }
BaselineOfRecordingCompletionInteraction class >> showHistoryPrivacySetupIfNeeded [

	[
		(Delay forMilliseconds: 500) wait.
		CooCompletionSharingPreferencesPresenter open 
	] fork
]

{ #category : 'baselines' }
BaselineOfRecordingCompletionInteraction >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec postLoadDoIt: #postLoad.
		spec
			baseline: 'PharoXPEventRecorder'
			with: [
				spec repository: 'github://omarabedelkader/pharo-data-collector:main' ].
		spec
			package: 'ExtendedHeuristicCompletion-History';
			package: 'ExtendedHeuristicCompletion-History-Tests'
			with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].

		spec
			package: 'ExtendedHeuristicCompletion-History-Recorder'
			with: [
				spec requires: #(
					'PharoXPEventRecorder'
					'ExtendedHeuristicCompletion-History'
				) ].
		spec
			package: 'ExtendedHeuristicCompletion-History-Spec'
			with: [ spec requires:	'ExtendedHeuristicCompletion-History-Recorder' ].
	]
]

{ #category : 'baselines' }
BaselineOfRecordingCompletionInteraction >> postLoad [

	self class showHistoryPrivacySetupIfNeeded
]
