"
I'm recording structrure that records modified or added methods and classes.
My behavior is to record everything. 

I pay attention to not hold directly class or compiled method objects to avoid creating spurious references. 

"
Class {
	#name : 'CooTemporalHandler',
	#superclass : 'CooProgramEntityHandler',
	#classInstVars : [
		'current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
}

{ #category : 'accessing' }
CooTemporalHandler >> classEntries [
	"Clearly we should manage what happen when we remove a class
	
	
	"
	self halt.
	^ classDescriptions collect: [ :each | (NECGlobalEntry contents: each className node: nil) fetcher: CooTemporalHandler ]
]

{ #category : 'as yet unclassified' }
CooTemporalHandler >> handleNewClassItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
]

{ #category : 'as yet unclassified' }
CooTemporalHandler >> handleNewMethodItem: anItem addedTo: aCollection [
	"here we will have to manage the incremental management of the new event see comments in selectorentries."
]

{ #category : 'printing' }
CooTemporalHandler >> printOn: aStream [

	super printOn: aStream.

]

{ #category : 'initialization' }
CooTemporalHandler >> registerSelector: aSelector ast: anAst event: anEventSymbol at: aDateAndTime [

	selectorDescriptions add: (CooMethodHistoryItem new
			 selector: aSelector;
			 time: aDateAndTime;
			 ast: anAst;
			 yourself) 
]

{ #category : 'accessing' }
CooTemporalHandler >> selectorEntries [
	"
	For now we perform the interpretation of program entities modifications once for all when requested. 
	It means that this is inefficient since we redo all the times the same treatment all the time.
	
	"
	
	| selectors filters |
	selectors := OrderedCollection new: selectorDescriptions size.
	"an add CM1, add/modified CM1, add CM1, removed CM1 = {}"
	
	"The following does implement this semantics removed CM1, add CM1 = CM1"
	
	filters := OrderedCollection new.
	selectorDescriptions do: [ :each | 
		(each event = #removed)
				ifTrue: [ filters add: each ]
				ifFalse: [ (filters anySatisfy: [ :f | ((f selector = each selector ) 
																		and: [ f nameOfClass = each nameOfClass ])])
										ifFalse: [ 
											each selector ifNotNil: [
												"we should find how this is possible to get a description with a nil selector." 
											selectors add: each selector ] ] ] ].
	^ selectors	collect: [ :each | (NECSelectorEntry contents: each  node: nil) fetcher: self ]
]

{ #category : 'accessing' }
CooTemporalHandler >> size [ 

	^ selectorDescriptions size
]
