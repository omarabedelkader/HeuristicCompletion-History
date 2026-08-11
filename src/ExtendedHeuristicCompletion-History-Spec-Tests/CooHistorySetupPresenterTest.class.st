Class {
	#name : 'CooHistorySetupPresenterTest',
	#superclass : 'TestCase',
	#category : 'ExtendedHeuristicCompletion-History-Spec-Tests-Core',
	#package : 'ExtendedHeuristicCompletion-History-Spec-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
CooHistorySetupPresenterTest >> testSetupButtonLayoutsDoNotUseFixedWidths [

	#(
		showConsentChoiceStep
		showLearnMoreStepReturningTo:includeConsentButtons:
		showWelcomeStepAfterConsentDecision
	) do: [ :selector |
		self deny:
			((CooHistorySetupPresenter sourceCodeAt: selector)
				includesSubstring: 'width:') ]
]

{ #category : 'tests' }
CooHistorySetupPresenterTest >> testShowWelcomeStepDoesNotRecordConsentWhenNotAsked [

	| originalFirstLaunchCompleted originalPrivacyConsentAccepted originalHistoryRecordingConsentState |
	originalFirstLaunchCompleted := CooHistorySettings instVarNamed: #firstLaunchCompleted.
	originalPrivacyConsentAccepted := CooHistorySettings instVarNamed: #privacyConsentAccepted.
	originalHistoryRecordingConsentState := CooHistorySettings instVarNamed: #historyRecordingConsentState.

	CooHistorySettings instVarNamed: #firstLaunchCompleted put: nil.
	CooHistorySettings instVarNamed: #privacyConsentAccepted put: nil.
	CooHistorySettings instVarNamed: #historyRecordingConsentState put: nil.

	[
		| presenter |
		presenter := CooHistorySetupPresenter new.
		presenter showWelcomeStep.

		self assert: CooHistorySettings historyRecordingConsentState equals: #notAsked.
		self deny: CooHistorySettings historyRecordingConsentAccepted.
		self deny: CooHistorySettings historyRecordingConsentDeclined ]
	ensure: [
		CooHistorySettings instVarNamed: #firstLaunchCompleted put: originalFirstLaunchCompleted.
		CooHistorySettings instVarNamed: #privacyConsentAccepted put: originalPrivacyConsentAccepted.
		CooHistorySettings instVarNamed: #historyRecordingConsentState put: originalHistoryRecordingConsentState ]
]
