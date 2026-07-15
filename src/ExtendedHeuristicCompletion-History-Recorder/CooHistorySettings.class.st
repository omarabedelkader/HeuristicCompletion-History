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
		'remoteDeliveryEnabled'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'actions' }
CooHistorySettings class >> confirmRemoteDeliveryDisable [

	| choice |
	[
	choice := UIManager default
		          chooseFrom: #('Keep sending' 'Turn off')
		          title:
		          'Dommage :( Sending history events helps us improve the completion engine inside Pharo. Do you still want to turn it off?' ]
		on: Error
		do: [ :ex | ^ true ].

	^ choice = 2
]

{ #category : 'actions' }
CooHistorySettings class >> enableRemoteHistoryRecording [

	firstLaunchCompleted := true.
	privacyConsentAccepted := true.
	historyRecordingEnabled := true.
	remoteDeliveryEnabled := true.

	CooSession install.
	CooHistoryEventRecorder category: #complishon.
	CooHistoryEventRecorder deliveryBatchSize: 1.
	CooHistoryEventRecorder install.
	CooHistoryEventRecorder enableDelivery.
	CooHistoryEventRecorder recordRemoteDeliveryEnabled
]

{ #category : 'accessing' }
CooHistorySettings class >> firstLaunchCompleted [

	^ firstLaunchCompleted ifNil: [ firstLaunchCompleted := false ]
]

{ #category : 'accessing' }
CooHistorySettings class >> firstLaunchCompleted: aBoolean [

	firstLaunchCompleted := aBoolean
]

{ #category : 'accessing' }
CooHistorySettings class >> historyRecordingEnabled [

	^ historyRecordingEnabled ifNil: [ historyRecordingEnabled := false ]
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
			self remoteDeliveryEnabled
				ifFalse: [
					self useNullHistoryRecorder.
					^ self ].

			self confirmRemoteDeliveryDisable
				ifTrue: [ self useNullHistoryRecorder ]
				ifFalse: [ historyRecordingEnabled := true ] ]
]

{ #category : 'accessing' }
CooHistorySettings class >> openFirstLaunchSetup [
	| choice sendRemote presenter window semaphore label yesButton noButton privacyButton |
	choice := nil.
	semaphore := Semaphore new.
	presenter := SpPresenter new.

	label := presenter newLabel.
	label label: 'Would you like to send anonymous usage history remotely?'.

	yesButton := presenter newButton.
	yesButton
		label: 'Yes';
		action: [ choice := #yes. window close ].

	noButton := presenter newButton.
	noButton
		label: 'No';
		action: [ choice := #no. window close ].

	privacyButton := presenter newButton.
	privacyButton
		label: 'Privacy Policy';
		action: [ choice := #privacy. window close ].

	presenter
		layout: (SpBoxLayout newVertical
			spacing: 5;
			hAlignCenter;
			add: label expand: false;
			add: (SpBoxLayout newHorizontal
				spacing: 5;
				hAlignCenter;
				add: yesButton expand: false;
				add: noButton expand: false;
				add: privacyButton expand: false;
				yourself) expand: false;
			yourself).

	window := presenter open.
	window title: 'First Launch Setup'.
	window initialExtent: 380@110.
	window whenClosedDo: [ semaphore signal ].
	semaphore wait.

	choice = #privacy
		ifTrue: [
			self openPrivacyPage.
			^ self openFirstLaunchSetup ].

	sendRemote := choice = #yes.
	firstLaunchCompleted := true.
	privacyConsentAccepted := sendRemote.
	sendRemote
		ifTrue: [ self enableRemoteHistoryRecording ]
		ifFalse: [
			historyRecordingEnabled := false.
			remoteDeliveryEnabled := false.
			self useNullHistoryRecorder ]
]

{ #category : 'actions' }
CooHistorySettings class >> openPrivacyPage [

	WebBrowser openOn: 'https://github.com/omarabedelkader/HeuristicCompletion-History/wiki/Data-Collection-and-Storage' asZnUrl
]

{ #category : 'accessing' }
CooHistorySettings class >> privacyConsentAccepted [

	^ privacyConsentAccepted ifNil: [ privacyConsentAccepted := false ]
]

{ #category : 'accessing' }
CooHistorySettings class >> privacyConsentAccepted: aBoolean [

	privacyConsentAccepted := aBoolean
]

{ #category : 'accessing' }
CooHistorySettings class >> remoteDeliveryEnabled [

	^ remoteDeliveryEnabled ifNil: [ remoteDeliveryEnabled := false ]
]

{ #category : 'accessing' }
CooHistorySettings class >> remoteDeliveryEnabled: aBoolean [

	aBoolean
		ifTrue: [ self enableRemoteHistoryRecording ]
		ifFalse: [
			self remoteDeliveryEnabled
				ifFalse: [
					self useNullHistoryRecorder.
					^ self ].

			self confirmRemoteDeliveryDisable
				ifTrue: [ self useNullHistoryRecorder ]
				ifFalse: [ remoteDeliveryEnabled := true ] ]
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

{ #category : 'actions' }
CooHistorySettings class >> useNullHistoryRecorder [

	historyRecordingEnabled := false.
	remoteDeliveryEnabled := false.

	CooHistoryEventRecorder disableDelivery.
	CooHistoryEventRecorder deinstall.
	CooNullHistoryEventRecorder install.
	CooSession current recorder: CooNullHistoryEventRecorder uniqueInstance
]
