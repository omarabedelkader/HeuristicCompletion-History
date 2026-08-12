"
I'm the settings of the history
"
Class {
	#name : 'CooHistorySettings',
	#superclass : 'Object',
	#classInstVars : [
		'firstLaunchCompleted',
		'privacyConsentAccepted',
		'historyRecordingEnabled',
		'remoteDeliveryEnabled',
		'historyRecordingConsentState'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'accessing' }
CooHistorySettings class >> firstLaunchCompleted [

	^ self historyRecordingConsentState ~= #notAsked
]

{ #category : 'accessing' }
CooHistorySettings class >> firstLaunchCompleted: aBoolean [

	firstLaunchCompleted := aBoolean.
	aBoolean ifFalse: [
		historyRecordingConsentState := #notAsked.
		privacyConsentAccepted := false ]
]

{ #category : 'actions' }
CooHistorySettings class >> confirmRemoteDeliveryDisable [

	| choice |
	[
	choice := UIManager default
		          chooseFrom: #('Cancel' 'Disable history telemetry')
		          title: self historyRecordingDisablePrompt ]
		on: Error
		do: [ :ex | ^ true ].

	^ choice = 2
]

{ #category : 'actions' }
CooHistorySettings class >> declineHistoryRecordingConsent [

	self useNullHistoryRecorder
]

{ #category : 'actions' }
CooHistorySettings class >> enableRemoteHistoryRecording [

	self recordHistoryRecordingConsentAccepted: true.
	historyRecordingEnabled := true.
	remoteDeliveryEnabled := true.

	CooSession install.
	CooHistoryEventRecorder category: #complishon.
	CooHistoryEventRecorder experienceId: 'complishon'.
	CooHistoryEventRecorder deliveryBatchSize: 1.
	CooHistoryEventRecorder install.
	CooHistoryEventRecorder enableDelivery.
	CooHistoryEventRecorder recordRemoteDeliveryEnabled
]

{ #category : 'accessing' }
CooHistorySettings class >> historyRecordingEnabled [

	^ self historyRecordingConsentAccepted and: [ historyRecordingEnabled = true ]
]

{ #category : 'accessing' }
CooHistorySettings class >> historyRecordingEnabled: aBoolean [

	aBoolean
		ifTrue: [
			self privacyConsentAccepted ifFalse: [
				self openFirstLaunchSetup.
				^ self ].

			self enableRemoteHistoryRecording ]
		ifFalse: [
			remoteDeliveryEnabled = true
				ifFalse: [
					self useNullHistoryRecorder.
					^ self ].

			self confirmRemoteDeliveryDisable
				ifTrue: [ self useNullHistoryRecorder ]
				ifFalse: [ historyRecordingEnabled := true ] ]
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingConsentAccepted [

	^ self historyRecordingConsentState = #accepted
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingConsentDeclined [

	^ self historyRecordingConsentState = #declined
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingConsentFirstLaunchText [

	^ 'Help improve Pharo code completion through usage research', String cr,
		String cr,
		'Researchers are studying how developers use history-based completion in Pharo.', String cr,
		'With your explicit permission, this package can record code-completion history events and send them to the configured research server.', String cr,
		String cr,
		'- Participation is voluntary.', String cr,
		'- History telemetry is OFF by default.', String cr,
		'- No events are sent unless you explicitly agree.', String cr,
		'- Closing or cancelling this dialog means no consent.', String cr,
		'- You can disable telemetry later from Settings.', String cr,
		'- Previously submitted research events may not be individually removable.'
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingConsentLearnMoreText [

	^ 'About Code Completion History Research', String cr,
		String cr,
		'Why collect this data?', String cr,
		'The project studies how Pharo developers interact with code-completion and history-based development tools. The goal is to improve completion heuristics, evaluate new features, and support reproducible software-engineering research.', String cr,
		String cr,
		'What may be collected?', String cr,
		'If you agree, the recorder may send events describing class additions, class removals, method additions, method modifications, method removals, completion selections, and recorder lifecycle events.', String cr,
		String cr,
		'Events may include timestamps, event kinds, class names, method selectors, changed message selectors, selected completion entries, completion choices, fetcher names, the configured server URL, and research metadata such as category and experience id.', String cr,
		String cr,
		'What is not intended to be collected?', String cr,
		'The recorder is not intended to collect your name, email address, passwords, credentials, authentication tokens, or full source-code contents. However, class names, method selectors, and completion choices can reveal project vocabulary, so only opt in if you agree to sending that research data.', String cr,
		String cr,
		'Where does the data go?', String cr,
		'If you agree, events are sent through the Pharo-XP/EventRecorder stack to the configured CooHistoryEventRecorder server URL. The default server URL is ', CooHistoryEventRecorder defaultServerUrl asString, '.', String cr,
		String cr,
		'Is participation required?', String cr,
		'No. Refusing telemetry does not prevent you from using Pharo. Without consent, the null recorder is installed and no history events are sent by this setup flow.', String cr,
		String cr,
		'Can you withdraw?', String cr,
		'Yes. You can disable telemetry at any time from Settings. Disabling telemetry stops future collection and delivery. Previously submitted research events may remain on the research server because they may not be linkable back to you.', String cr,
		String cr,
		'Rule: no explicit Yes means no telemetry.'
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingConsentNotAsked [

	^ self historyRecordingConsentState = #notAsked
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingConsentState [

	| normalized |
	historyRecordingConsentState ifNil: [
		historyRecordingConsentState := privacyConsentAccepted = true
			ifTrue: [ #accepted ]
			ifFalse: [
				firstLaunchCompleted = true
					ifTrue: [ #declined ]
					ifFalse: [ #notAsked ] ] ].

	normalized := historyRecordingConsentState ifNil: [ #notAsked ].
	(#(#notAsked #declined #accepted) includes: normalized) ifFalse: [
		historyRecordingConsentState := #declined.
		privacyConsentAccepted := false.
		firstLaunchCompleted := true.
		historyRecordingEnabled := false.
		remoteDeliveryEnabled := false.
		^ #declined ].

	^ normalized
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingDisabledStatusText [

	^ 'Anonymous history telemetry is disabled.', String cr,
		'The null recorder is installed and no code completion history events are sent.'
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingEnabledStatusText [

	^ 'Anonymous history telemetry is enabled.', String cr,
		'Code completion history events are being recorded and sent to the configured research server.'
]

{ #category : 'consent' }
CooHistorySettings class >> historyRecordingDisablePrompt [

	^ 'Disable history telemetry?', String cr,
		String cr,
		'The history recorder will stop sending future code-completion history events to the configured research server.', String cr,
		'Data already submitted may remain on the research server because it may not be linkable back to you.'
]

{ #category : 'consent' }
CooHistorySettings class >> normalizeConsentChoice: choice [

	choice ifNil: [ ^ #decline ].
	choice = 0 ifTrue: [ ^ #decline ].
	(#(#decline #accept #learnMore) includes: choice) ifTrue: [ ^ choice ].
	choice = 1 ifTrue: [ ^ #decline ].
	choice = 2 ifTrue: [ ^ #accept ].
	choice = 3 ifTrue: [ ^ #learnMore ].
	^ #decline
]

{ #category : 'accessing' }
CooHistorySettings class >> openFirstLaunchSetup [

	"Open the first-launch privacy setup. Use the Spec setup wizard when it is
	available and a user interface is running, otherwise fall back to plain
	UIManager dialogs."

	| presenterClass |
	presenterClass := Smalltalk globals
		at: #CooHistorySetupPresenter
		ifAbsent: [ nil ].

	(presenterClass notNil and: [ World notNil ])
		ifTrue: [
			^ [ presenterClass open ]
				on: Error
				do: [ :ex | self openFirstLaunchSetupDialog ] ].

	self openFirstLaunchSetupDialog
]

{ #category : 'accessing' }
CooHistorySettings class >> openFirstLaunchSetupDialog [

	| choice |

	[
		choice := self requestFirstLaunchConsentChoice.
		choice = #learnMore ifTrue: [ self showHistoryRecordingStudyInformation ]
	] doWhileTrue: [ choice = #learnMore ].

	choice = #accept
		ifTrue: [ self enableRemoteHistoryRecording ]
		ifFalse: [ self declineHistoryRecordingConsent ]
]

{ #category : 'actions' }
CooHistorySettings class >> openPrivacyPage [

	self showHistoryRecordingStudyInformation
]

{ #category : 'accessing' }
CooHistorySettings class >> privacyConsentAccepted [

	^ self historyRecordingConsentAccepted
]

{ #category : 'accessing' }
CooHistorySettings class >> privacyConsentAccepted: aBoolean [

	self recordHistoryRecordingConsentAccepted: aBoolean
]

{ #category : 'consent' }
CooHistorySettings class >> recordHistoryRecordingConsentAccepted: aBoolean [

	privacyConsentAccepted := aBoolean = true.
	firstLaunchCompleted := true.
	historyRecordingConsentState := privacyConsentAccepted
		ifTrue: [ #accepted ]
		ifFalse: [ #declined ].

	privacyConsentAccepted ifFalse: [
		historyRecordingEnabled := false.
		remoteDeliveryEnabled := false ].

	^ privacyConsentAccepted
]

{ #category : 'accessing' }
CooHistorySettings class >> remoteDeliveryEnabled [

	^ self historyRecordingConsentAccepted and: [ remoteDeliveryEnabled = true ]
]

{ #category : 'accessing' }
CooHistorySettings class >> remoteDeliveryEnabled: aBoolean [

	aBoolean
		ifTrue: [ self enableRemoteHistoryRecording ]
		ifFalse: [
			remoteDeliveryEnabled = true
				ifFalse: [
					self useNullHistoryRecorder.
					^ self ].

			self confirmRemoteDeliveryDisable
				ifTrue: [ self useNullHistoryRecorder ]
				ifFalse: [ remoteDeliveryEnabled := true ] ]
]

{ #category : 'consent' }
CooHistorySettings class >> requestFirstLaunchConsentChoice [

	| ui labels values choice |
	ui := self uiManager.
	ui ifNil: [ ^ #decline ].

	labels := #('No, don''t collect data' 'Yes, I agree' 'Learn more').
	values := #(#decline #accept #learnMore).

	^ [
		(ui respondsTo: #chooseFrom:values:title:)
			ifTrue: [
				choice := ui
					chooseFrom: labels
					values: values
					title: self historyRecordingConsentFirstLaunchText ]
			ifFalse: [
				choice := ui
					chooseFrom: labels
					title: self historyRecordingConsentFirstLaunchText ].
		self normalizeConsentChoice: choice
	] on: Error do: [ :ex | #decline ]
]

{ #category : 'consent' }
CooHistorySettings class >> showHistoryRecordingStudyInformation [

	| ui message |
	message := self historyRecordingConsentLearnMoreText.
	ui := self uiManager.
	ui ifNotNil: [
		(ui respondsTo: #longMessage:title:) ifTrue: [
			^ ui
				longMessage: message
				title: 'Code Completion History Research' ].
		(ui respondsTo: #inform:) ifTrue: [ ^ ui inform: message ] ].

	Transcript
		show: message;
		cr
]

{ #category : 'actions' }
CooHistorySettings class >> notifyUser: aString [

	"Display a message to the user (UIManager if available, otherwise Transcript)."

	(self notifyViaUIManager: aString) ifTrue: [ ^ self ].
	self notifyViaTranscript: aString
]

{ #category : 'actions' }
CooHistorySettings class >> notifyViaTranscript: aString [

	| transcript |
	transcript := Smalltalk globals at: #Transcript ifAbsent: [ nil ].
	transcript ifNil: [ ^ false ].
	(transcript respondsTo: #show:) ifFalse: [ ^ false ].

	transcript show: aString; cr.
	^ true
]

{ #category : 'actions' }
CooHistorySettings class >> notifyViaUIManager: aString [

	| ui |
	ui := self uiManager.
	(ui notNil and: [ ui respondsTo: #inform: ])
		ifTrue: [
			ui inform: aString.
			^ true ].
	^ false
]

{ #category : 'private' }
CooHistorySettings class >> uiManager [

	| uiClass |
	uiClass := Smalltalk globals at: #UIManager ifAbsent: [ ^ nil ].
	(uiClass respondsTo: #default) ifFalse: [ ^ nil ].
	^ [ uiClass default ] on: Error do: [ :ex | nil ]
]

{ #category : 'actions' }
CooHistorySettings class >> useNullHistoryRecorder [

	self recordHistoryRecordingConsentAccepted: false.
	historyRecordingEnabled := false.
	remoteDeliveryEnabled := false.

	(Smalltalk globals at: #ERPrivacy ifAbsent: [ nil ])
		ifNotNil: [ :privacyClass |
			(privacyClass respondsTo: #sendDiagnosticsAndUsageData:)
				ifTrue: [ privacyClass sendDiagnosticsAndUsageData: false ] ].

	CooHistoryEventRecorder disableDelivery.
	CooHistoryEventRecorder deinstall.
	CooNullHistoryEventRecorder install.
	CooSession current recorder: CooNullHistoryEventRecorder uniqueInstance
]

{ #category : 'accessing' }
CooHistorySettings class >> settingsOn: aBuilder [

	<systemsettings>

	(aBuilder setting: #'Code Completion History')
		target: self;
		parentName: #codeBrowsing;
		selector: #historyRecordingEnabled;
		default: self historyRecordingEnabled;
		label: 'History Recorder Privacy';
		description: 'Configure history recording and remote delivery.';
		iconName: #smallConfiguration;
		with: [

			(aBuilder setting: #remoteDeliveryEnabled)
				order: 2;
				label: 'Send history events to server';
				target: self;
				getSelector: #remoteDeliveryEnabled;
				setSelector: #remoteDeliveryEnabled:;
				default: self remoteDeliveryEnabled;
				description: 'When enabled, collected history events are sent to the configured server URL.' ]
]
