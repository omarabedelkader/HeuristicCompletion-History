"
I group the packages that form one project-level benchmark scope.
"
Class {
	#name : 'CooHistoryBenchmarkScope',
	#superclass : 'Object',
	#instVars : [
		'name',
		'packages'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'instance creation' }
CooHistoryBenchmarkScope class >> named: aString packages: aCollection [

	^ self new
		  name: aString;
		  packages: aCollection;
		  yourself
]

{ #category : 'accessing' }
CooHistoryBenchmarkScope >> definedClasses [

	^ ((self packages flatCollect: [ :package |
		    (package respondsTo: #definedClasses)
			    ifTrue: [ package definedClasses ]
			    ifFalse: [ #(  ) ] ]) asSet) asArray
]

{ #category : 'enumerating' }
CooHistoryBenchmarkScope >> do: aBlock [

	self packages do: aBlock
]

{ #category : 'enumerating' }
CooHistoryBenchmarkScope >> methodsDo: aBlock [

	self packages do: [ :package |
		(package respondsTo: #methodsDo:)
			ifTrue: [ package methodsDo: aBlock ]
			ifFalse: [
				(package respondsTo: #methods)
					ifTrue: [ package methods do: aBlock ] ] ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkScope >> name [

	^ name
]

{ #category : 'accessing' }
CooHistoryBenchmarkScope >> name: aString [

	name := aString
]

{ #category : 'accessing' }
CooHistoryBenchmarkScope >> packages [

	^ packages ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
CooHistoryBenchmarkScope >> packages: aCollection [

	packages := aCollection asArray
]

{ #category : 'printing' }
CooHistoryBenchmarkScope >> printOn: aStream [

	super printOn: aStream.
	aStream
		space;
		nextPutAll: self name;
		nextPutAll: ' packages ';
		print: self packages size
]

{ #category : 'accessing' }
CooHistoryBenchmarkScope >> size [

	^ self packages size
]
