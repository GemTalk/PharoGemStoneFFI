"
A pool variable used to represent various C types used by the GCI.
"
Class {
	#name : #GciTypes,
	#superclass : #Object,
	#classVars : [
		'BoolType',
		'CharArray1025',
		'OopType',
		'OopTypeArray10'
	],
	#category : #GemStoneFFI
}

{ #category : #'class initialization' }
GciTypes class >> initialize [
"GciTypes initialize"
	OopType := #uint64 .
	OopTypeArray10 := FFIArray newArrayTypeOf: #uint64 size: 10.
	CharArray1025 := FFIArray newArrayTypeOf: #char size: 1025 . 
	BoolType := #int32 .
]
