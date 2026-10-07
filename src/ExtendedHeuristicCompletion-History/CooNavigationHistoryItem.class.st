"
I record the fact that the developer has *seen* a program element while navigating a Calypso browser.

Unlike the structural history items (added/modified/removed) I'm purely an observation: the user just looked at a class, package or method without necessarily editing it.

I carry:
- `name`        the displayed name of the navigated element (a class name or a selector)
- `kind`        either #class or #selector to know how to feed it back to the completion engine
- `timestamp`   when the observation was captured
- `browserTitle` (optional) the label of the originating Calypso browser
- `paneIndex`    (optional) the pane the selection was read from
"
Class {
	#name : 'CooNavigationHistoryItem',
	#superclass : 'CooItem',
	#instVars : [
		'name',
		'kind',
		'browserTitle',
		'paneIndex'
	],
	#category : 'ExtendedHeuristicCompletion-History-Navigation',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Navigation'
}

{ #category : 'instance creation' }
CooNavigationHistoryItem class >> class: aClassName [

	^ self new
		  kind: #class;
		  name: aClassName;
		  yourself
]

{ #category : 'instance creation' }
CooNavigationHistoryItem class >> selector: aSelector [

	^ self new
		  kind: #selector;
		  name: aSelector asString;
		  yourself
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> browserTitle [

	^ browserTitle
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> browserTitle: aString [

	browserTitle := aString
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> initialize [

	super initialize.
	timestamp := DateAndTime now
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> isClassObservation [

	^ kind = #class
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> isSelectorObservation [

	^ kind = #selector
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> kind [

	^ kind
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> kind: aSymbol [

	kind := aSymbol
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> name [

	^ name
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> paneIndex [

	^ paneIndex
]

{ #category : 'accessing' }
CooNavigationHistoryItem >> paneIndex: anObject [

	paneIndex := anObject
]

{ #category : 'printing' }
CooNavigationHistoryItem >> printOn: aStream [

	super printOn: aStream.
	aStream space.
	aStream nextPutAll: '('.
	aStream nextPutAll: (kind ifNil: [ 'unknown' ] ifNotNil: [ kind asString ]).
	aStream nextPutAll: ') '.
	name ifNotNil: [ aStream nextPutAll: name ].
	browserTitle ifNotNil: [
		aStream nextPutAll: ' @ '.
		aStream nextPutAll: browserTitle ]
]
