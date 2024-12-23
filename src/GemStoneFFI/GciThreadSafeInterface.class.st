"
The class used to call the thread-safe GCI via the Pharo FFI.

Instance Variables:
-session (ExternalData) - a reference to the GciSession object in C heap memory. All Gci thread safe calls take the session as an argument.
"
Class {
	#name : 'GciThreadSafeInterface',
	#superclass : 'GciInterface',
	#instVars : [
		'session'
	],
	#category : 'GemStoneFFI',
	#package : 'GemStoneFFI'
}

{ #category : 'constants' }
GciThreadSafeInterface class >> fileNameStem [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ 'libgcits-'
]

{ #category : 'testing' }
GciThreadSafeInterface class >> isThreadSafe [
	^ true
]

{ #category : 'assertions' }
GciThreadSafeInterface >> assertLoggedIn [

self isLoggedIn ifFalse:[ self error: 'Session is not yet logged in!']
]

{ #category : 'assertions' }
GciThreadSafeInterface >> assertNotLoggedIn [

self isLoggedIn ifTrue:[ self error: 'Session is already logged in']
]

{ #category : 'remote execution (nonblocking)' }
GciThreadSafeInterface >> blockAndFetchNbResult [

"Blocks until the result of a previous non-blocking executeString method is ready.
Raises an exception if an error occurs or if the result is larger than 1024 bytes
(use the blockAndFetchNbResultWithMaxSize: method in that case).
Otherwise returns the result object execution which must be true, false, nil, a SmallInteger
a ByteArray, aString or a Symbol.
To check the nonblocking call status without blocking use the method: getNbCallStatusWithMaxDelay: 0"

^ self blockAndFetchNbResultWithMaxSize: 1024

]

{ #category : 'remote execution (nonblocking)' }
GciThreadSafeInterface >> blockAndFetchNbResultWithMaxSize: maxSize [

"Blocks until the result of a previous non-blocking executeString method is ready.
Raises an exception if an error occurs or if the result is larger than maxSize bytes
(use the blockAndFetchNbResultWithMaxSize: method in that case).
Otherwise returns the result object execution which must be true, false, nil, a SmallInteger
a ByteArray, aString or a Symbol.
To check the nonblocking call status without blocking use the method: getNbCallStatusWithMaxDelay: 0"

|tracker  result  gsError localResult |
self assertLoggedIn .
tracker := GsMemoryTracker new.
gsError := GciErrSType externalNew .
tracker add: gsError.
result := self gciTsNbResult: session gsError: gsError.
result == self class oopIllegal 
	ifTrue:[ ^ GciError newForError: gsError tracker: tracker ].
tracker freeAll. "No error, so done with this."
gsError := nil. "Get freed C memory off the stack"
result == self class oopNil ifTrue:[ ^ nil ].
localResult := self class asLocalObject: result.
^ localResult == Object "Means we could not easily convert it to a Pharo immediate object"
	ifTrue:[self doFetchResultByteObject: result maxResultSize: maxSize tracker: tracker]
	ifFalse:[ localResult ]. "nil, Boolean or Integer take this path"
]

{ #category : 'error handling' }
GciThreadSafeInterface >> checkGciResult: gciResult gsError: gsError tracker: tracker [

gciResult >= 0 ifTrue:[ ^ self ].

"Call failed, return an exception"
^ GciError newForError: gsError tracker: tracker
]

{ #category : 'error handling' }
GciThreadSafeInterface >> checkSpaceForBufferSize: bufSize resultSize: resultSize tracker: tracker [

	resultSize <= bufSize ifTrue:[ ^ self ]. "We have enough room"
	^ [self error: ('Result buffer size (' , bufSize asString,
		  ') is too small (Gci returned ' , resultSize asString,
		  ' bytes)')] ensure:[ tracker freeAll ].
]

{ #category : 'remote execution' }
GciThreadSafeInterface >> doExecuteString: sourceString tracker: tracker [

"Executes sourceString which is expected to return a Boolean, SmallInteger, String, Symbol or ByteArray not larger than 1024 bytes.
Raises an error if the remote execute fails or if the result of the remote execute is larger than 1024."

	| result gciResult gsError srcCstring |
	srcCstring := self
		              convertStringToExternalArgOrNull: sourceString
		              memoryTracker: tracker.
	gsError := GciErrSType externalNew.
	tracker add: gsError.
	gciResult := self ffiDo:[ self
		             gciTsExecute_: session
		             sourceString: srcCstring getHandle
		             sourceStringSize: srcCstring sizeNoNull
		             sourceOop: self class OOP_CLASS_STRING
		             contextObject: self class oopNil
		             symbolList: self class oopNil
		   		       flags: 0
						 envId: 0
		             gsError: gsError getHandle ].
	gciResult == self class oopIllegal 
		ifTrue:[ ^ GciError newForError: gsError tracker: tracker ].
	result := self class asLocalObject: gciResult.
	^ result == Object
		ifTrue:[ self doFetchResultByteObject: gciResult maxResultSize: 1024 tracker: tracker ]
		ifFalse:[ result ]
]

{ #category : 'remote execution' }
GciThreadSafeInterface >> doFetchResultByteObject: oop maxResultSize: maxSize tracker: tracker [

	| objInfo result gciResult resultBuffer gsError isSymbol classOop |
	self assertLoggedIn.
	resultBuffer := GsExternalByteString new: maxSize .
	tracker add: resultBuffer.
	gsError := GciErrSType externalNew.
	tracker add: gsError.
	objInfo := GciTsObjInfo externalNew.
	tracker add: objInfo.
	gciResult := self ffiDo:[ self
		             gciTsFetchObjInfo: session
		             object: oop
		             addToExportSet: 0
		             resultInfo: objInfo getHandle
		             resultBuffer: resultBuffer getHandle
		             resultBufferSize: resultBuffer size
		             gsError: gsError getHandle ].
	self checkGciResult: gciResult gsError: gsError tracker: tracker.
	self
		checkSpaceForBufferSize: maxSize
		resultSize: gciResult
		tracker: tracker.

	classOop := objInfo objClass.
	classOop == self class OOP_CLASS_BYTE_ARRAY ifTrue: [ 
		result := resultBuffer asByteArrayOfSize: gciResult.
		^ result ].

	isSymbol := classOop == self class OOP_CLASS_SYMBOL.
	(isSymbol or: [ classOop == self class OOP_CLASS_STRING ]) ifFalse: [ 
		| msg |
		msg := 'Expected GemStone object to have class OOP_CLASS_STRING but it has class '
		       , classOop asString.
		^ Error signal: msg ].
	result := resultBuffer asByteStringOfSize: gciResult.
	isSymbol ifTrue: [ result := result asSymbol ].
	^ result
]

{ #category : 'remote execution' }
GciThreadSafeInterface >> executeString: sourceString [

"Executes sourceString which is expected to return a Boolean, SmallInteger, String, Symbol or ByteArray not larger than 1024 bytes.
Raises an error if the remote execute fails or if the result of the remote execute is larger than 1024."

	| tracker |
	self assertLoggedIn.
	tracker := GsMemoryTracker new.
	[ ^ self doExecuteString: sourceString tracker: tracker ] ensure:[ tracker freeAll ].
	
]

{ #category : 'remote execution (nonblocking)' }
GciThreadSafeInterface >> executeStringAndDetachNb: sourceString [

"Starts remote execution of the string sourceString and tells the gem to stop servicing
the client and ignore disconnects.
Returns true if the execution was started and raises and exception on error.
Requires GemStone v3.7.1 or later."

|tracker srcCstring result gsError|

self assertLoggedIn .
tracker := GsMemoryTracker new.
srcCstring := self convertStringToExternalArgOrNull: sourceString  memoryTracker: tracker.
gsError := tracker add: GciErrSType externalNew .

result := self ffiDo:[ self gciTsNbExecute: session
		 sourceString: srcCstring getHandle 
		 sourceOop: self class OOP_CLASS_STRING  
		 contextObject: self class oopNil
		 symbolList: self class oopNil
		 flags: self class GCI_PERFORM_DETACH
		 envId: 0
		 gsError: gsError ].
result ~~ 1 ifTrue:[ ^ GciError newForError: gsError tracker: tracker ].
tracker freeAll.
^ true
]

{ #category : 'remote execution' }
GciThreadSafeInterface >> executeStringAndFetchResultByteArray: sourceString maxResultSize: maxSize [

"Executes sourceString which is expected to return a ByteArray of no more than maxSize elements."
^ self executeStringAndFetchResultBytes: sourceString maxResultSize: maxSize asByteArray: true

]

{ #category : 'remote execution' }
GciThreadSafeInterface >> executeStringAndFetchResultBytes: sourceString maxResultSize: maxSize asByteArray: asByteArrayBoolean [

	"Executes sourceString which is expected to return a byte object.
If asByteArrayBoolean is true, then the result is expected to be a ByteArray.
If asByteArrayBoolean is false, then the result expected to be a BytesString.

Raises an error if the remote execute fails or if the result of the remote execute is larger than
maxSize."

	| tracker srcCstring gciResult result resultBuffer gsError |
	self assertLoggedIn.
	tracker := GsMemoryTracker new.
	srcCstring := self
		              convertStringToExternalArgOrNull: sourceString
		              memoryTracker: tracker.
	resultBuffer := tracker add:
		                (GsExternalByteString newWithNull: maxSize).
	gsError := tracker add: GciErrSType externalNew.

	gciResult := self ffiDo:[ self
		             gciTsExecuteFetchBytes: session
		             sourceString: srcCstring getHandle
		             sourceStringSize: srcCstring sizeNoNull
		             sourceOop: self class OOP_CLASS_STRING
		             contextObject: self class oopNil
		             symbolList: self class oopNil
		             resultBuffer: resultBuffer getHandle
		             resultBufferSize: resultBuffer size
		             gsError: gsError ].
	self checkGciResult: gciResult gsError: gsError tracker: tracker.
	self
		checkSpaceForBufferSize: maxSize
		resultSize: gciResult
		tracker: tracker.
	result := asByteArrayBoolean
		          ifTrue: [ resultBuffer asByteArrayOfSize: gciResult ]
		          ifFalse: [ resultBuffer asByteStringOfSize: gciResult ].
	tracker freeAll.
	^ result
]

{ #category : 'remote execution' }
GciThreadSafeInterface >> executeStringAndFetchResultString: sourceString [ 

"Compiles and executes sourceString on GemStone. Assumes the result of the executing is a String object.
Returns a ByteString on success or raises an exception if an error occurs."
^ self executeStringAndFetchResultString: sourceString maxResultSize: 1024

]

{ #category : 'remote execution' }
GciThreadSafeInterface >> executeStringAndFetchResultString: sourceString maxResultSize: anInt [

^ self executeStringAndFetchResultBytes: sourceString maxResultSize: anInt asByteArray: false

]

{ #category : 'remote execution (nonblocking)' }
GciThreadSafeInterface >> executeStringNb: sourceString [

"Starts remote execution of the string sourceString.
Returns true if the execution was started and raises and exception on error."
|tracker srcCstring result gsError|

self assertLoggedIn .
tracker := GsMemoryTracker new.
srcCstring := self convertStringToExternalArgOrNull: sourceString  memoryTracker: tracker.
gsError := tracker add: GciErrSType externalNew .

result := self ffiDo:[ self gciTsNbExecute: session
		 sourceString: srcCstring getHandle 
		 sourceOop: self class OOP_CLASS_STRING  
		 contextObject: self class oopNil
		 symbolList: self class oopNil
		 flags: 0
		 envId: 0
		 gsError: gsError ].
result ~~ 1 ifTrue:[ ^ GciError newForError: gsError tracker: tracker ].
tracker freeAll.
^ true
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsExecuteFetchBytes: sess sourceString: sourceString sourceStringSize: sourceStringSize sourceOop: sourceOop contextObject: contextObject symbolList: symbolList resultBuffer: resultBuffer resultBufferSize: resultBufferSize gsError: gsError [

^self ffiCall: #( int64 GciTsExecuteFetchBytes(
											void * sess, 
											const char* sourceString, 
											int64 sourceStringSize, 
											OopType sourceOop, 
											OopType contextObject, 
											OopType symbolList,  
											char *resultBuffer, 
											int64 resultBufferSize,
											GciErrSType *gsError)) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsExecute_: sess sourceString: sourceString sourceStringSize: sourceStringSize sourceOop: sourceOop contextObject: contextObject symbolList: symbolList flags: flags envId: envId gsError: gsError [

^self ffiCall: #( int64 GciTsExecute_(
											void * sess, 
											const char* sourceString, 
											int64 sourceStringSize, 
											OopType sourceOop, 
											OopType contextObject, 
											OopType symbolList,  
											int flags,
											ushort envId,
											GciErrSType *gsError)) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsFetchObjInfo: sess object: objId addToExportSet: aBoolean resultInfo: aGciTsObjInfo resultBuffer: resultBuffer resultBufferSize: resultBufferSize gsError: gsError [ 

^self ffiCall: #( int64 GciTsFetchObjInfo(
											void *sess, 
											OopType objId,
											BoolType aBoolean, 
											GciTsObjInfo *aGciTsObjInfo,
											char * resultBuffer, 
											size_t resultBufferSize,  
											GciErrSType *gsError)) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsLoginToStone: stnNrs hostUserId: hostUid hostPassword: hostPw hostPwIsEncrypted: hostPwEnc gemNrs: gemNrs gsUserId: gsUid gsPassword: gsPw loginFlags: lFlags haltOnErrorNum: haltNum executedSessInit: aBoolPtr err: gsErrSType [
"Low level FFI call to login using the Gci thread-safe library."
			
^ self ffiCall: #( void * GciTsLogin(const char *stnNrs, 
												const char *hostUid, 
												const char *hostPw, 
												int32 hostPwEnc, 
												const char *gemNrs, 
												const char *gsUid, 
												const char *gsPw, 
												uint32 lFlags, 
												int32 haltNum, 
												int32  *aBoolPtr, 
												GciErrSType *gsErrSType) ) 
			library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsLogout: sess gsError: gsError [
"Low level FFI call to logout using the Gci thread-safe library."
			
^ self ffiCall: #( BoolType GciTsLogout(void *sess, GciErrSType *gsError) ) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsNbExecute: sess sourceString: sourceString sourceOop: sourceOop contextObject: contextObject symbolList: symbolList flags: flags envId: envId gsError: gsError [

^self ffiCall: #( BoolType GciTsNbExecute(
											void * sess, 
											const char* sourceString, 
											OopType sourceOop, 
											OopType contextObject, 
											OopType symbolList,  
											int flags,
											uint16 envId,
											GciErrSType *gsError)) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsNbLogout: sess gsError: gsError [
"Non-blocking low level FFI call to logout using the Gci thread-safe library.
Does not wait for a response from the gem."
			
^ self ffiCall: #( BoolType GciTsNbLogout(void *sess, GciErrSType *gsError) ) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsNbPoll: sess timeoutMs: timeoutMs gsError: gsError [

^self ffiCall: #( int GciTsNbPoll(
											void * sess, 
											int timeoutMs,
											GciErrSType *gsError)) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsNbResult: sess gsError: gsError [

^self ffiCall: #( OopType GciTsNbResult(
											void * sess, 
											GciErrSType *gsError)) library: self gsLibraryPath 
]

{ #category : 'ffi calls' }
GciThreadSafeInterface >> gciTsVersion: buffer bufferSize: bufSize [
"Low level FFI call to logout using the Gci thread-safe library."
			
^ self ffiCall: #( uint32 GciTsVersion(char *buffer, size_t bufSize) ) library: self gsLibraryPath 
]

{ #category : 'version strings' }
GciThreadSafeInterface >> gciVersionString [

|tracker result resultBuffer bufSize|

bufSize := 128.
tracker := GsMemoryTracker new.
resultBuffer := tracker add: (GsExternalByteString newWithNull: bufSize).
 
"Result is the GciProduct type, which is always 3 (not interesting)."
self ffiDo:[ self gciTsVersion: resultBuffer getHandle bufferSize: bufSize ].
"Save result string so we can free the buffer on the C heap"
result := resultBuffer asByteString .
tracker freeAll.
^ result
									

]

{ #category : 'version strings' }
GciThreadSafeInterface >> gciVersionStringShort [

"Answer the short GCI client version string, for example: '3.7.1' "
^ (ReadStream on: self gciVersionString) upTo: Character space

]

{ #category : 'remote execution (nonblocking)' }
GciThreadSafeInterface >> getNbCallStatusWithMaxDelay: delayMs [

"Check for completion of a nonblocking call. Block for delayMs to wait for the call to complete. If delayMs is -1, block forever until the call completes. Answer true if the nonblocking call completed or false if it has not. Otherwise raise an exception inindicating the session has been terminated."

|tracker  result  gsError|
tracker := GsMemoryTracker new.
gsError := tracker add: GciErrSType externalNew .
result := self ffiDo:[ self gciTsNbPoll: session timeoutMs: delayMs gsError: gsError ].
result == -1 
	ifTrue:[ ^ GciError newForError: gsError tracker: tracker ].
tracker freeAll.
gsError := nil. "Get freed C memory off the stack"
result == 1 ifTrue:[ ^ true ].
result == 0 ifTrue:[ ^ false ].
"Should not be here!"
^ self error: ('Unexpected result from gciTsNbPoll call: ', result asString)
]

{ #category : 'testing' }
GciThreadSafeInterface >> isLoggedIn [
^ session ~~ nil
]

{ #category : 'Login' }
GciThreadSafeInterface >> loginWithHostUserId: hostId hostPassword: hostPw gsUserId: gsUserId gsPassword: gsPw sessionParameters: parms [

|exStnNrs exHostId exHostPw exHostPwEnc exGemNrs exGsUid exGsPw exLoginFlags exHaltOnErrNum exBoolPtr gsError result tracker|
"This is ugly smalltalk code, but then again, calling an 11 arg fuction using the FFI is ugly business!"
self assertNotLoggedIn .

"Keep track of all malloced memory with this object."
tracker := GsMemoryTracker new.

"Convert all login string args to external addresses or NULL if empty. tracker remembers the object if it's not null"
exStnNrs := self convertStringToExternalArgOrNull: parms stoneNrs memoryTracker: tracker.
exHostId := self convertStringToExternalArgOrNull: hostId memoryTracker: tracker.
exHostPw := self convertStringToExternalArgOrNull: hostPw memoryTracker: tracker.
exHostPwEnc := 0.
exGemNrs := self convertStringToExternalArgOrNull: parms gemNrs memoryTracker: tracker.
exGsUid := self convertStringToExternalArgOrNull: gsUserId memoryTracker: tracker.
exGsPw := self convertStringToExternalArgOrNull: gsPw memoryTracker: tracker.
exLoginFlags := 0.
exHaltOnErrNum := 0.
exBoolPtr := FFIInt32 newBuffer .
gsError := tracker add: GciErrSType externalNew .
"result is a GsSession (void *)"
result := self ffiDo:[self gciTsLoginToStone: exStnNrs getHandle
		hostUserId: exHostId  getHandle 
		hostPassword: exHostPw  getHandle
		hostPwIsEncrypted: exHostPwEnc  
		gemNrs: exGemNrs  getHandle
		gsUserId: exGsUid getHandle
		 gsPassword: exGsPw getHandle
		 loginFlags: exLoginFlags 
		 haltOnErrorNum: exHaltOnErrNum 
		 executedSessInit: exBoolPtr 
		 err: gsError getHandle ].
result isNull ifTrue:[ ^ GciError newForError: gsError tracker: tracker ].
session := result.
tracker freeAll.
^ true


]

{ #category : 'Login' }
GciThreadSafeInterface >> logout [

"Logout the session. Raise an error if the session is not logged in or GsTsLogout returns an error. Return true on success."
^self logoutNoError: false

]

{ #category : 'Login' }
GciThreadSafeInterface >> logoutNbNoError [

"Logout the session and do not wait for a response from the gem."
| tracker gsError |
self isLoggedIn ifFalse:[
	^ true 
].

tracker := GsMemoryTracker new.
gsError := tracker add: GciErrSType externalNew .
self ffiDo:[ self gciTsNbLogout: session gsError: gsError ].
session := nil.
tracker freeAll.
^true

]

{ #category : 'Login' }
GciThreadSafeInterface >> logoutNoError [
"Same as logout except that errors are ignored. Returns true."
^self logoutNoError: true

]

{ #category : 'Login' }
GciThreadSafeInterface >> logoutNoError: noError [

"Logout the session. If noError is true, then errors are ignored and no exceptions are raised.
If noError is false, raise an exception if the session is already logged out or if the FFI call returns
anything but 1."
| result tracker gsError |
self isLoggedIn ifFalse:[
	^  noError ifTrue:[ true ] ifFalse:[ self error: 'session is not logged in' ].
].

tracker := GsMemoryTracker new.
gsError := tracker add: GciErrSType externalNew .
result := self ffiDo:[ self gciTsLogout: session gsError: gsError ].
session := nil.
((result == 1) or:[ noError]) ifTrue:[
	tracker freeAll.
	^true
].
"Got an error logging out"

result := GciError newForError:  gsError. "Build a coherent exception before freeing gsError"
[result signal: result message ] ensure:[ tracker freeAll ]

]

{ #category : 'remote execution (nonblocking)' }
GciThreadSafeInterface >> startWaitForResultThread [

[ | done delay |
	delay := Delay forSeconds: 1.
	done := false.
	[ done ] whileFalse:[
	(self getNbCallStatusWithMaxDelay: 0) "Poll socket without blocking"
		ifTrue:[ self blockAndFetchNbResult. "Fetch result or raise error"
					done := true. ]
		ifFalse:[ delay wait].
	].
] fork .
^ true
]
