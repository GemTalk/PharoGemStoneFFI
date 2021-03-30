Class {
	#name : #GsExternalByteStringTest,
	#superclass : #GemStoneFFITestCase,
	#category : #'GemStoneFFI-Tests'
}

{ #category : #tests }
GsExternalByteStringTest >> testNewFromByteString [
 |  srcStr str |
	srcStr := 'abc' .
	str := GsExternalByteString newFromByteString: srcStr.
	[ self assert: str class identicalTo: GsExternalByteString ;
		 	assert: str size equals: (srcStr size + 1) ;
			assert: str sizeNoNull equals: srcStr size ;
			assert: str asByteString equals: srcStr 
		] ensure:[ str free ].
	^self
]

{ #category : #tests }
GsExternalByteStringTest >> testNewWithNull [

 | sz str |
	sz := 16 .
	str := GsExternalByteString newWithNull: sz.
	[ self assert: str class identicalTo: GsExternalByteString ;
		 assert: str size equals: (sz + 1) ] ensure:[ str free ].
	^self
]
