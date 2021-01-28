"
A class used to represent a C null-terminated ASCII string. instances are allocated on the C heap and must be freed.
"
Class {
	#name : #GsExternalByteString,
	#superclass : #FFIExternalArray,
	#category : #GemStoneFFI
}

{ #category : #'instance creation' }
GsExternalByteString class >> new [

"Use new: or newWithNull:"
^self shouldNotImplement 
]

{ #category : #'instance creation' }
GsExternalByteString class >> new: aSize [
"Create a new external C string object from aByteString. Caller must free the result.
Does NOT allocate an extra byte for the NULL character. Don't do that here, it breaks things!
Call newWithNull: if you want space for a NULL included in the size."

^ self externalNewType: 'char' size: aSize

]

{ #category : #'instance creation' }
GsExternalByteString class >> newFromByteString: aByteString [
"Create a new external C string object from aByteString. Caller must free the result."
| sz result |
sz := aByteString size.
result := self newWithNull: sz.
1 to: sz do:[:n| result at: n put: (aByteString at: n)].
result at: (sz + 1) put: Character null.
^result
]

{ #category : #'instance creation' }
GsExternalByteString class >> newWithNull: aSize [
"Create a new external C ByteString that has room for aSize bytes and a terminating NULL character. Caller must free the result."

^ self new: (aSize + 1)

]

{ #category : #converting }
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

{ #category : #converting }
GsExternalByteString >> asByteString [ 

^ ByteString withAll: (self copyUpTo: Character null)

]

{ #category : #accessing }
GsExternalByteString >> sizeNoNull [

^size - 1
]
