"
A class used to represent a C null-terminated ASCII string. instances are allocated on the C heap and must be freed.
"
Class {
	#name : 'GsExternalByteString',
	#superclass : 'FFIExternalArray',
	#category : 'GemStoneFFI'
}

{ #category : 'instance creation' }
GsExternalByteString class >> new [

"Use new: or newWithNull:"
^self shouldNotImplement 
]

{ #category : 'instance creation' }
GsExternalByteString class >> new: aSize [
"Create a new external C string object from aByteString. Caller must free the result.
Does NOT allocate an extra byte for the NULL character. Don't do that here, it breaks things!
Call newWithNull: if you want space for a NULL included in the size."

^ self externalNewType: 'char' size: aSize

]

{ #category : 'instance creation' }
GsExternalByteString class >> newFromByteString: aByteString [
"Create a new external C string object from aByteString. Caller must free the result."
| sz result |
sz := aByteString size.
result := self newWithNull: sz.
1 to: sz do:[:n| result at: n put: (aByteString at: n)].
result at: (sz + 1) put: Character null.
^result
]

{ #category : 'instance creation' }
GsExternalByteString class >> newWithNull: aSize [
"Create a new external C ByteString that has room for aSize bytes and a terminating NULL character. Caller must free the result."

^ self new: (aSize + 1)

]

{ #category : 'converting' }
GsExternalByteString >> asByteArrayOfSize: aSize [
"Used to extract data from a C buffer into a ByteArray. aSize is the amount of valid data in the buffer and must be less than
or equal to the size of the C buffer (self size)"
| result |
aSize > self size
	ifTrue:[ ^self error: ('Attempt to create a ByteArray larger than my size (', aSize asString , ' > ', self size asString, ')' ) ].
result := ByteArray new: aSize.
1 to: aSize do:[:e| result at: e put: (self at: e) asInteger].
^result 

]

{ #category : 'converting' }
GsExternalByteString >> asByteString [

	"If I am null-terminated, answer a ByteString containing my bytes up to the first null. 
	Otherwise, answer a ByteString with my full contents.
	This is done byte-wise and may well do the wrong thing for code points > 127."

	| stream null |
	stream := WriteStream on: (ByteString new: size).
	null := Character null.
	self do: [ :each | 
		each = null
			ifTrue: [ ^ stream contents ]
			ifFalse: [ stream nextPut: each ] ].
	^ stream contents
]

{ #category : 'converting' }
GsExternalByteString >> asByteStringOfSize: requestedSize [

	"Answer a ByteString of the lesser size of my size or the given size,
	containing my bytes up to that size.
	This is done byte-wise and may well do the wrong thing for code points > 127."

	| resultSize result |
	resultSize := requestedSize min: self size.
	result := ByteString new: resultSize.
	1 to: resultSize do: [ :i | result at: i put: (self at: i) ].
	^ result
]

{ #category : 'accessing' }
GsExternalByteString >> sizeNoNull [

^size - 1
]
