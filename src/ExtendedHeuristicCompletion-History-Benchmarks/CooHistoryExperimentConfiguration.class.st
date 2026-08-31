"
I describe one project-level History experiment.
"
Class {
	#name : 'CooHistoryExperimentConfiguration',
	#superclass : 'Object',
	#instVars : [
		'name',
		'repository',
		'numberOfCommits',
		'loader',
		'outputDirectory',
		'packageNamePrefix',
		'packageNames'
	],
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks'
}

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> microdown [

	^ self new
		  name: 'Microdown';
		  repository: 'git@github.com:pillar-markup/Microdown.git';
		  numberOfCommits: 15;
		  packageNamePrefix: 'Microdown';
		  loader: [
			  Smalltalk globals
				  at: #BaselineOfMicrodown
				  ifPresent: [ :class | class removeFromSystem ].

			  Metacello new
				  baseline: 'Microdown';
				  repository: 'github://pillar-markup/Microdown:v2.9.3/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load: #( 'All' ) ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Microdown';
		  yourself
]

{ #category : 'private' }
CooHistoryExperimentConfiguration >> allPackages [

	| organizer allPackages |
	organizer := PackageOrganizer default.
	allPackages := OrderedCollection new.

	(organizer respondsTo: #packages)
		ifTrue: [ allPackages addAll: organizer packages ]
		ifFalse: [
			(organizer respondsTo: #packagesDo:)
				ifTrue: [
					organizer packagesDo: [ :package |
						allPackages add: package ] ] ].

	^ allPackages
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> benchmarkScope [

	^ CooHistoryBenchmarkScope
		  named: self name
		  packages: self packages
]

{ #category : 'initialization' }
CooHistoryExperimentConfiguration >> initialize [

	super initialize.
	numberOfCommits := 0.
	loader := [  ].
	packageNames := #(  )
]

{ #category : 'running' }
CooHistoryExperimentConfiguration >> loadProject [

	^ loader value
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> loader [

	^ loader
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> loader: aBlock [

	loader := aBlock
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> name [

	^ name
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> name: aString [

	name := aString
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> numberOfCommits [

	^ numberOfCommits
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> numberOfCommits: anInteger [

	numberOfCommits := anInteger
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> outputDirectory [

	^ outputDirectory
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> outputDirectory: aFileReference [

	outputDirectory := aFileReference
]

{ #category : 'private' }
CooHistoryExperimentConfiguration >> packageNamed: aString [

	^ [ PackageOrganizer default packageNamed: aString ]
		  on: Error
		  do: [ :exception | nil ]
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> packageNamePrefix [

	^ packageNamePrefix
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> packageNamePrefix: aString [

	packageNamePrefix := aString
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> packageNames [

	^ packageNames
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> packageNames: aCollection [

	packageNames := aCollection asArray
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> packages [

	| selected |
	packageNames ifNotNil: [
		packageNames isEmpty
			ifFalse: [ ^ self packagesNamed: packageNames ] ].

	packageNamePrefix ifNil: [ ^ #(  ) ].
	selected := self allPackages select: [ :package |
		            package name asString beginsWith: packageNamePrefix ].
	^ selected asArray
]

{ #category : 'private' }
CooHistoryExperimentConfiguration >> packagesNamed: aCollection [

	| selected |
	selected := OrderedCollection new.
	aCollection do: [ :packageName |
		| package |
		package := self packageNamed: packageName.
		package ifNotNil: [ selected add: package ] ].
	^ selected asArray
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> repository [

	^ repository
]

{ #category : 'accessing' }
CooHistoryExperimentConfiguration >> repository: aString [

	repository := aString
]
