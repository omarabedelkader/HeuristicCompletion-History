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
         	with: [ spec repository: 'github://omarabedelkader/HeuristicCompletion-Benchmarks:main/src' ].
		
		spec 
         package: 'ExtendedHeuristicCompletion-History-Recorder'
         with: [ spec requires: #('DSSpyEventRecorder' 'ExperimentModel') ].
	
     	spec 
        	package: 'ExtendedHeuristicCompletion-History' 
        	with: [ spec requires: 'ExtendedHeuristicCompletion-History-Recorder' ].
     	spec 
        	package: 'ExtendedHeuristicCompletion-History-Tests' 
        	with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].
     	spec 
       	package: 'ExtendedHeuristicCompletion-History-Benchmarks' 
        	with: [ spec requires: 'ExtendedHeuristicCompletion-History' ].
     	spec 
       	package: 'ExtendedHeuristicCompletion-History-Recorder-Tests' 
        	with: [ spec requires: 'ExtendedHeuristicCompletion-History-Recorder' ].
 	].
]

{ #category : 'baselines' }
BaselineOfExtendedHeuristicCompletionHistory >> postLoad [

	self class showHistoryPrivacySetupIfNeeded
]
