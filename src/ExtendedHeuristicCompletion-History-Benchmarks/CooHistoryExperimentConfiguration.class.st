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
	#category : 'ExtendedHeuristicCompletion-History-Benchmarks-Core',
	#package : 'ExtendedHeuristicCompletion-History-Benchmarks',
	#tag : 'Core'
}

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> microdown [

	^ self new
		  name: 'Microdown';
		  repository: 'git@github.com:pillar-markup/Microdown.git';
		  numberOfCommits: 200;
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

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> roassal [

    ^ self new
        name: 'Roassal';
        repository: 'git@github.com:pharo-graphics/Roassal.git';
        numberOfCommits: 200;
        packageNamePrefix: 'Roassal';
        loader: [
            Metacello new
                baseline: 'Roassal';
                repository: 'github://pharo-graphics/Roassal:Pharo13';
                load: 'Full' ];
        outputDirectory:
            FileLocator workingDirectory
                / 'History-Bench-Results'
                / 'Roassal';
        yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> testRepoForHistory [
	
	^ self new
		  name: 'test-repo-for-history';
		  repository: 'git@github.com:omarabedelkader/test-repo-for-history.git';
		  numberOfCommits: 4;
		  packageNamePrefix: 'MyCounter';
		  loader: [ 
			  Metacello new
				  baseline: 'MyCounter';
				  repository: 'github://omarabedelkader/test-repo-for-history:main/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'MyCounter';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> druid [

	^ self new
		  name: 'Druid';
		  repository: 'git@github.com:Alamvic/druid.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Druid';
		  loader: [
			  Metacello new
				  baseline: 'Druid';
				  repository: 'github://Alamvic/druid:main';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load: 'Core' ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Druid';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> fame [

	^ self new
		  name: 'Fame';
		  repository: 'git@github.com:moosetechnology/Fame.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Fame';
		  loader: [
			  Metacello new
				  baseline: 'Fame';
				  repository: 'github://moosetechnology/Fame:development/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Fame';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> famix [

	^ self new
		  name: 'FAMIX';
		  repository: 'git@github.com:moosetechnology/Famix.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Famix';
		  loader: [
			  Metacello new
				  baseline: 'Famix';
				  repository: 'github://moosetechnology/Famix:development/src';
				  onConflict: [ :exception | exception allow ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'FAMIX';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> fastPython [

	^ self new
		  name: 'FASTPython';
		  repository: 'git@github.com:moosetechnology/FAST-Python.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'FAST-Python';
		  loader: [
			  Metacello new
				  baseline: 'FASTPython';
				  repository: 'github://moosetechnology/FAST-Python:main/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'FASTPython';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> fastTypescript [

	^ self new
		  name: 'FASTTypescript';
		  repository: 'git@github.com:moosetechnology/FASTTypescript.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'FAST-TypeScript';
		  loader: [
			  Metacello new
				  baseline: 'FASTTypeScript';
				  repository: 'github://moosetechnology/FASTTypescript:main';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'FASTTypescript';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> gitProjectHealth [

	^ self new
		  name: 'GitProjectHealth';
		  repository: 'git@github.com:moosetechnology/GitProjectHealth.git';
		  numberOfCommits: 200;
		  packageNames: #(
			  'GitLabHealth-Model'
			  'GitLabHealth-Model-Analysis'
			  'GitLabHealth-Model-Importer'
			  'GitHubHealth-Model-Importer'
			  'BitBucketHealth-Model-Importer' );
		  loader: [
			  Metacello new
				  baseline: 'GitLabHealth';
				  repository: 'github://moosetechnology/GitProjectHealth:main/src';
				  onConflict: [ :exception | exception useLoaded ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  onDowngrade: [ :exception | exception useLoaded ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'GitProjectHealth';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> mooseCI [

	^ self new
		  name: 'MooseCI';
		  repository: 'git@github.com:moosetechnology/MooseCI.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'MooseCI';
		  loader: [
			  Metacello new
				  baseline: 'MooseCI';
				  repository: 'github://moosetechnology/MooseCI:master/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'MooseCI';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> bloc [

	^ self new
		  name: 'Bloc';
		  repository: 'git@github.com:pharo-graphics/Bloc.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Bloc';
		  loader: [
			  Metacello new
				  baseline: 'Bloc';
				  repository: 'github://pharo-graphics/Bloc:dev/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Bloc';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> toplo [

	^ self new
		  name: 'Toplo';
		  repository: 'git@github.com:pharo-graphics/Toplo.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Toplo';
		  loader: [
			  Metacello new
				  baseline: 'Toplo';
				  repository: 'github://pharo-graphics/Toplo:dev/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Toplo';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> polyMath [

	^ self new
		  name: 'PolyMath';
		  repository: 'git@github.com:PolyMathOrg/PolyMath.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Math-';
		  loader: [
			  Metacello new
				  baseline: 'PolyMath';
				  repository: 'github://PolyMathOrg/PolyMath:master/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'PolyMath';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> dataFrame [

	^ self new
		  name: 'DataFrame';
		  repository: 'git@github.com:PolyMathOrg/DataFrame.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'DataFrame';
		  loader: [
			  Metacello new
				  baseline: 'DataFrame';
				  repository: 'github://PolyMathOrg/DataFrame:master/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'DataFrame';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> seaside [

	^ self new
		  name: 'Seaside';
		  repository: 'git@github.com:SeasideSt/Seaside.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Seaside';
		  loader: [
			  Metacello new
				  baseline: 'Seaside3';
				  repository: 'github://SeasideSt/Seaside:master/repository';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Seaside';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> pillar [

	^ self new
		  name: 'Pillar';
		  repository: 'git@github.com:pillar-markup/pillar.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Pillar';
		  loader: [
			  Metacello new
				  baseline: 'Pillar';
				  repository: 'github://pillar-markup/pillar:dev/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Pillar';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> mooseIDE [

	^ self new
		  name: 'MooseIDE';
		  repository: 'git@github.com:moosetechnology/MooseIDE.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'MooseIDE';
		  loader: [
			  Metacello new
				  baseline: 'MooseIDE';
				  repository: 'github://moosetechnology/MooseIDE:development/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'MooseIDE';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> voyage [

	^ self new
		  name: 'Voyage';
		  repository: 'git@github.com:pharo-nosql/voyage.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'Voyage';
		  loader: [
			  Metacello new
				  baseline: 'Voyage';
				  repository: 'github://pharo-nosql/voyage:master/mc';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'Voyage';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> chatPharo [

	^ self new
		  name: 'ChatPharo';
		  repository: 'git@github.com:omarabedelkader/ChatPharo.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'AI-ChatPharo';
		  loader: [
			  Metacello new
				  baseline: 'AIChatPharo';
				  repository: 'github://omarabedelkader/ChatPharo:main/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'ChatPharo';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> pharoLauncher [

	^ self new
		  name: 'PharoLauncher';
		  repository: 'git@github.com:pharo-project/pharo-launcher.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'PharoLauncher';
		  loader: [
			  Metacello new
				  baseline: 'PharoLauncher';
				  repository: 'github://pharo-project/pharo-launcher:dev/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'PharoLauncher';
		  yourself
]

{ #category : 'instance creation' }
CooHistoryExperimentConfiguration class >> tinyLogger [

	^ self new
		  name: 'TinyLogger';
		  repository: 'git@github.com:jecisc/TinyLogger.git';
		  numberOfCommits: 200;
		  packageNamePrefix: 'TinyLogger';
		  loader: [
			  Metacello new
				  baseline: 'TinyLogger';
				  repository: 'github://jecisc/TinyLogger:v1.x.x/src';
				  onConflict: [ :exception | exception useIncoming ];
				  onUpgrade: [ :exception | exception useIncoming ];
				  load ];
		  outputDirectory:
			  FileLocator workingDirectory / 'History-Bench-Results' / 'TinyLogger';
		  yourself
]

{ #category : 'private' }
CooHistoryExperimentConfiguration >> allPackages [

	| organizer allPackages |
	organizer := PackageOrganizer default.
	allPackages := OrderedCollection new.
	allPackages addAll: organizer packages.
		
	^ allPackages
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
	"Return packages from the list of package names if given or the prefix."
	
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
		package := PackageOrganizer default  
			packageNamed: packageName 
			ifPresent: [ :p | selected add: p ] ].
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
