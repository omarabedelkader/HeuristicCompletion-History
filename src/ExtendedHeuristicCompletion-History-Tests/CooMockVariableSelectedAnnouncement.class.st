Class {
	#name : 'CooMockVariableSelectedAnnouncement',
	#superclass : 'Object',
	#instVars : [
		'selectedItem'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Tests'
}

{ #category : 'instance creation' }
CooMockVariableSelectedAnnouncement class >> for: aVariable [

    ^ self new
        selectedItem: aVariable;
        yourself
]

{ #category : 'accessing' }
CooMockVariableSelectedAnnouncement >> selectedItem [

    ^ selectedItem
]

{ #category : 'accessing' }
CooMockVariableSelectedAnnouncement >> selectedItem: aVariable [

    selectedItem := aVariable
]
