Class {
	#name : 'CooMockCompletionEntry',
	#superclass : 'Object',
	#instVars : [
		'contents'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Session-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Session-Mock'
}

{ #category : 'as yet unclassified' }
CooMockCompletionEntry class >> withContents: aString [

	^ self new
		contents: aString;
		yourself
]

{ #category : 'accessing' }
CooMockCompletionEntry >> contents [

	^ contents
]

{ #category : 'accessing' }
CooMockCompletionEntry >> contents: aString [

	contents := aString
]
