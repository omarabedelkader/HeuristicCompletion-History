"
I'm a setup presenter for the code completion history system.
I present the first-launch privacy consent flow and run the history recorder setup.

I mirror PharoCopilotSetupPresenter: I show a welcome step, a consent choice step,
a learn-more step and a short setup step with a progress bar. Depending on the
consent decision, I either enable remote history recording or install the null
recorder, then close the window.
"
Class {
	#name : 'CooHistorySetupPresenter2',
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

{ #category : 'progress' }
CooHistorySetupPresenter2 class >> indeterminateProgressFrom: current start: start end: end step: step [

	| boundedStart boundedEnd boundedCurrent next |
	boundedStart := ((start ifNil: [ 0 ]) max: 0) min: 1.
	boundedEnd := ((end ifNil: [ 1 ]) max: boundedStart) min: 1.
	boundedStart = boundedEnd ifTrue: [ ^ boundedStart ].

	boundedCurrent := ((current ifNil: [ boundedStart ]) max: boundedStart) min: boundedEnd.
	next := boundedCurrent + (step ifNil: [ 0.004 ]).
	next >= boundedEnd ifTrue: [ ^ boundedStart ].
	^ next
]

{ #category : 'instance creation' }
CooHistorySetupPresenter2 class >> open [
	"Open the setup wizard."

	^ self new open
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> contentContainer [

	^ contentContainer
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> contentContainer: anObject [

	contentContainer := anObject
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> continueSetupAfterConsentDecision [

	titleLabel label: 'Setting up Code Completion History'.
	statusLabel label: ( CooHistoryEventRecorder2 shareNames
		ifTrue: [ 'Enabling history recorder...' ]
		ifFalse: [ 'Installing the null recorder.' ]).

]

{ #category : 'layout' }
CooHistorySetupPresenter2 >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  borderWidth: 14;
		  add: titleLabel expand: false;
		  add: descriptionLabel expand: false;
		  add: contentContainer expand: true;
		  add: statusLabel expand: false;
		  yourself
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> descriptionLabel [

	^ descriptionLabel
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> descriptionLabel: anObject [

	descriptionLabel := anObject
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> handleConsentAccepted [

	CooHistorySettings recordHistoryRecordingConsentAccepted: true.
	statusLabel label: 'Anonymous history telemetry is now enabled. Continuing setup...'.
	self continueSetupAfterConsentDecision
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> handleConsentDeclined [

	CooHistorySettings recordHistoryRecordingConsentAccepted: false.
	statusLabel label: 'Anonymous history telemetry is disabled. Continuing setup...'.
	self continueSetupAfterConsentDecision
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> handleOk [

	self continueSetupAfterConsentDecision
]

{ #category : 'initialization' }
CooHistorySetupPresenter2 >> initializePresenters [

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

	contentContainer := SpPresenter new.

	self showWelcomeStep
]

{ #category : 'initialization' }
CooHistorySetupPresenter2 >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Code Completion History Setup';
		initialExtent: 560 @ 420;
		centered.

]

{ #category : 'initialization' }
CooHistorySetupPresenter2 >> setupProgressPercentage: aNumber [

	| bounded |
	progressIsIndeterminate := false.
	bounded := (aNumber ifNil: [ 0 ]) max: 0.
	bounded := bounded min: 100.
	setupProgress := bounded / 100.0
]

{ #category : 'initialization' }
CooHistorySetupPresenter2 >> showConsentChoiceStep [

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
CooHistorySetupPresenter2 >> showLearnMoreStepReturningTo: returnBlock includeConsentButtons: includeConsentButtons [

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
CooHistorySetupPresenter2 >> showSetupStep [

	titleLabel label: 'Setting up Code Completion History'.
	
]

{ #category : 'initialization' }
CooHistorySetupPresenter2 >> showWelcomeStep [

	titleLabel label: 'Welcome to Code Completion History'.
	descriptionLabel label: 'History-based completion for Pharo.'.
	statusLabel label: ''.

	CooHistorySettings historyRecordingConsentNotAsked
		ifTrue: [ ^ self showConsentChoiceStep ].
	^ self showWelcomeStepAfterConsentDecision
]

{ #category : 'initialization' }
CooHistorySetupPresenter2 >> showWelcomeStepAfterConsentDecision [

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

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> statusLabel [

	^ statusLabel
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> statusLabel: anObject [

	statusLabel := anObject
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> titleLabel [

	^ titleLabel
]

{ #category : 'accessing' }
CooHistorySetupPresenter2 >> titleLabel: anObject [

	titleLabel := anObject
]
