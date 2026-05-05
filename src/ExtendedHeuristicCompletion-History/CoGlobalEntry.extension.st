Extension { #name : 'CoGlobalEntry' }

{ #category : '*ExtendedHeuristicCompletion-History' }
CoGlobalEntry >> sessionItem [

	^ self propertyAt: #sessionItem ifAbsent: [ self error: 'No item found' ]
]

{ #category : '*ExtendedHeuristicCompletion-History' }
CoGlobalEntry >> sessionItem: anItem [

	self propertyAt: #sessionItem put: anItem
]
