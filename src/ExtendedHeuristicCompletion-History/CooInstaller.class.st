Class {
	#name : 'CooInstaller',
	#superclass : 'Object',
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'as yet unclassified' }
CooInstaller >> installSessionInSystem [
	self halt.
		"this is the old code from an old image"
	"self installSessionInSystem"
	
	"| engine builder heuBuilder  newElement |
	engine := CoCompletionEngine new.
	
	builder := CoASTHeuristicsResultSetBuilder new. 
	heuBuilder := CoHeuristicBuilder new. 
	newElement := heuBuilder add: CoSessionMessagesHeuristic new; build.
	newElement next: builder messageHeuristic.
	engine completionBuilder: ( builder messageHeuristic: newElement ).  

	RubSmalltalkEditor completionEngineInstance: engine.
	RubSmalltalkEditor allInstances do: [ :each | each completionEngine: engine ].
	"
]

{ #category : 'as yet unclassified' }
CooInstaller >> whereToHookInToGetEntries [

	self halt just move the caret "
	When we will want to know what the user saw and selected. ...
	
	The following method contains the full information: the selected item (entry) and the entries found by the 
	engine.
	
	activateEntryAt: anIndex

	| entry |
	self halt.
	entry := (self entries at: anIndex).
	entry activateOn: self.
	^ entry
	
	
	
	
	In this method the completion menu is built (in the drawLine....)
	
	handleKeyDownBefore: aKeyboardEvent editor: anEditor
	
	| key controlKeyPressed commandKeyPressed |
	self setEditor: anEditor.
	key := aKeyboardEvent key.
	controlKeyPressed := aKeyboardEvent controlKeyPressed.
	commandKeyPressed := aKeyboardEvent commandKeyPressed.

	(self isMenuOpen not and: [
		 self editor atCompletionPosition and: [
			 NECPreferences popupShowWithShortcut matches: { aKeyboardEvent } ] ])
		ifTrue: [
			aKeyboardEvent supressNextKeyPress: true.
			self openMenu.
			^ true ].

	key = KeyboardKey backspace ifTrue: [
		self smartBackspace ifTrue: [ ^ true ] ].

	self isMenuOpen ifFalse: [ ^ false ].

	({
		 KeyboardKey left.
		 KeyboardKey right.
		 KeyboardKey keypadLeft.
		 KeyboardKey keypadRight } includes: key) ifTrue: [ " "
		^ false ].

	({
		 KeyboardKey up.
		 KeyboardKey keypadUp } includes: key) ifTrue: [
		menuMorph moveUp.
		^ true ].
	({
		 KeyboardKey down.
		 KeyboardKey keypadDown } includes: key) ifTrue: [
		menuMorph moveDown.
		^ true ].
	key = KeyboardKey pageUp ifTrue: [
		menuMorph pageUp.
		^ true ].
	key = KeyboardKey pageDown ifTrue: [
		menuMorph pageDown.
		^ true ].
	((key = KeyboardKey enter or: [ key = KeyboardKey keypadEnter ])
		 and: [ NECPreferences useEnterToAccept ]) ifTrue: [
		menuMorph insertSelected ifTrue: [ ^ true ] ].
	key = KeyboardKey tab ifTrue: [
		menuMorph insertSelected ifTrue: [ ^ true ] ].
	key = KeyboardKey backspace ifTrue: [
		editor isCaretBehindChar ifFalse: [ self closeMenu ].
		^ false ].
	key = KeyboardKey escape ifTrue: [
		self closeMenu.
		^ true ].
	^ false"
]
