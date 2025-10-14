"
I implement a session that collects execution information.
I collect the last words in modified methods.
"
Class {
	#name : 'CooStatisticalHistorySession',
	#superclass : 'Object',
	#instVars : [
		'vocabularyCache',
		'history',
		'weights',
		'halfLifeDays'
	],
	#classVars : [
		'Current'
	],
	#category : 'ExtendedHeuristicCompletion-History-History-Fetcher',
	#package : 'ExtendedHeuristicCompletion-History',
	#tag : 'History-Fetcher'
}

{ #category : 'actions' }
CooStatisticalHistorySession class >> current [ 

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'actions' }
CooStatisticalHistorySession class >> deinstall [
	<script>
	
	self environment codeChangeAnnouncer unsubscribe: self current.
	CooTemporalHistorySession allInstances 
		do: [ :each | self environment codeChangeAnnouncer unsubscribe: each ]
]

{ #category : 'actions' }
CooStatisticalHistorySession class >> install [
	<script>
	
	self environment codeChangeAnnouncer
		when: MethodAdded
		send: #addNewMethodInVocabulary: 
		to: self current.
	"
	This does not work for now because we are expecting a node and the menu does not give us a node
	in addition we do not get the."
	"self environment codeChangeAnnouncer
		when: CompletionItemSelected
		send: #addMessageInVocabulary: 
		to: self current."
]

{ #category : 'actions' }
CooStatisticalHistorySession class >> reset [
	<script>
	Current ifNotNil: [ 
		self environment codeChangeAnnouncer
			unsubscribe: Current.
	Current := nil ]
]

{ #category : 'vocabulary' }
CooStatisticalHistorySession >> addNewMethodInVocabulary: anAnn [

	vocabularyCache add: anAnn methodAdded selector
]

{ #category : 'vocabulary' }
CooStatisticalHistorySession >> addVocabulary: aString at: aDateAndTime [

	vocabularyCache at: aString put: aDateAndTime
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> completionSelected: anEntry in: aCompletionContext [ 

    "Record that a completion item was activated by the user."
    | nm kind pkgName clsName now item |
    nm := anEntry contents.
    kind := (anEntry isKindOf: NECSelectorEntry)
        ifTrue: [ #message ]
        ifFalse: [ #global ].

    pkgName := (aCompletionContext completionClass ifNotNil: [ :c | c package name ]) ifNil: [ nil ].
    clsName := (aCompletionContext completionClass ifNotNil: [ :c | c name ]) ifNil: [ nil ].

    now := DateAndTime now.
    item := self history at: nm ifAbsentPut: [
        CooHistoryItem new
            name: nm;
            kind: kind;
            yourself ].
    "Normalize kind if we learn more (e.g., first time was #global, later we see a selector)"
    (item kind ~= kind and: [ item kind isNil ])
        ifTrue: [ item kind: kind ].

    item touchAt: now package: pkgName class: clsName.
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> defaultWeights [ 

    "Tuneable weights for scoring."
    ^ weights ifNil: [ weights := { #recency -> 0.4. #frequency -> 0.6 } asDictionary ]
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> globalEntriesForPrefix: prefix limit: k inContext: aCompletionContext [ 

    "Return NECGlobalEntry instances ranked by history."
    ^ (self globalsMatching: prefix limit: k inContext: aCompletionContext)
        collect: [ :it | NECGlobalEntry contents: it name node: nil ]
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> globalsMatching: prefix limit: k inContext: aCompletionContext [ 

    | now pkgName clsName matches |
    now := DateAndTime now.
    pkgName := (aCompletionContext completionClass ifNotNil: [ :c | c package name ]) ifNil: [ nil ].
    clsName := (aCompletionContext completionClass ifNotNil: [ :c | c name ]) ifNil: [ nil ].

    matches := self history values
        select: [ :it | it kind = #global and: [ it name beginsWith: prefix ] ].

    ^ (matches
        asSortedCollection: [ :a :b |
            (a scoreAt: now withWeights: self defaultWeights halfLifeDays: self halfLifeDays inPackage: pkgName inClass: clsName)
                >
            (b scoreAt: now withWeights: self defaultWeights halfLifeDays: self halfLifeDays inPackage: pkgName inClass: clsName) ])
        first: (k min: matches size)
]

{ #category : 'accessing' }
CooStatisticalHistorySession >> history [ 

    ^ history ifNil: [ history := Dictionary new ]
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> initialize [

	super initialize.
	vocabularyCache := Bag new.

]

{ #category : 'file in/out' }
CooStatisticalHistorySession >> loadFromDefaultFile [ 

    | ref file dict |
    ref := FileLocator imageDirectory / 'coo-history.ston'.
    ref exists ifFalse: [ ^ self ].
    file := ref readStream.
    [ dict := STON fromStream: file ] ensure: [ file close ].
    dict do: [ :assoc |
        | d item |
        d := assoc.
        item := CooHistoryItem new
            name: (d at: #name);
            kind: (d at: #kind ifAbsent: [ #message ]);
            yourself.
        item
            instVarNamed: #count put: (d at: #count ifAbsent: [ 1 ]);
            instVarNamed: #firstSeen put: (d at: #firstSeen ifAbsent: [ nil ]);
            instVarNamed: #lastSeen put: (d at: #lastSeen ifAbsent: [ nil ]).
        item packages addAll: (d at: #packages ifAbsent: [ #() ]).
        item classes addAll: (d at: #classes ifAbsent: [ #() ]).
        self history at: item name put: item ].
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> messageEntriesForPrefix: prefix limit: k inContext: aCompletionContext [ 

    "Return NECSelectorEntry instances ranked by history."
    ^ (self selectorsMatching: prefix limit: k inContext: aCompletionContext)
        collect: [ :it | NECSelectorEntry contents: it name node: nil ]
]

{ #category : 'file in/out' }
CooStatisticalHistorySession >> saveToDefaultFile [ 

    | file ref dict |
    ref := FileLocator imageDirectory / 'coo-history.ston'.
    dict := self history collect: [ :item |
        {
            #name -> item name.
            #kind -> item kind.
            #count -> item count.
            #firstSeen -> item firstSeen.
            #lastSeen -> item lastSeen.
            #packages -> item packages asArray.
            #classes -> item classes asArray
        } asDictionary ].
    file := ref ensureCreateFile; writeStream.
    [ STON put: dict onStream: file ] ensure: [ file close ].
]

{ #category : 'initialization' }
CooStatisticalHistorySession >> selectorsMatching: prefix limit: k inContext: aCompletionContext [
	"Return the best matching message names by score."

	| matching |
	matching := Bag new.
	vocabularyCache keysAndValuesDo: [ :sel :count |
			(sel beginsWith: prefix) ifTrue: [
				count timesRepeat: [ matching add: sel ] ] ].
	^ (matching sortedElements collect: [ :each |   CooHistoryItem new name: each key; yourself ]) "first:
		  (k min: matching size)"
]

{ #category : 'accessing' }
CooStatisticalHistorySession >> size [
	^ vocabularyCache size
]

{ #category : 'accessing' }
CooStatisticalHistorySession >> words [

	^ vocabularyCache keys
]
