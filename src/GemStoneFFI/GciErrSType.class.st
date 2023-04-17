"
A representation the gci type GciErrSType C structure, used to return GemStone error information to Pharo.
Allocated on the C heap and must be freed.
"
Class {
	#name : 'GciErrSType',
	#superclass : 'FFIStructure',
	#classVars : [
		'OFFSET_ARGCOUNT',
		'OFFSET_ARGS',
		'OFFSET_CATEGORY',
		'OFFSET_CONTEXT',
		'OFFSET_EXCEPTIONOBJ',
		'OFFSET_FATAL',
		'OFFSET_MESSAGE',
		'OFFSET_NUMBER',
		'OFFSET_REASON'
	],
	#pools : [
		'GciTypes'
	],
	#category : 'GemStoneFFI'
}

{ #category : 'ffi support' }
GciErrSType class >> fieldsDesc [
^ #(
	OopType category;
	OopType context;
	OopType exceptionObj;
	OopTypeArray10 args;
	int32 number;
	int32 argCount;
	uint8 fatal;
	CharArray1025 message;
	CharArray1025 reason;
	)
]

{ #category : 'accessing structure variables' }
GciErrSType >> argCount [
	"This method was automatically generated"
	^handle signedLongAt: OFFSET_ARGCOUNT
]

{ #category : 'accessing structure variables' }
GciErrSType >> argCount: anObject [
	"This method was automatically generated"
	handle signedLongAt: OFFSET_ARGCOUNT put: anObject
]

{ #category : 'accessing structure variables' }
GciErrSType >> args [
	"This method was automatically generated"
	^(FFITypeArray ofType: #FFIUInt64 size: 10) fromHandle: (handle copyFrom: OFFSET_ARGS to: OFFSET_ARGS + 79)
]

{ #category : 'accessing structure variables' }
GciErrSType >> args: anObject [
	"This method was automatically generated"
	handle replaceFrom: OFFSET_ARGS to: OFFSET_ARGS + 79 with: anObject getHandle startingAt: 1
]

{ #category : 'accessing structure variables' }
GciErrSType >> category [
	"This method was automatically generated"
	^handle unsignedLongLongAt: OFFSET_CATEGORY
]

{ #category : 'accessing structure variables' }
GciErrSType >> category: anObject [
	"This method was automatically generated"
	handle unsignedLongLongAt: OFFSET_CATEGORY put: anObject
]

{ #category : 'accessing structure variables' }
GciErrSType >> context [
	"This method was automatically generated"
	^handle unsignedLongLongAt: OFFSET_CONTEXT
]

{ #category : 'accessing structure variables' }
GciErrSType >> context: anObject [
	"This method was automatically generated"
	handle unsignedLongLongAt: OFFSET_CONTEXT put: anObject
]

{ #category : 'accessing structure variables' }
GciErrSType >> exceptionObj [
	"This method was automatically generated"
	^handle unsignedLongLongAt: OFFSET_EXCEPTIONOBJ
]

{ #category : 'accessing structure variables' }
GciErrSType >> exceptionObj: anObject [
	"This method was automatically generated"
	handle unsignedLongLongAt: OFFSET_EXCEPTIONOBJ put: anObject
]

{ #category : 'accessing structure variables' }
GciErrSType >> fatal [
	"This method was automatically generated"
	^handle unsignedByteAt: OFFSET_FATAL
]

{ #category : 'accessing structure variables' }
GciErrSType >> fatal: anObject [
	"This method was automatically generated"
	handle unsignedByteAt: OFFSET_FATAL put: anObject
]

{ #category : 'accessing structure variables' }
GciErrSType >> message [
	"This method was automatically generated"
	"^(FFITypeArray ofType: #FFICharacterType size: 1025) fromHandle: (handle copyFrom: OFFSET_MESSAGE to: OFFSET_MESSAGE + 1024)"
	|rs |
	rs := ReadStream on: (handle copyFrom: OFFSET_MESSAGE to: OFFSET_MESSAGE + 1024) asString.
	^rs upTo: Character null

]

{ #category : 'accessing structure variables' }
GciErrSType >> message: anObject [
	"This method was automatically generated"
	handle replaceFrom: OFFSET_MESSAGE to: OFFSET_MESSAGE + 1024 with: anObject getHandle startingAt: 1
]

{ #category : 'accessing structure variables' }
GciErrSType >> number [
	"This method was automatically generated"
	^handle signedLongAt: OFFSET_NUMBER
]

{ #category : 'accessing structure variables' }
GciErrSType >> number: anObject [
	"This method was automatically generated"
	handle signedLongAt: OFFSET_NUMBER put: anObject
]

{ #category : 'accessing structure variables' }
GciErrSType >> reason [
	"This method was automatically generated"
	"^(FFITypeArray ofType: #FFICharacterType size: 1025) fromHandle: (handle copyFrom: OFFSET_REASON to: OFFSET_REASON + 1024)"
	
	|rs |
	rs := ReadStream on: (handle copyFrom: OFFSET_REASON to: OFFSET_REASON + 1024) asString.
	^rs upTo: Character null
]

{ #category : 'accessing structure variables' }
GciErrSType >> reason: anObject [
	"This method was automatically generated"
	handle replaceFrom: OFFSET_REASON to: OFFSET_REASON + 1024 with: anObject getHandle startingAt: 1
]
