"
I'm a subclass of Selector because I need to pass extra information. 
In the future NECEntry should be more extensible.
"
Class {
	#name : 'NECSessionSelectorEntry',
	#superclass : 'NECSelectorEntry',
	#instVars : [
		'sessionItem'
	],
	#category : 'ExtendedHeuristicCompletion-History-NEC',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'NEC'
}

{ #category : 'accessing' }
NECSessionSelectorEntry >> deltaMessages [ 
	
	^ sessionItem deltaMessages 
]

{ #category : 'accessing' }
NECSessionSelectorEntry >> sessionItem [

	^ sessionItem 
]

{ #category : 'accessing' }
NECSessionSelectorEntry >> sessionItem: aSessionItem [

	sessionItem := aSessionItem
]
