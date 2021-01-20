"
A class used to represent a C null-terminated ASCII string. instances are allocated on the C heap and must be freed.
"
Class {
	#name : #GsExternalByteString,
	#superclass : #FFIExternalArray,
	#category : #GemStoneFFI
}

{ #category : #'instance creation' }
GsExternalByteString class >> new: aSize [
"Create a new external C string object from aByteString. Caller must free the result."

^ self externalNewType: 'char' size: (aSize + 1)

]

{ #category : #'instance creation' }
GsExternalByteString class >> newFromByteString: aByteString [
"Create a new external C string object from aByteString. Caller must free the result."
| sz result |
sz := aByteString size.
result := self externalNewType: 'char' size: (sz + 1).
1 to: sz do:[:n| result at: n put: (aByteString at: n)].
result at: (sz + 1) put: Character null.
^result
]

{ #category : #converting }
GsExternalByteString >> asByteString [ 
	
	^ ByteString withAll:  ((ReadStream on: self) upTo: Character null)
	
]

{ #category : #accessing }
GsExternalByteString >> sizeNoNull [

^size - 1
]
