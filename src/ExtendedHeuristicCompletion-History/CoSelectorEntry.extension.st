Extension { #name : 'CoSelectorEntry' }

{ #category : '*ExtendedHeuristicCompletion-History' }
CoSelectorEntry >> deltaMessages [ 
	
	^ self sessionItem deltaMessages 
]

{ #category : '*ExtendedHeuristicCompletion-History' }
CoSelectorEntry >> sessionItem [

	^ self propertyAt: #sessionItem ifAbsent: [ self error: 'No item found' ]
]

{ #category : '*ExtendedHeuristicCompletion-History' }
CoSelectorEntry >> sessionItem: anItem [

	self propertyAt: #sessionItem put: anItem
]
