"
I ask a short feedback form when the Pharo image is about to quit.
Answers are recorded through CooHistoryEventRecorder as a survey event.
"
Class {
	#name : 'CooHistoryImageCloseSurvey',
	#superclass : 'Object',
	#classInstVars : [
		'promptInProgress',
		'promptedForCurrentQuit'
	],
	#category : 'ExtendedHeuristicCompletion-History-Recorder',
	#package : 'ExtendedHeuristicCompletion-History-Recorder'
}

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> askOptionalCommentUsing: uiManager [

	| comment |
	uiManager ifNil: [ ^ nil ].
	(uiManager respondsTo: #multiLineRequest:initialAnswer:answerHeight:) ifTrue: [
		comment := uiManager
			multiLineRequest: self optionalCommentQuestionTitle
			initialAnswer: ''
			answerHeight: self optionalCommentAnswerHeight.
		^ self validatedOptionalComment: comment ].
	(uiManager respondsTo: #request:initialAnswer:title:) ifFalse: [ ^ nil ].

	comment := uiManager
		request: self optionalCommentQuestionTitle
		initialAnswer: ''
		title: self optionalCommentWindowTitle.

	^ self validatedOptionalComment: comment
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> askQuestion: anAssociation using: uiManager [

	| rating |
	uiManager ifNil: [ ^ nil ].
	(uiManager respondsTo: #chooseFrom:values:title:) ifFalse: [ ^ nil ].

	rating := uiManager
		chooseFrom: self ratingLabels
		values: self ratingValues
		title: anAssociation value.

	^ self validatedRating: rating
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> askSurveyFormUsing: uiManager [

	| presenterClass |
	uiManager ifNil: [ ^ nil ].

	(uiManager respondsTo: #imageCloseSurveyFormWithSpec:) ifTrue: [
		^ uiManager imageCloseSurveyFormWithSpec: self surveyFormSpec ].

	presenterClass := self singleFormPresenterClass.
	presenterClass ifNil: [
		^ self collectSurveyResponseSequentiallyUsing: uiManager ].

	^ [
		presenterClass openAndWait
	] on: Error do: [ :ex |
		self logSurveyError: ex.
		self collectSurveyResponseSequentiallyUsing: uiManager ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> askTaskUsing: uiManager [

	| task |
	uiManager ifNil: [ ^ nil ].
	(uiManager respondsTo: #chooseFrom:values:title:) ifFalse: [ ^ nil ].

	task := uiManager
		chooseFrom: self taskLabels
		values: self taskValues
		title: self taskQuestionTitle.

	^ self validatedTask: task
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> askUserExperienceUsing: uiManager [

	| experience |
	uiManager ifNil: [ ^ nil ].
	(uiManager respondsTo: #chooseFrom:values:title:) ifFalse: [ ^ nil ].

	experience := uiManager
		chooseFrom: self userExperienceLabels
		values: self userExperienceValues
		title: self userExperienceQuestionTitle.

	^ self validatedUserExperience: experience
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> availableTaskLabelsByKey [

	| labels |
	labels := Dictionary new.
	self taskChoices do: [ :task |
		labels at: task key put: task value ].
	^ labels
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> availableUserExperienceLabelsByValue [

	| labels |
	labels := Dictionary new.
	self userExperienceChoices do: [ :choice |
		labels at: choice key asString put: choice value ].
	^ labels
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> collectRatingsUsing: uiManager [

	| ratings rating |
	ratings := Dictionary new.
	self surveyQuestions do: [ :question |
		rating := self askQuestion: question using: uiManager.
		rating ifNil: [ ^ nil ].
		ratings at: question key put: rating ].
	^ ratings
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> collectSurveyResponseSequentiallyUsing: uiManager [

	| ratings tasks userProfile feedbackComment |
	ratings := self collectRatingsUsing: uiManager.
	ratings ifNil: [ ^ nil ].
	tasks := self collectTasksUsing: uiManager.
	userProfile := self collectUserProfileUsing: uiManager.
	feedbackComment := self askOptionalCommentUsing: uiManager.

	^ Dictionary new
		at: #ratings put: ratings;
		at: #tasks put: tasks;
		at: #userProfile put: userProfile;
		at: #feedbackComment put: feedbackComment;
		yourself
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> collectSurveyResponseUsing: uiManager [

	^ self validatedSurveyResponse: (self askSurveyFormUsing: uiManager)
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> collectTasksUsing: uiManager [

	| task |
	task := self askTaskUsing: uiManager.
	^ task
		ifNil: [ #() ]
		ifNotNil: [ { task } ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> collectUserProfileUsing: uiManager [

	| experience profile |
	profile := Dictionary new.
	experience := self askUserExperienceUsing: uiManager.
	experience ifNotNil: [ profile at: #experienceYears put: experience ].
	^ profile
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> hasInteractiveUI [

	| manager |
	(Smalltalk respondsTo: #isInteractive) ifTrue: [
		Smalltalk isInteractive ifFalse: [ ^ false ] ].

	manager := self uiManager.
	manager ifNil: [ ^ false ].
	manager class name = #NonInteractiveUIManager ifTrue: [ ^ false ].
	^ manager respondsTo: #chooseFrom:values:title:
]

{ #category : 'logging' }
CooHistoryImageCloseSurvey class >> logSurveyError: anException [

	[
		Transcript
			show: 'Code Completion History feedback failed: ';
			show: anException description;
			cr
	] on: Error do: [ :ignored | nil ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> optionalCommentAnswerHeight [

	^ 180
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> optionalCommentFormTitle [

	^ 'Additional feedback (optional)'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> optionalCommentQuestionTitle [

	^ 'Do you have any thoughts or feedback to share, positive or negative? (Optional - you can leave this blank and continue.)'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> optionalCommentWindowTitle [

	^ 'Code Completion History feedback'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> promptAndRecordUsing: uiManager recorder: aRecorder [

	| response ratings tasks userProfile feedbackComment |
	response := self collectSurveyResponseUsing: uiManager.
	response ifNil: [ ^ nil ].
	ratings := response at: #ratings.
	tasks := response at: #tasks.
	userProfile := response at: #userProfile.
	feedbackComment := response at: #feedbackComment.
	self
		recordRatings: ratings
		tasks: tasks
		userProfile: userProfile
		feedbackComment: feedbackComment
		recorder: aRecorder.
	^ ratings
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> promptBeforeImageQuit [

	^ self
		promptBeforeImageQuitUsing: self uiManager
		recorder: CooHistoryEventRecorder uniqueInstance
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> promptBeforeImageQuitUsing: uiManager recorder: aRecorder [

	self shouldPromptBeforeImageQuit ifFalse: [ ^ nil ].
	promptInProgress = true ifTrue: [ ^ nil ].
	promptedForCurrentQuit = true ifTrue: [ ^ nil ].

	promptedForCurrentQuit := true.
	promptInProgress := true.
	[
		^ [
			self
				promptAndRecordUsing: uiManager
				recorder: aRecorder
		] on: Error do: [ :ex |
			self logSurveyError: ex.
			nil ]
	] ensure: [
		promptInProgress := false ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> questionLabelsByKey [

	| labels |
	labels := Dictionary new.
	self surveyQuestions do: [ :question |
		labels at: question key put: question value ].
	^ labels
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> ratingHighAnchorLabel [

	^ 'Extremely useful'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> ratingLabels [

	^ #(
		'1 star - Poor'
		'2 stars - Fair'
		'3 stars - Good'
		'4 stars - Very good'
		'5 stars - Excellent'
	)
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> ratingLowAnchorLabel [

	^ 'Not useful at all'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> ratingValues [

	^ #(1 2 3 4 5)
]

{ #category : 'logging' }
CooHistoryImageCloseSurvey class >> recordRatings: ratingsDictionary tasks: taskCollection userProfile: userProfileDictionary feedbackComment: feedbackComment recorder: aRecorder [

	aRecorder ifNil: [ ^ self ].
	aRecorder recordImageCloseSurveyPayload: (self
		surveyPayloadForRatings: ratingsDictionary
		tasks: taskCollection
		userProfile: userProfileDictionary
		feedbackComment: feedbackComment
		recorder: aRecorder)
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> requiredQuestionTitle: aString [

	^ aString , ' *'
]

{ #category : 'session management' }
CooHistoryImageCloseSurvey class >> resetPromptState [

	promptInProgress := false.
	promptedForCurrentQuit := false
]

{ #category : 'session management' }
CooHistoryImageCloseSurvey class >> shouldPromptBeforeImageQuit [

	CooHistorySettings imageCloseSurveyEnabled ifFalse: [ ^ false ].
	^ self hasInteractiveUI
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> singleFormPresenterClass [

	^ Smalltalk globals
		at: #CooHistoryImageCloseSurveyPresenter
		ifAbsent: [ nil ]
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> stringOrNil: anObject [

	^ anObject ifNotNil: [ :value | value asString ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyFormDescription [

	^ 'Questions marked * are required. Comment is optional.'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyFormSpec [

	^ Dictionary new
		at: #title put: self surveyFormWindowTitle;
		at: #heading put: self surveyFormTitle;
		at: #description put: self surveyFormDescription;
		at: #questions put: self surveyQuestions;
		at: #ratingValues put: self ratingValues;
		at: #ratingLowLabel put: self ratingLowAnchorLabel;
		at: #ratingHighLabel put: self ratingHighAnchorLabel;
		at: #taskQuestion put: (self requiredQuestionTitle: self taskQuestionTitle);
		at: #taskChoices put: self taskChoices;
		at: #experienceQuestion put: (self requiredQuestionTitle: self userExperienceQuestionTitle);
		at: #experienceChoices put: self userExperienceChoices;
		at: #commentQuestion put: self optionalCommentFormTitle;
		at: #requiredMessage put: self surveyRequiredMessage;
		yourself
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyFormTitle [

	^ 'Code Completion History feedback'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyFormWindowTitle [

	^ 'Code Completion History Feedback'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyPayloadForRatings: ratingsDictionary tasks: taskCollection userProfile: userProfileDictionary feedbackComment: feedbackComment recorder: aRecorder [

	| payload |
	payload := Dictionary new
		at: #surveyName put: 'image-close-survey';
		at: #toolName put: 'Code Completion History';
		at: #timestamp put: DateAndTime now asString;
		at: #questions put: self questionLabelsByKey;
		at: #ratings put: ratingsDictionary;
		at: #availableTasks put: self availableTaskLabelsByKey;
		at: #tasks put: taskCollection asArray;
		at: #availableUserExperience put: self availableUserExperienceLabelsByValue;
		at: #userProfile put: (userProfileDictionary ifNil: [ Dictionary new ]);
		yourself.

	aRecorder ifNotNil: [
		payload
			at: #serverUrl put: aRecorder serverUrl asString;
			at: #category put: aRecorder category asString;
			at: #experienceId put: (self stringOrNil: aRecorder experienceId);
			at: #participantUUID put: (self stringOrNil: aRecorder participantUUID);
			at: #taskOrSurveyId put: (self stringOrNil: aRecorder taskOrSurveyId) ].

	feedbackComment ifNotNil: [
		payload at: #feedbackComment put: feedbackComment ].
	^ payload
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyQuestions [

	^ {
		#overall -> 'Overall, how would you rate Code Completion History this session?'.
		#suggestionQuality -> 'How would you rate the quality of history-based suggestions?'.
		#speed -> 'How would you rate completion response speed?'.
		#usefulness -> 'How useful was Code Completion History for your coding this session?'
	}
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> surveyRequiredMessage [

	^ 'Please answer every question marked with * before submitting.'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> taskChoices [

	^ {
		#codeCompletion -> 'Writing code with completions'.
		#navigation -> 'Navigating or browsing code'.
		#debugging -> 'Debugging or fixing errors'.
		#refactoring -> 'Refactoring existing code'.
		#tests -> 'Writing or updating tests'.
		#codeReview -> 'Reviewing or understanding code'.
		#documentation -> 'Writing comments or documentation'.
		#setup -> 'Configuring history completion'.
		#learning -> 'Learning Pharo or APIs'
	}
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> taskLabels [

	^ self taskChoices collect: [ :task | task value ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> taskQuestionTitle [

	^ 'Which task did you perform this session?'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> taskValues [

	^ self taskChoices collect: [ :task | task key ]
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> taskValueFromSurveyResponse: aDictionary [

	| task tasks |
	task := aDictionary at: #task ifAbsent: [ nil ].
	task ifNotNil: [ ^ task ].

	tasks := aDictionary at: #tasks ifAbsent: [ #() ].
	(tasks respondsTo: #isEmpty) ifFalse: [ ^ nil ].
	tasks isEmpty ifTrue: [ ^ nil ].
	^ tasks first
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> uiManager [

	| uiClass |
	uiClass := Smalltalk globals at: #UIManager ifAbsent: [ ^ nil ].
	(uiClass respondsTo: #default) ifFalse: [ ^ nil ].
	^ [ uiClass default ] on: Error do: [ :ex | nil ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> userExperienceChoices [

	^ {
		0 -> 'Less than 2 years'.
		2 -> 'Between 2 and 5 years'.
		5 -> 'Between 5 and 10 years'.
		10 -> 'More than 10 years'
	}
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> userExperienceLabels [

	^ self userExperienceChoices collect: [ :choice | choice value ]
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> userExperienceQuestionTitle [

	^ 'How many years of programming experience do you have?'
]

{ #category : 'survey' }
CooHistoryImageCloseSurvey class >> userExperienceValues [

	^ self userExperienceChoices collect: [ :choice | choice key ]
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> userExperienceValueFromSurveyResponse: aDictionary [

	| experience userProfile |
	experience := aDictionary at: #experienceYears ifAbsent: [ nil ].
	experience ifNotNil: [ ^ experience ].

	userProfile := aDictionary at: #userProfile ifAbsent: [ nil ].
	(userProfile respondsTo: #at:ifAbsent:) ifFalse: [ ^ nil ].
	^ userProfile at: #experienceYears ifAbsent: [ nil ]
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> validatedOptionalComment: anObject [

	anObject ifNil: [ ^ nil ].
	(anObject respondsTo: #asString) ifFalse: [ ^ nil ].
	^ anObject asString
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> validatedRating: anObject [

	| rating |
	anObject ifNil: [ ^ nil ].

	rating := anObject isNumber
		ifTrue: [ anObject asInteger ]
		ifFalse: [
			(anObject respondsTo: #asString)
				ifTrue: [ Integer readFrom: anObject asString ifFail: [ nil ] ]
				ifFalse: [ nil ] ].

	rating ifNil: [ ^ nil ].
	^ (self ratingValues includes: rating)
		ifTrue: [ rating ]
		ifFalse: [ nil ]
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> validatedSurveyResponse: anObject [

	| ratingsInput ratings rating task experience profile comment |
	anObject ifNil: [ ^ nil ].
	(anObject respondsTo: #at:ifAbsent:) ifFalse: [ ^ nil ].

	ratingsInput := anObject at: #ratings ifAbsent: [ nil ].
	(ratingsInput respondsTo: #at:ifAbsent:) ifFalse: [ ^ nil ].

	ratings := Dictionary new.
	self surveyQuestions do: [ :question |
		rating := self validatedRating:
			(ratingsInput at: question key ifAbsent: [ nil ]).
		rating ifNil: [ ^ nil ].
		ratings at: question key put: rating ].

	task := self validatedTask:
		(self taskValueFromSurveyResponse: anObject).
	task ifNil: [ ^ nil ].

	experience := self validatedUserExperience:
		(self userExperienceValueFromSurveyResponse: anObject).
	experience ifNil: [ ^ nil ].

	profile := Dictionary new
		at: #experienceYears put: experience;
		yourself.
	comment := self validatedOptionalComment:
		(anObject at: #feedbackComment ifAbsent: [ '' ]).

	^ Dictionary new
		at: #ratings put: ratings;
		at: #tasks put: { task };
		at: #userProfile put: profile;
		at: #feedbackComment put: (comment ifNil: [ '' ]);
		yourself
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> validatedTask: anObject [

	| task |
	anObject ifNil: [ ^ nil ].
	task := anObject isSymbol
		ifTrue: [ anObject ]
		ifFalse: [
			(anObject respondsTo: #asString)
				ifTrue: [ anObject asString asSymbol ]
				ifFalse: [ nil ] ].

	^ (self taskValues includes: task)
		ifTrue: [ task ]
		ifFalse: [ nil ]
]

{ #category : 'private' }
CooHistoryImageCloseSurvey class >> validatedUserExperience: anObject [

	| experience |
	anObject ifNil: [ ^ nil ].

	experience := anObject isNumber
		ifTrue: [ anObject asInteger ]
		ifFalse: [
			(anObject respondsTo: #asString)
				ifTrue: [ Integer readFrom: anObject asString ifFail: [ nil ] ]
				ifFalse: [ nil ] ].

	experience ifNil: [ ^ nil ].
	^ (self userExperienceValues includes: experience)
		ifTrue: [ experience ]
		ifFalse: [ nil ]
]
