Class {
	#name : 'CooHistoryImageCloseSurveyTest',
	#superclass : 'TestCase',
	#instVars : [
		'recorder'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder-Tests-Core',
	#package : 'ExtendedHeuristicCompletion-History-Recorder-Tests',
	#tag : 'Core'
}

{ #category : 'fixtures' }
CooHistoryImageCloseSurveyTest >> completeSurveyUI [

	| ui |
	ui := CooHistoryImageCloseSurveyUIManagerDouble new.
	ui ratings: #(5 4 3 2 #codeCompletion 5).
	ui comments: #('Useful overall.').
	^ ui
]

{ #category : 'running' }
CooHistoryImageCloseSurveyTest >> setUp [

	super setUp.

	recorder := CooHistoryEventRecorderMock new.
	recorder deliveryBatchSize: 100.
	recorder drainPendingEvents.
	CooHistoryImageCloseSurvey resetPromptState
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testCollectSurveyResponseUsesSingleFormWhenAvailable [

	| ui response request |
	ui := self completeSurveyUI.

	response := CooHistoryImageCloseSurvey collectSurveyResponseUsing: ui.

	self assert: response notNil.
	self assert: ui requests size equals: 1.
	request := ui requests first.
	self assert: (request includesKey: #surveyFormSpec).
	self assert: ((response at: #ratings) at: #overall) equals: 5.
	self assert: (response at: #tasks) asArray equals: { #codeCompletion }.
	self assert: ((response at: #userProfile) at: #experienceYears) equals: 5.
	self assert: (response at: #feedbackComment) equals: 'Useful overall.'
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testPromptAndRecordContinuesWithBlankOptionalComment [

	| ui event payload |
	ui := CooHistoryImageCloseSurveyUIManagerDouble new.
	ui ratings: #(5 4 3 2 #codeCompletion 5).

	CooHistoryImageCloseSurvey
		promptAndRecordUsing: ui
		recorder: recorder.

	event := recorder pendingEvents first.
	payload := event at: #payload.
	self assert: (payload at: #feedbackComment) equals: ''
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testPromptAndRecordRequiresEveryRequiredSurveyAnswer [

	| ui result |
	ui := CooHistoryImageCloseSurveyUIManagerDouble new.
	ui ratings: #(5 4 3).

	result := CooHistoryImageCloseSurvey
		promptAndRecordUsing: ui
		recorder: recorder.

	self assert: result isNil.
	self assert: recorder pendingEvents isEmpty
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testPromptAndRecordWritesImageCloseSurveyEvent [

	| ratings event payload |
	ratings := CooHistoryImageCloseSurvey
		promptAndRecordUsing: self completeSurveyUI
		recorder: recorder.

	self assert: ratings notNil.
	self assert: recorder pendingEvents size equals: 1.

	event := recorder pendingEvents first.
	self assert: (event at: #kind) equals: #survey.
	self assert: (event at: #event) equals: #imageCloseSurvey.
	self assert: (event includesKey: #timestamp).

	payload := event at: #payload.
	self assert: (payload at: #surveyName) equals: 'image-close-survey'.
	self assert: (payload at: #toolName) equals: 'Code Completion History'.
	self assert: ((payload at: #ratings) at: #overall) equals: 5.
	self assert: (payload at: #tasks) asArray equals: { #codeCompletion }.
	self assert: ((payload at: #userProfile) at: #experienceYears) equals: 5.
	self assert: (payload at: #feedbackComment) equals: 'Useful overall.'
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testSurveyFormSpecMarksRequiredQuestions [

	| spec |
	spec := CooHistoryImageCloseSurvey surveyFormSpec.

	self assert: (spec at: #description) equals: 'Questions marked * are required. Comment is optional.'.
	self assert: ((spec at: #taskQuestion) includesSubstring: '*').
	self assert: ((spec at: #experienceQuestion) includesSubstring: '*').
	self assert: (spec at: #commentQuestion) equals: 'Additional feedback (optional)'
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testValidatedRatingAcceptsOnlyOneToFive [

	self assert: (CooHistoryImageCloseSurvey validatedRating: 1) equals: 1.
	self assert: (CooHistoryImageCloseSurvey validatedRating: '5') equals: 5.
	self assert: (CooHistoryImageCloseSurvey validatedRating: 0) isNil.
	self assert: (CooHistoryImageCloseSurvey validatedRating: 6) isNil.
	self assert: (CooHistoryImageCloseSurvey validatedRating: 'bad') isNil
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testValidatedSurveyResponseRejectsInvalidRating [

	| response ratings |
	response := self validSurveyResponse.
	ratings := response at: #ratings.
	ratings at: #overall put: 6.

	self assert: (CooHistoryImageCloseSurvey validatedSurveyResponse: response) isNil
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testValidatedTaskAcceptsOnlyAvailableTasks [

	self
		assert: (CooHistoryImageCloseSurvey validatedTask: #codeCompletion)
		equals: #codeCompletion.
	self
		assert: (CooHistoryImageCloseSurvey validatedTask: 'navigation')
		equals: #navigation.
	self assert: (CooHistoryImageCloseSurvey validatedTask: #other) isNil
]

{ #category : 'tests' }
CooHistoryImageCloseSurveyTest >> testValidatedUserExperienceAcceptsConfiguredBuckets [

	self assert: (CooHistoryImageCloseSurvey validatedUserExperience: 0) equals: 0.
	self assert: (CooHistoryImageCloseSurvey validatedUserExperience: '10') equals: 10.
	self assert: (CooHistoryImageCloseSurvey validatedUserExperience: 7) isNil
]

{ #category : 'fixtures' }
CooHistoryImageCloseSurveyTest >> validSurveyResponse [

	| ratings |
	ratings := Dictionary new
		at: #overall put: 5;
		at: #suggestionQuality put: 4;
		at: #speed put: 3;
		at: #usefulness put: 2;
		yourself.

	^ Dictionary new
		at: #ratings put: ratings;
		at: #task put: #codeCompletion;
		at: #experienceYears put: 5;
		at: #feedbackComment put: 'Useful overall.';
		yourself
]
