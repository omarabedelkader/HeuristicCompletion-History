Class {
	#name : 'CooHistorySettingsTest',
	#superclass : 'TestCase',
	#instVars : [
		'originalFirstLaunchCompleted',
		'originalPrivacyConsentAccepted',
		'originalHistoryRecordingEnabled',
		'originalRemoteDeliveryEnabled',
		'originalHistoryRecordingConsentState'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests-Core',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
CooHistorySettingsTest >> resetConsentState [

	CooHistorySettings instVarNamed: #firstLaunchCompleted put: nil.
	CooHistorySettings instVarNamed: #privacyConsentAccepted put: nil.
	CooHistorySettings instVarNamed: #historyRecordingEnabled put: nil.
	CooHistorySettings instVarNamed: #remoteDeliveryEnabled put: nil.
	CooHistorySettings instVarNamed: #historyRecordingConsentState put: nil
]

{ #category : 'running' }
CooHistorySettingsTest >> setUp [

	super setUp.

	originalFirstLaunchCompleted := CooHistorySettings instVarNamed: #firstLaunchCompleted.
	originalPrivacyConsentAccepted := CooHistorySettings instVarNamed: #privacyConsentAccepted.
	originalHistoryRecordingEnabled := CooHistorySettings instVarNamed: #historyRecordingEnabled.
	originalRemoteDeliveryEnabled := CooHistorySettings instVarNamed: #remoteDeliveryEnabled.
	originalHistoryRecordingConsentState := CooHistorySettings instVarNamed: #historyRecordingConsentState.

	self resetConsentState
]

{ #category : 'running' }
CooHistorySettingsTest >> tearDown [

	CooHistorySettings instVarNamed: #firstLaunchCompleted put: originalFirstLaunchCompleted.
	CooHistorySettings instVarNamed: #privacyConsentAccepted put: originalPrivacyConsentAccepted.
	CooHistorySettings instVarNamed: #historyRecordingEnabled put: originalHistoryRecordingEnabled.
	CooHistorySettings instVarNamed: #remoteDeliveryEnabled put: originalRemoteDeliveryEnabled.
	CooHistorySettings instVarNamed: #historyRecordingConsentState put: originalHistoryRecordingConsentState.

	super tearDown
]

{ #category : 'tests' }
CooHistorySettingsTest >> testAcceptedConsentAllowsEnabledFlags [

	CooHistorySettings recordHistoryRecordingConsentAccepted: true.
	CooHistorySettings instVarNamed: #historyRecordingEnabled put: true.
	CooHistorySettings instVarNamed: #remoteDeliveryEnabled put: true.

	self assert: CooHistorySettings historyRecordingConsentState equals: #accepted.
	self assert: CooHistorySettings firstLaunchCompleted.
	self assert: CooHistorySettings privacyConsentAccepted.
	self assert: CooHistorySettings historyRecordingEnabled.
	self assert: CooHistorySettings remoteDeliveryEnabled
]

{ #category : 'tests' }
CooHistorySettingsTest >> testConsentDefaultsToNotAskedAndTelemetryOff [

	self assert: CooHistorySettings historyRecordingConsentState equals: #notAsked.
	self deny: CooHistorySettings firstLaunchCompleted.
	self deny: CooHistorySettings privacyConsentAccepted.
	self deny: CooHistorySettings historyRecordingEnabled.
	self deny: CooHistorySettings remoteDeliveryEnabled
]

{ #category : 'tests' }
CooHistorySettingsTest >> testDeclinedConsentDisablesEnabledFlags [

	CooHistorySettings instVarNamed: #historyRecordingEnabled put: true.
	CooHistorySettings instVarNamed: #remoteDeliveryEnabled put: true.

	CooHistorySettings recordHistoryRecordingConsentAccepted: false.

	self assert: CooHistorySettings historyRecordingConsentState equals: #declined.
	self assert: CooHistorySettings firstLaunchCompleted.
	self deny: CooHistorySettings privacyConsentAccepted.
	self deny: CooHistorySettings historyRecordingEnabled.
	self deny: CooHistorySettings remoteDeliveryEnabled
]

{ #category : 'tests' }
CooHistorySettingsTest >> testNormalizeConsentChoiceTreatsCloseAsDecline [

	self assert: (CooHistorySettings normalizeConsentChoice: nil) equals: #decline.
	self assert: (CooHistorySettings normalizeConsentChoice: 0) equals: #decline.
	self assert: (CooHistorySettings normalizeConsentChoice: 1) equals: #decline.
	self assert: (CooHistorySettings normalizeConsentChoice: 2) equals: #accept.
	self assert: (CooHistorySettings normalizeConsentChoice: 3) equals: #learnMore
]

{ #category : 'tests' }
CooHistorySettingsTest >> testUnknownConsentStateFailsClosed [

	CooHistorySettings instVarNamed: #historyRecordingEnabled put: true.
	CooHistorySettings instVarNamed: #remoteDeliveryEnabled put: true.
	CooHistorySettings instVarNamed: #historyRecordingConsentState put: #unexpected.

	self assert: CooHistorySettings historyRecordingConsentState equals: #declined.
	self deny: CooHistorySettings privacyConsentAccepted.
	self deny: CooHistorySettings historyRecordingEnabled.
	self deny: CooHistorySettings remoteDeliveryEnabled
]
