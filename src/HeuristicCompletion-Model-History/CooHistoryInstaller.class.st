Class {
	#name : 'CooHistoryInstaller',
	#superclass : 'Object',
	#classVars : [
		'Current'
	],
	#category : 'HeuristicCompletion-Model-History-History-Fetcher',
	#package : 'HeuristicCompletion-Model-History',
	#tag : 'History-Fetcher'
}

{ #category : 'actions' }
CooHistoryInstaller class >> deinstallSessionHeuristics [
	"self installSessionHeuristics"

	<script>
	| engine builder |
	builder := CoASTHeuristicsResultSetBuilder new.
	engine := CoCompletionEngine new.
	engine completionBuilder: builder.
	RubSmalltalkEditor completionEngineInstance: engine
]

{ #category : 'actions' }
CooHistoryInstaller class >> install [

	<script>
	CooTemporalHistorySession install.
	self installSessionHeuristics 
]

{ #category : 'actions' }
CooHistoryInstaller class >> installSessionHeuristics [
	"self installSessionHeuristics"

	<script>
	| engine builder heuBuilder newElement |
	builder := CoASTHeuristicsResultSetBuilder new.


	"For messages"
	heuBuilder := CoHeuristicBuilder new.
	newElement := heuBuilder
		              add: CooSessionMessagesHeuristic new;
		              build.
	newElement next: builder messageHeuristic.
	builder messageHeuristic: newElement.

	"For variables"
	heuBuilder := CoHeuristicBuilder new.
	newElement := heuBuilder
		              add: CooSessionVariableHeuristic new;
		              build.
	newElement next: builder variablesHeuristic.
	builder variablesHeuristic: newElement.

	engine := CoCompletionEngine new.
	engine completionBuilder: builder.

	RubSmalltalkEditor completionEngineInstance: engine
]

{ #category : 'actions' }
CooHistoryInstaller class >> installSessionHeuristicsAsStatistical [
	"self installSessionHeuristicsAsStatistical"

	<script>
	| engine builder heuBuilder newElement |
	builder := CoASTHeuristicsResultSetBuilder new.


	"For messages"
	heuBuilder := CoHeuristicBuilder new.
	newElement := heuBuilder
		              add: (CooSessionMessagesHeuristic new sessionClass: CooStatisticalHistorySession; yourself);
		              build.
	newElement next: builder messageHeuristic.
	builder messageHeuristic: newElement.

	"For variables"
	heuBuilder := CoHeuristicBuilder new.
	newElement := heuBuilder
		              add: (CooSessionMessagesHeuristic new sessionClass: CooStatisticalHistorySession; yourself);
		              build.
	newElement next: builder variablesHeuristic.
	builder variablesHeuristic: newElement.

	engine := CoCompletionEngine new.
	engine completionBuilder: builder.

	RubSmalltalkEditor completionEngineInstance: engine
]

{ #category : 'actions' }
CooHistoryInstaller class >> loadHistoryIfPresent [ 

    <script>
    CooTemporalHistorySession current loadFromDefaultFile
]

{ #category : 'actions' }
CooHistoryInstaller class >> saveHistoryNow [ 

    <script>
    CooTemporalHistorySession current saveToDefaultFile
]
