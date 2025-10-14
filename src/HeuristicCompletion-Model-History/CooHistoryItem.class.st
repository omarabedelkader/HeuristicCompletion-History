Class {
	#name : 'CooHistoryItem',
	#superclass : 'Object',
	#instVars : [
		'name',
		'kind',
		'count',
		'firstSeen',
		'lastSeen',
		'packages',
		'classes'
	],
	#category : 'HeuristicCompletion-Model-History-History-Fetcher',
	#package : 'HeuristicCompletion-Model-History',
	#tag : 'History-Fetcher'
}

{ #category : 'accessing' }
CooHistoryItem >> classes [

	^ classes
]

{ #category : 'accessing' }
CooHistoryItem >> classes: anObject [

	classes := anObject
]

{ #category : 'accessing' }
CooHistoryItem >> count [

	^ count
]

{ #category : 'accessing' }
CooHistoryItem >> count: anObject [

	count := anObject
]

{ #category : 'accessing' }
CooHistoryItem >> firstSeen [

	^ firstSeen
]

{ #category : 'accessing' }
CooHistoryItem >> firstSeen: anObject [

	firstSeen := anObject
]

{ #category : 'initialization' }
CooHistoryItem >> initialize [

    super initialize.
    count := 0.
    packages := Set new.
    classes := Set new.
]

{ #category : 'accessing' }
CooHistoryItem >> kind [

	^ kind
]

{ #category : 'accessing' }
CooHistoryItem >> kind: anObject [

	kind := anObject
]

{ #category : 'accessing' }
CooHistoryItem >> lastSeen [

	^ lastSeen
]

{ #category : 'accessing' }
CooHistoryItem >> lastSeen: anObject [

	lastSeen := anObject
]

{ #category : 'accessing' }
CooHistoryItem >> name [

	^ name
]

{ #category : 'accessing' }
CooHistoryItem >> name: anObject [

	name := anObject
]

{ #category : 'accessing' }
CooHistoryItem >> packages [

	^ packages
]

{ #category : 'accessing' }
CooHistoryItem >> packages: anObject [

	packages := anObject
]

{ #category : 'printing' }
CooHistoryItem >> printOn: aStream [

	super printOn: aStream.
	name ifNotNil: [ aStream << '('; << name; <<')' ]
]

{ #category : 'initialization' }
CooHistoryItem >> scoreAt: now withWeights: weights halfLifeDays: halfDays inPackage: pkgName inClass: className [ 

    "Score = w_recency * exp(-ln(2) * age/halfLife) + w_freq * ln(count+1) + small context bonuses."
    | ageSec halfSec recencyScore freqScore pkgBonus classBonus |
    lastSeen ifNil: [ ^ 0 ].
    ageSec := (now - lastSeen) asSeconds asFloat.
    halfSec := (halfDays asFloat max: 0.001) * 24 * 60 * 60.
    recencyScore := (2.0 raisedTo: (ageSec / halfSec) negated). "== exp(-ln2 * age/half)"
    freqScore := ((count + 1) ln).

    pkgBonus := (pkgName notNil and: [ packages includes: pkgName ]) ifTrue: [ 0.15 ] ifFalse: [ 0.0 ].
    classBonus := (className notNil and: [ classes includes: className ]) ifTrue: [ 0.10 ] ifFalse: [ 0.0 ].

    ^ ((weights at: #recency ifAbsent: [ 0.4 ]) * recencyScore)
    + ((weights at: #frequency ifAbsent: [ 0.6 ]) * freqScore)
    + pkgBonus + classBonus
]

{ #category : 'initialization' }
CooHistoryItem >> touchAt: aDateAndTime package: pkgName class: className [ 

    count := count + 1.
    lastSeen := aDateAndTime.
    firstSeen ifNil: [ firstSeen := aDateAndTime ].
    pkgName ifNotNil: [ packages add: pkgName ].
    className ifNotNil: [ classes add: className ].
]
