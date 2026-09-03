Class {
	#name : 'HistoryPopulator',
	#superclass : 'Object',
	#instVars : [
		'scrapper'
	],
	#category : 'ExtendedHeuristicCompletion-History-Fetching-Github',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'Fetching-Github'
}

{ #category : 'examples' }
HistoryPopulator class >> repositoryNamed: aURLString [

	^ self new
		  scrapper: (HistoryScrapper repositoryNamed: aURLString);
		  yourself
]

{ #category : 'accessing' }
HistoryPopulator >> scrapper [
	^ scrapper
]

{ #category : 'accessing' }
HistoryPopulator >> scrapper: aHistoryScrapper [
	scrapper := aHistoryScrapper
]
