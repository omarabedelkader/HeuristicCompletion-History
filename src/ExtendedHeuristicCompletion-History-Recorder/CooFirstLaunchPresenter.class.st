Class {
	#name : 'CooFirstLaunchPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'label',
		'yesButton',
		'noButton',
		'privacyButton',
		'choice'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'accessing' }
CooFirstLaunchPresenter >> choice [

	^ choice
]

{ #category : 'layout' }
CooFirstLaunchPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
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
		yourself
]

{ #category : 'initialize' }
CooFirstLaunchPresenter >> initializePresenters [
	label := self newLabel
		label: 'Would you like to send anonymous usage history remotely?';
		yourself.

	yesButton := self newButton
		label: 'Yes';
		action: [ choice := #yes. self window close ];
		yourself.

	noButton := self newButton
		label: 'No';
		action: [ choice := #no. self window close ];
		yourself.

	privacyButton := self newButton
		label: 'Privacy Policy';
		action: [ choice := #privacy. self window close ];
		yourself.
]

{ #category : 'initialize' }
CooFirstLaunchPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'First Launch Setup';
		initialExtent: 380@110
]
