"
I record all the information about a choice in the completion engine:

- the token
- the presented choices with their origin (the fetchers)
- the fetchers
- the selected item 
- and its index (yes this is redundant. 

Ideally we should also record all the available fetchers so that we can see later if we add a new one if it is valuable or not. 
"
Class {
	#name : 'CooInteractionItem',
	#superclass : 'Object',
	#instVars : [
		'choices',
		'fetchers',
		'selectedItem',
		'token',
		'index',
		'timestamp'
	],
	#category : 'ExtendedHeuristicCompletion-History-UserInteractionModel',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'UserInteractionModel'
}

{ #category : 'accessing' }
CooInteractionItem >> choices [

	^ choices
]

{ #category : 'accessing' }
CooInteractionItem >> choices: anObject [

	choices := anObject
]

{ #category : 'accessing' }
CooInteractionItem >> fetchers [

	^ fetchers
]

{ #category : 'accessing' }
CooInteractionItem >> fetchers: anObject [

	fetchers := anObject
]

{ #category : 'accessing' }
CooInteractionItem >> index [

	^ index
]

{ #category : 'accessing' }
CooInteractionItem >> index: anObject [

	index := anObject
]

{ #category : 'initialization' }
CooInteractionItem >> initialize [

	super initialize.
	"not sure that nil is not better we should revisit this when we will look at the cancel"
	timestamp := DateAndTime now.
	choices := #().
	fetchers := #()
]

{ #category : 'accessing' }
CooInteractionItem >> selectedItem [

	^ selectedItem
]

{ #category : 'accessing' }
CooInteractionItem >> selectedItem: anObject [

	selectedItem := anObject
]

{ #category : 'accessing' }
CooInteractionItem >> token [

	^ token
]

{ #category : 'accessing' }
CooInteractionItem >> token: anObject [

	token := anObject
]
