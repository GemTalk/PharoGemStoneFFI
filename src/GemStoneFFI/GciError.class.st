"
The type of Exception raised by the GCI in Pharo.
 

Instance Variables
	fatal:			<Boolean> - true if the session was termianted, otherwise false.
	message:		<ByteString> - error message from GemStone.
	number:		<SmallInteger> - GemStone error number.
	reason:		<ByteString> - additional information about the error. Maybe empty or nil.

"
Class {
	#name : 'GciError',
	#superclass : 'Error',
	#instVars : [
		'number',
		'fatal',
		'message',
		'reason'
	],
	#category : 'GemStoneFFI',
	#package : 'GemStoneFFI'
}

{ #category : 'signalling' }
GciError class >> newForError: aGciErrSType [

| ex |
ex :=self new .
ex	fatal: aGciErrSType fatal ;
	number: aGciErrSType number ;
	reason: aGciErrSType reason ;
	message: aGciErrSType message.
^ ex
]

{ #category : 'signalling' }
GciError class >> newForError: aGciErrSType tracker: aMemoryTracker [
"Build an exception for an GemStone FFI call using the error in aGciErrSType .
Then release the C heap memory before raising the exception."
| result |
result := self newForError: aGciErrSType .
"aMemoryTracker freeAll." "Now that we're done with aGciErrSType, free meemory."
[result signal: result message ] ensure:[ aMemoryTracker freeAll ].

]

{ #category : 'signalling' }
GciError class >> signalFrom: aGciErrSType [

| ex |
ex :=self new .
ex	fatal: aGciErrSType fatal ;
	number: aGciErrSType number ;
	reason: aGciErrSType reason ;
	message: aGciErrSType message.
^ ex signal:  ex message
]

{ #category : 'accessing' }
GciError >> fatal [
	^ fatal
]

{ #category : 'accessing' }
GciError >> fatal: anObject [
	fatal := anObject
]

{ #category : 'accessing' }
GciError >> message [
	^ message
]

{ #category : 'accessing' }
GciError >> message: anObject [
	message := anObject
]

{ #category : 'accessing' }
GciError >> number [
	^ number
]

{ #category : 'accessing' }
GciError >> number: anObject [
	number := anObject
]

{ #category : 'accessing' }
GciError >> reason [
	^ reason
]

{ #category : 'accessing' }
GciError >> reason: anObject [
	reason := anObject
]
