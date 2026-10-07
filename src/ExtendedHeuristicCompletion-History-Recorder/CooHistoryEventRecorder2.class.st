Class {
	#name : 'CooHistoryEventRecorder2',
	#superclass : 'EREventRecorder',
	#classInstVars : [
		'sharedNames'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-New',
	#package : 'ExtendedHeuristicCompletion-History-Recorder',
	#tag : 'New'
}

{ #category : 'settings' }
CooHistoryEventRecorder2 class >> completionSettingsOn: aBuilder [
	<systemsettings>

	(aBuilder group: #SharingCompletion)
		parentName: #codeBrowsing;
		label: 'Code Completion Diagnostics And Usage Anonymously Shared';
		noOrdering;
		iconName: #smallConfiguration;
		description: 'Settings for completion session anonymous sharing: entered token, index in the choice list, choices (selectors, variables or class names) proposed to the user by the completion engine. Help us improving your UX experience!'
		
	
]

{ #category : 'settings' }
CooHistoryEventRecorder2 class >> settingsOn: aBuilder [

	<systemsettings>

	(aBuilder setting: #'ShareNames')
		target: self;
		parentName: #SharingCompletion;
		selector: #shareNames;
		default: self shareNamesDefault;
		label: 'Send names (selectors, var, class names)';
		description: 'Share completion item entity names: the index of user selection, the entered token, the choices presented to the user(class names, selectors, variable names will be sent) by the completion engine. No class definition or method definitions will be sent';
		iconName: #smallConfiguration.
	

]

{ #category : 'settings' }
CooHistoryEventRecorder2 class >> shareNames [

	^ sharedNames
]

{ #category : 'settings' }
CooHistoryEventRecorder2 class >> shareNames: aBoolean [

	sharedNames := aBoolean 
]

{ #category : 'settings' }
CooHistoryEventRecorder2 class >> shareNamesDefault [
	^ false
]

{ #category : 'logging' }
CooHistoryEventRecorder2 >> log: info [

	self class shareNames 
		ifTrue: [ self log: info ]
]
