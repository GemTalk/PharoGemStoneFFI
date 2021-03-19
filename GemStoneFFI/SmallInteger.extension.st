Extension { #name : 'SmallInteger' }

{ #category : '*GemStoneFFI' }
SmallInteger >> asGemStoneOop [
"666 asGemStoneOop"
^(self bitShift: GciInterface OOP_NUM_TAG_BITS) bitOr: GciInterface OOP_TAG_SMALLINT 
]
