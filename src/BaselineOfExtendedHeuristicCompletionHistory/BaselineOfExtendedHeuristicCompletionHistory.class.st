Class {
	#name : 'BaselineOfExtendedHeuristicCompletionHistory',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfExtendedHeuristicCompletionHistory',
	#package : 'BaselineOfExtendedHeuristicCompletionHistory'
}

{ #category : 'script' }
BaselineOfExtendedHeuristicCompletionHistory class >> postLoad [


	self class environment at: #CooHistoryEventRecorder2 ifPresent: [ :p|
		"the group sharing has been loaded"
		
		 ]
]

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec postLoadDoIt: #postLoad.
		spec
			package: 'ExtendedHeuristicCompletion-History';
			package: 'ExtendedHeuristicCompletion-History-Tests'
			with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].
	
	
		spec
			baseline: 'ExtendedHeuristicCompletionBenchmarks'
			with: [ spec repository: 'github://omarabedelkader/HeuristicCompletion-Benchmarks:main/src' ].	
		spec
			package: 'ExtendedHeuristicCompletion-History-Benchmarks'
			with: [ spec requires: #(
						'ExtendedHeuristicCompletion-History'
						'ExtendedHeuristicCompletionBenchmarks') ].
		spec
			package: 'ExtendedHeuristicCompletion-History-Benchmarks-Tests'
			with: [ spec requires: 'ExtendedHeuristicCompletion-History-Benchmarks' ].
	
	
	
		"spec postLoadDoIt: #postLoad."
		
		spec
			baseline: 'PharoXPEventRecorder'
			with: [ spec repository: 'github://omarabedelkader/pharo-data-collector:main' ].
		spec	
			package: 'ExtendedHeuristicCompletion-History-Recorder'
			with: [ spec requires: #( 'PharoXPEventRecorder' 'ExtendedHeuristicCompletion-History') ];
			package: 'ExtendedHeuristicCompletion-History-Spec'
			with: [ spec requires:	'ExtendedHeuristicCompletion-History-Recorder' ].
	
	
	
	
		spec
			group: 'Core' 
			with: #( 'ExtendedHeuristicCompletion-History' );
			group: 'Tests'
			with: #('ExtendedHeuristicCompletion-History-Tests' );
			
			group: 'Bench'
			with: #('ExtendedHeuristicCompletion-History-Benchmarks' );
			group: 'BenchTests'
			with: #('ExtendedHeuristicCompletion-History-Benchmarks-Tests' );
			
			group: 'Sharing'
			with: #('ExtendedHeuristicCompletion-History-Recorder' 'ExtendedHeuristicCompletion-History-Spec'); 
			
			group: 'default' 
			with: #( 'Core' 'Tests' );
			group: 'full' 
			with: #( 'default' 'Bench' 'Sharing') ]

]

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> postLoad [


	self class environment at: #CooHistoryEventRecorder2 ifPresent: [ :p|
		"the group sharing has been loaded"
		CooSession current recorder: CooHistoryEventRecorder2 new.
		CooCompletionSharingPreferencesPresenter open.
		]
]
