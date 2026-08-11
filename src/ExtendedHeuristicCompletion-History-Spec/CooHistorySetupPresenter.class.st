"
I'm a setup presenter for the code completion history system.
I present the first-launch privacy consent flow and run the history recorder setup.

I mirror PharoCopilotSetupPresenter: I show a welcome step, a consent choice step,
a learn-more step and a short setup step with a progress bar. Depending on the
consent decision, I either enable remote history recording or install the null
recorder, then close the window.
"
Class {
	#name : 'CooHistorySetupPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleLabel',
		'descriptionLabel',
		'statusLabel',
		'contentContainer',
		'progressBar',
		'setupProcess',
		'setupProgress',
		'progressIsIndeterminate',
		'indeterminateProgressStart',
		'indeterminateProgressEnd'
	],
	#category : 'ExtendedHeuristicCompletion-History-Spec',
	#package : 'ExtendedHeuristicCompletion-History-Spec'
}

{ #category : 'instance creation' }
CooHistorySetupPresenter class >> open [
	"Open the setup wizard."

	^ self new open
]

{ #category : 'progress' }
CooHistorySetupPresenter class >> indeterminateProgressFrom: current start: start end: end step: step [

	| boundedStart boundedEnd boundedCurrent next |
	boundedStart := ((start ifNil: [ 0 ]) max: 0) min: 1.
	boundedEnd := ((end ifNil: [ 1 ]) max: boundedStart) min: 1.
	boundedStart = boundedEnd ifTrue: [ ^ boundedStart ].

	boundedCurrent := ((current ifNil: [ boundedStart ]) max: boundedStart) min: boundedEnd.
	next := boundedCurrent + (step ifNil: [ 0.004 ]).
	next >= boundedEnd ifTrue: [ ^ boundedStart ].
	^ next
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> contentContainer [

	^ contentContainer
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> contentContainer: anObject [

	contentContainer := anObject
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> continueSetupAfterConsentDecision [

	self showSetupStep.
	statusLabel label: (CooHistorySettings historyRecordingConsentAccepted
		ifTrue: [ 'Enabling history recorder...' ]
		ifFalse: [ 'Installing the null recorder.' ]).
	self startSetup
]

{ #category : 'layout' }
CooHistorySetupPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  borderWidth: 14;
		  add: titleLabel expand: false;
		  add: descriptionLabel expand: false;
		  add: contentContainer expand: true;
		  add: statusLabel expand: false;
		  yourself
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> deferUI: aBlock [

	| ui |
	ui := [ UIManager default ] on: Error do: [ nil ].

	(ui notNil and: [ ui respondsTo: #defer: ]) ifTrue: [
		^ ui defer: aBlock ].

	^ aBlock value
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> descriptionLabel [

	^ descriptionLabel
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> descriptionLabel: anObject [

	descriptionLabel := anObject
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> handleConsentAccepted [

	CooHistorySettings recordHistoryRecordingConsentAccepted: true.
	statusLabel label: 'Anonymous history telemetry is now enabled. Continuing setup...'.
	self continueSetupAfterConsentDecision
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> handleConsentDeclined [

	CooHistorySettings recordHistoryRecordingConsentAccepted: false.
	statusLabel label: 'Anonymous history telemetry is disabled. Continuing setup...'.
	self continueSetupAfterConsentDecision
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> handleOk [

	self continueSetupAfterConsentDecision
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> initializePresenters [

	super initializePresenters.

	titleLabel := self newLabel
		label: 'Welcome to Code Completion History';
		yourself.

	descriptionLabel := self newLabel
		label: '';
		yourself.

	statusLabel := self newLabel
		label: '';
		yourself.

	setupProgress := 0.
	progressIsIndeterminate := false.
	indeterminateProgressStart := 0.
	indeterminateProgressEnd := 1.
	progressBar := self newProgressBar.
	progressBar
		progress: [ self progressBarValue ]
		every: 0.1 second.

	contentContainer := SpPresenter new.

	self showWelcomeStep
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.

	aWindowPresenter
		title: 'Code Completion History Setup';
		initialExtent: 560 @ 420;
		centered.

]

{ #category : 'accessing' }
CooHistorySetupPresenter >> performSetup [

	self setupProgressPercentage: 0.
	self deferUI: [ statusLabel label: '' ].

	self deferUI: [
		statusLabel label: (CooHistorySettings historyRecordingConsentAccepted
			ifTrue: [ 'Enabling history recording...' ]
			ifFalse: [ 'Disabling history recording...' ]) ].

	CooHistorySettings historyRecordingConsentAccepted
		ifTrue: [ CooHistorySettings enableRemoteHistoryRecording ]
		ifFalse: [ CooHistorySettings declineHistoryRecordingConsent ].

	self deferUI: [
		self setupProgressPercentage: 100.
		statusLabel label: 'OKAY! Code Completion History setup is complete.'.
		CooHistorySettings notifyUser: 'OKAY! Code Completion History setup is complete.'.
		self window close ]
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> progressBarValue [

	progressIsIndeterminate ifTrue: [
		setupProgress := self class
			indeterminateProgressFrom: setupProgress
			start: indeterminateProgressStart
			end: indeterminateProgressEnd
			step: 0.004 ].

	^ setupProgress ifNil: [ 0 ]
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> setupProgressPercentage: aNumber [

	| bounded |
	progressIsIndeterminate := false.
	bounded := (aNumber ifNil: [ 0 ]) max: 0.
	bounded := bounded min: 100.
	setupProgress := bounded / 100.0
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> showConsentChoiceStep [

	| messageLabel telemetryStateLabel learnMoreButton noButton yesButton buttonRow |
	titleLabel label: 'Help improve Pharo'.
	descriptionLabel label: 'Anonymous usage research consent for code completion history.'.
	statusLabel label: ''.

	messageLabel := self newLabel
		label: CooHistorySettings historyRecordingConsentFirstLaunchText;
		yourself.

	telemetryStateLabel := self newLabel
		label: 'Anonymous history telemetry is OFF by default.';
		yourself.

	learnMoreButton := self newButton
		label: 'Learn more';
		action: [
			self
				showLearnMoreStepReturningTo: [ self showConsentChoiceStep ]
				includeConsentButtons: true ];
		yourself.

	noButton := self newButton
		label: 'Do not collect data';
		action: [ self handleConsentDeclined ];
		yourself.

	yesButton := self newButton
		label: 'Yes, I agree';
		action: [ self handleConsentAccepted ];
		yourself.

	buttonRow := SpBoxLayout newHorizontal
		spacing: 10;
		add: learnMoreButton;
		add: noButton;
		add: yesButton;
		yourself.

	contentContainer layout: (SpBoxLayout newTopToBottom
		spacing: 12;
		add: messageLabel expand: true;
		add: telemetryStateLabel expand: false;
		add: buttonRow expand: false;
		yourself).

	self layout: self defaultLayout
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> showLearnMoreStepReturningTo: returnBlock includeConsentButtons: includeConsentButtons [

	| detailsText backButton noButton yesButton continueButton buttonRow |
	titleLabel label: 'Anonymous Usage Research'.
	descriptionLabel label: 'Details about the code completion history research project.'.
	statusLabel label: 'Use the scroll bar to read the full study information.'.

	detailsText := self newText.
	detailsText
		text: CooHistorySettings historyRecordingConsentLearnMoreText;
		beNotEditable.

	backButton := self newButton
		label: 'Back';
		action: [ returnBlock value ];
		yourself.

	includeConsentButtons
		ifTrue: [
			noButton := self newButton
				label: 'Do not collect data';
				action: [ self handleConsentDeclined ];
				yourself.

			yesButton := self newButton
				label: 'Yes, I agree';
				action: [ self handleConsentAccepted ];
				yourself.

			buttonRow := SpBoxLayout newHorizontal
				spacing: 10;
				add: backButton;
				add: noButton;
				add: yesButton;
				yourself ]
		ifFalse: [
			continueButton := self newButton
				label: 'Continue setup';
				action: [ self handleOk ];
				yourself.

			buttonRow := SpBoxLayout newHorizontal
				spacing: 10;
				add: backButton;
				add: continueButton;
				yourself ].

	contentContainer layout: (SpBoxLayout newTopToBottom
		spacing: 10;
		add: detailsText expand: true;
		add: buttonRow expand: false;
		yourself).

	self layout: self defaultLayout
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> showSetupStep [

	titleLabel label: 'Setting up Code Completion History'.
	descriptionLabel label: 'LOADING .....'.
	statusLabel label: ''.

	self setupProgressPercentage: 0.

	contentContainer layout: (SpBoxLayout newTopToBottom
		spacing: 12;
		add: progressBar expand: false;
		add: SpNullPresenter new expand: true;
		yourself).

	self layout: self defaultLayout
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> showWelcomeStep [

	titleLabel label: 'Welcome to Code Completion History'.
	descriptionLabel label: 'History-based completion for Pharo.'.
	statusLabel label: ''.

	CooHistorySettings historyRecordingConsentNotAsked
		ifTrue: [ ^ self showConsentChoiceStep ].
	^ self showWelcomeStepAfterConsentDecision
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> showWelcomeStepAfterConsentDecision [

	| messageLabel learnMoreButton continueButton buttonRow |
	messageLabel := self newLabel
		label: (CooHistorySettings historyRecordingConsentAccepted
			ifTrue: [ CooHistorySettings historyRecordingEnabledStatusText ]
			ifFalse: [ CooHistorySettings historyRecordingDisabledStatusText ]);
		yourself.

	learnMoreButton := self newButton
		label: 'Learn more';
		action: [
			self
				showLearnMoreStepReturningTo: [ self showWelcomeStepAfterConsentDecision ]
				includeConsentButtons: false ];
		yourself.

	continueButton := self newButton
		label: 'Continue setup';
		action: [ self handleOk ];
		yourself.

	buttonRow := SpBoxLayout newHorizontal
		spacing: 10;
		add: learnMoreButton;
		add: continueButton;
		yourself.

	contentContainer layout: (SpBoxLayout newTopToBottom
		spacing: 10;
		add: messageLabel expand: true;
		add: buttonRow expand: false;
		yourself).

	self layout: self defaultLayout
]

{ #category : 'initialization' }
CooHistorySetupPresenter >> startSetup [

	setupProcess := [
		self performSetup
	] forkAt: Processor userBackgroundPriority named: 'Code Completion History setup'
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> statusLabel [

	^ statusLabel
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> statusLabel: anObject [

	statusLabel := anObject
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> titleLabel [

	^ titleLabel
]

{ #category : 'accessing' }
CooHistorySetupPresenter >> titleLabel: anObject [

	titleLabel := anObject
]
