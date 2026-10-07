"
A small Spec2 settings dialog: a multi-line text on top, a label with a radio button below, and OK/Cancel buttons at the bottom.
"
Class {
	#name : 'CooCompletionSharingPreferencesPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'text',
		'label',
		'radioButton',
		'okButton',
		'cancelButton'
	],
	#category : 'ExtendedHeuristicCompletion-History-Spec',
	#package : 'ExtendedHeuristicCompletion-History-Spec'
}

{ #category : 'instance creation' }
CooCompletionSharingPreferencesPresenter class >> open [
	<script>
	^ self new open
]

{ #category : 'layout' }
CooCompletionSharingPreferencesPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: text expand: true; 
		  add: (SpBoxLayout newLeftToRight
				   add: label expand: false;
				   add: radioButton expand: false;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newLeftToRight
				   add: okButton expand: true;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'initialization' }
CooCompletionSharingPreferencesPresenter >> initializePresenters [

	text := self newText.
	text text: self textContents.
	label := self newLabel.
	label label: 'Enable completion sharing preferences'.
	
	radioButton := self newCheckBox.
	radioButton label: 'Share information'.
	radioButton state: false. 
	radioButton whenChangedDo: [ :st | CooHistoryEventRecorder2 shareNames: st ].
	
	okButton := self newButton.
	okButton
		label: 'Close';
		action: [ self window close. 
			CooHistoryEventRecorder2 shareNames: radioButton state.
			CooHistoryEventRecorder2 shareNames
				ifTrue: [ self inform: 'Thanks sharing your information' ]
			 ].

]

{ #category : 'initialization' }
CooCompletionSharingPreferencesPresenter >> textContents [

	^ 'Help us improve Pharo completion engine. To improve it we need to collect the following information from your interaction with the completion menu: the token you typed, the choices that the completion engine proposed to you, the choices you made and how the completion engine was configured. 
	
	Your identity will not be collected. No personal data are collected since the information that you will share is anonymous.
	We will only collect names of entities: selectors, variable names, class names.
	You will be able to change later your decision using the setting browser.'
]

{ #category : 'accessing' }
CooCompletionSharingPreferencesPresenter >> windowTitle [

	^ 'Share Completion Selection Preferences'
]
