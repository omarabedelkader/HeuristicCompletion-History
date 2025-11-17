Class {
	#name : 'HistoryMockTranscript',
	#superclass : 'Object',
	#instVars : [
		'stream'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests-Github-Scrapper-Mock',
	#package : 'ExtendedHeuristicCompletion-History-Tests',
	#tag : 'Github-Scrapper-Mock'
}

{ #category : 'streaming' }
HistoryMockTranscript >> contents [
    ^ stream contents
]

{ #category : 'streaming' }
HistoryMockTranscript >> cr [
    stream nextPut: Character cr
]

{ #category : 'streaming' }
HistoryMockTranscript >> initialize [
    super initialize.
    stream := WriteStream on: String new
]

{ #category : 'streaming' }
HistoryMockTranscript >> show: aString [
    stream nextPutAll: aString
]
