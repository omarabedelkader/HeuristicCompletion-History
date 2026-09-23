Extension { #name : 'CoEntry' }

{ #category : '*ExtendedHeuristicCompletion-History' }
CoEntry class >> stonAllInstVarNames [
	
	^ self allInstVarNames copyWithout: #node
]

{ #category : '*ExtendedHeuristicCompletion-History' }
CoEntry >> stonOn: aBuilder [ 

	aBuilder writeObject: self streamMap: [ :map |
		map at: #contents put: contents.
		map at: #fetcherName put: fetcherName.
      map at: #description put: self description description asString ]
]
