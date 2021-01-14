Class {
	#name : #GsMemoryTracker,
	#superclass : #OrderedCollection,
	#category : #GemStoneFFI
}

{ #category : #'as yet unclassified' }
GsMemoryTracker >> freeAll [

self do:[:e| e free ].
self removeAll
]
