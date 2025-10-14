Class {
	#name : 'CooHistoryItemTest',
	#superclass : 'CoMiniTestCase',
	#instVars : [
		'cls'
	],
	#category : 'ExtendedHeuristicCompletion-History-Tests',
	#package : 'ExtendedHeuristicCompletion-History-Tests'
}

{ #category : 'tests' }
CooHistoryItemTest >> testContextBonus [ 

    | item now w baseScore bonusScore |
    now := DateAndTime now.
    item := CooHistoryItem new.
    item touchAt: now package: 'Pkg' class: 'Foo'.
    w := { #recency -> 0.5. #frequency -> 0.5 } asDictionary.
    baseScore := item scoreAt: now withWeights: w halfLifeDays: 1 inPackage: nil inClass: nil.
    bonusScore := item scoreAt: now withWeights: w halfLifeDays: 1 inPackage: 'Pkg' inClass: 'Foo'.
    self assert: bonusScore > baseScore
]

{ #category : 'tests' }
CooHistoryItemTest >> testRecencyInfluencesScore [

    | item now early w oldScore newScore |
    now := DateAndTime now.
    early := now - 2 days.
    item := CooHistoryItem new.
    item touchAt: early package: nil class: nil.
    w := { #recency -> 1.0. #frequency -> 0.0 } asDictionary.
    oldScore := item scoreAt: now withWeights: w halfLifeDays: 1 inPackage: nil inClass: nil.
    item touchAt: now package: nil class: nil.
    newScore := item scoreAt: now withWeights: w halfLifeDays: 1 inPackage: nil inClass: nil.
    self assert: newScore > oldScore
]

{ #category : 'tests' }
CooHistoryItemTest >> testScoreIncreaseWithFrequency [ 

    | item now w s1 s2 |
    now := DateAndTime now.
    item := CooHistoryItem new.
    item touchAt: now package: nil class: nil.
    w := { #recency -> 0.5. #frequency -> 0.5 } asDictionary.
    s1 := item scoreAt: now withWeights: w halfLifeDays: 1 inPackage: nil inClass: nil.
    item touchAt: now package: nil class: nil.
    s2 := item scoreAt: now withWeights: w halfLifeDays: 1 inPackage: nil inClass: nil.
    self assert: s2 > s1

]
