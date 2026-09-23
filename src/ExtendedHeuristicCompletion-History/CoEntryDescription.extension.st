Extension { #name : 'CoEntryDescription' }

{ #category : '*ExtendedHeuristicCompletion-History' }
CoEntryDescription >> stonOn: ston [
    ston writeObject: self streamMap: [ :map |
		map at: #label put: label.
		map at: #title put: title.
      map at: #description put: description asString ]
]
