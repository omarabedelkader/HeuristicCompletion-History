Class {
	#name : 'CooSession',
	#superclass : 'Object',
	#instVars : [
		'cache'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-Session',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Session'
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

	cache addModifiedMethodInVocabulary: anAnn 
]

{ #category : 'adding' }
CooSession >> addNewMethodInVocabulary: anAnn [

	cache addNewMethodInVocabulary: anAnn
]

{ #category : 'adding' }
CooSession >> addNewVariableInVocabulary: aClassAdded [ 
	cache addNewVariableInVocabulary: aClassAdded
]

{ #category : 'accessing' }
CooSession >> cache [
	^ cache 
]

{ #category : 'initialization' }
CooSession >> initialize [ 
	super initialize.
	cache := CooTemporalCache new.
]

{ #category : 'adding' }
CooSession >> removeMethodFromVocabulary: aMethodRemovedAnnouncement [ 

	cache removeMethodFromVocabulary: aMethodRemovedAnnouncement 
]

{ #category : 'adding' }
CooSession >> removeVariableFromVocabulary: aClassRemoved [ 
	cache removeVariableFromVocabulary: aClassRemoved 
]

{ #category : 'matching' }
CooSession >> selectors [
	
	^ cache selectors
]

{ #category : 'matching' }
CooSession >> variableNames [
	^ cache variableNames
]

{ #category : 'accessing' }
CooSession >> vocabularyCache [
	^ cache 
]

{ #category : 'accessing' }
CooSession >> vocabularyCache: aCache [

	cache := aCache
]
