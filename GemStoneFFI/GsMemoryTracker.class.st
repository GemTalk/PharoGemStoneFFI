"
A simple OrderedCollection used to track memroy alllocated on the C-heap by the GemStoneFFI.

The #freeAll message frees all memory in the receiver and empties the collection.
"
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
