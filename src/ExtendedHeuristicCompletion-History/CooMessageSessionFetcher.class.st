"
I'm responsible for providing selector completion based on the current development session 

In essence I ask the session its selectorEntries

```
entriesDo: aBlock

	self session selectorEntries  
		do: [ :e | aBlock value: (e node: astNode) ]
```
"
Class {
	#name : 'CooMessageSessionFetcher',
	#superclass : 'CooSessionFetcher',
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'enumerating' }
CooMessageSessionFetcher >> entriesDo: aBlock [

	self session selectorEntries  
		do: [ :e | aBlock value: (e node: astNode) ]
]
