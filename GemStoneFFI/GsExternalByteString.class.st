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
GsExternalByteString >> asByteString [ 

^ ByteString withAll: (self copyUpTo: Character null)

]

{ #category : #accessing }
GsExternalByteString >> sizeNoNull [

^size - 1
]
