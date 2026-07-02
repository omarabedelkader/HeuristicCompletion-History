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
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Recorder'
}

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

			historyRecordingEnabled := true.
			CooHistoryEventRecorder install ]
		ifFalse: [
			historyRecordingEnabled := false.
			CooHistoryEventRecorder deinstall.
			CooHistoryEventRecorder disableDelivery ]
]

{ #category : 'accessing' }
CooHistorySettings class >> openFirstLaunchSetup [

	| accepted sendRemote message |

	message := 'This plugin records Pharo development history.

It may collect:
- method additions, modifications, and removals
- class additions, modifications, and removals
- completion selections, when available
- timestamps
- image/session metadata

This history is used for history-based completion.

Do you agree to enable history data collection?'.

	accepted := UIManager default confirm: message.

	firstLaunchCompleted := true.
	privacyConsentAccepted := accepted.
	historyRecordingEnabled := accepted.

	accepted
		ifTrue: [
			sendRemote := UIManager default confirm:
				'Do you also agree to send collected history events to the configured server?'.

			remoteDeliveryEnabled := sendRemote.

			sendRemote
				ifTrue: [ CooHistoryEventRecorder install ]
				ifFalse: [ CooNullHistoryEventRecorder install ]]
		ifFalse: [
			remoteDeliveryEnabled := false.
			CooHistoryEventRecorder deinstall.
			CooHistoryEventRecorder disableDelivery ]
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

	remoteDeliveryEnabled := aBoolean.

	aBoolean
		ifTrue: [ CooHistoryEventRecorder enableDelivery ]
		ifFalse: [ CooHistoryEventRecorder disableDelivery ]
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
