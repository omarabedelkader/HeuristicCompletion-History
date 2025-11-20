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
	self environment codeChangeAnnouncer when: MethodRemoved send: #removeMethodFromVocabulary: to: self current
]

{ #category : 'instance creation' }
CooSession class >> withCache: aCache [

	^ self current vocabularyCache: aCache
]

{ #category : 'accessing' }
CooSession >> vocabularyCache: aCache [

	vocabularyCache := aCache
]
