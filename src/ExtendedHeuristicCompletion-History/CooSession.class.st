Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-New',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'New'
}

{ #category : 'accessing' }
CooSession class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooSession class >> deinstall [

	<script>
	self environment codeChangeAnnouncer unsubscribe: self current.
	Current := nil
]

{ #category : 'actions' }
CooSession class >> install [

	<script>
	self deinstall.
	self environment codeChangeAnnouncer when: MethodAdded send: #addNewMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodModified send: #addModifiedMethodInVocabulary: to: self current.
	self environment codeChangeAnnouncer when: MethodRemoved send: #removeMethodFromVocabulary: to: self current.
	
	self environment codeChangeAnnouncer
		when: ClassAdded send: #addNewVariableInVocabulary: to: self current;
		when: ClassRemoved send: #removeVariableFromVocabulary: to: self current
]

{ #category : 'instance creation' }
CooSession class >> withCache: aCache [

	^ self current vocabularyCache: aCache
]

{ #category : 'adding' }
CooSession >> addModifiedMethodInVocabulary: anAnn [

	vocabularyCache addModifiedMethodInVocabulary: anAnn 
]

{ #category : 'adding' }
CooSession >> addNewMethodInVocabulary: anAnn [

	vocabularyCache addNewMethodInVocabulary: anAnn
]

{ #category : 'adding' }
CooSession >> addNewVariableInVocabulary: aClassAdded [ 
	vocabularyCache addNewVariableInVocabulary: aClassAdded
]

{ #category : 'initialization' }
CooSession >> initialize [ 
	super initialize.
	vocabularyCache := CooNewTemporalCache new.
]

{ #category : 'adding' }
CooSession >> removeMethodFromVocabulary: aMethodRemovedAnnouncement [ 

	vocabularyCache removeMethodFromVocabulary: aMethodRemovedAnnouncement 
]

{ #category : 'adding' }
CooSession >> removeVariableFromVocabulary: aClassRemoved [ 
	vocabularyCache removeVariableFromVocabulary: aClassRemoved 
]

{ #category : 'matching' }
CooSession >> selectors [
	^ vocabularyCache selectors
]

{ #category : 'matching' }
CooSession >> variableNames [
	^ vocabularyCache variableNames
]

{ #category : 'accessing' }
CooSession >> vocabularyCache [
	^ vocabularyCache 
]

{ #category : 'accessing' }
CooSession >> vocabularyCache: aCache [

	vocabularyCache := aCache
]
