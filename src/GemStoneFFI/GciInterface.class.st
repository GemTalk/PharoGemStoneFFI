"
Abstract superclass for Gci interfaces. Contains behavior used by both the thread-safe and non-thread-safe subclasses.
"
Class {
	#name : 'GciInterface',
	#superclass : 'Object',
	#instVars : [
		'gsVersionString',
		'gsLibraryPath'
	],
	#classVars : [
		'FfiMutex',
		'GciLastVersionUsed',
		'GemStoneLibraryDirectory'
	],
	#pools : [
		'GciTypes'
	],
	#category : 'GemStoneFFI',
	#package : 'GemStoneFFI'
}

{ #category : 'constants' }
GciInterface class >> GCI_PERFORM_DETACH [
	^ 16r40
]

{ #category : 'constants' }
GciInterface class >> GCI_PERFORM_FLAG_DISABLE_ASYNC_EVENTS [
	^ 2
]

{ #category : 'constants' }
GciInterface class >> GCI_PERFORM_FLAG_ENABLE_DEBUG [
	^ 1
]

{ #category : 'constants' }
GciInterface class >> GCI_PERFORM_FLAG_INTERPRETED [
	^ 16r20
]

{ #category : 'constants' }
GciInterface class >> GCI_PERFORM_FLAG_SINGLE_STEP [
	^ 4
]

{ #category : 'constants' }
GciInterface class >> GCI_PERFORM_noClientUseraction [
	^ 16r10
]

{ #category : 'constants' }
GciInterface class >> OOP_CLASS_BYTE_ARRAY [
	^ 103425
]

{ #category : 'constants' }
GciInterface class >> OOP_CLASS_STRING [

^ 74753
]

{ #category : 'constants' }
GciInterface class >> OOP_CLASS_SYMBOL [

^ 110849
]

{ #category : 'constants' }
GciInterface class >> OOP_NUM_TAG_BITS [
	^3
]

{ #category : 'constants' }
GciInterface class >> OOP_TAG_SMALLINT [
	^2
]

{ #category : 'constants' }
GciInterface class >> OOP_TAG_SPECIAL_MASK [
	^6
]

{ #category : 'library path' }
GciInterface class >> addLibraryPathToSystemPath: aByteString [

"On windows, add the library path to the system PATH so windows can find the vc runtime dll files.
See bug 48680. "
Smalltalk os isWindows ifTrue:[ |path|
	path := Smalltalk os environment at: 'PATH' .
	(path includesSubstring: aByteString)
		ifFalse:[ 
			|ws|
			ws := WriteStream with: path.
			path last == $; ifFalse:[ ws nextPut: $;].
			ws nextPutAll: aByteString.
			Smalltalk os environment at: 'PATH' put: ws contents .
	].
].
^ self
]

{ #category : 'converting' }
GciInterface class >> asLocalObject: anOopType [

"Answers a local Boolean or Integer if anOopType is a Boolean or SmallInteger from GemStone or 
nil if anOopType is none of those types.
Note: Caller must check for oopNil!"

anOopType == self oopTrue ifTrue:[ ^ true ].
anOopType == self oopFalse ifTrue:[ ^ false ].
anOopType == self oopNil ifTrue:[ ^ nil ].
(self oopIsSmallInt: anOopType) ifTrue:[ ^ self oopToSmallInt: anOopType ].
"We could add code to check for other specials here like SmallDate, SmallTime, etc"
^Object "Easy cases exhausted. Caller needs to call GciTsFetchObjInfo to find out what is it."
]

{ #category : 'library path' }
GciInterface class >> clearLibraryDirectory [ 
	GemStoneLibraryDirectory := nil
]

{ #category : 'composing' }
GciInterface class >> composeCompleteLibraryDirectoryPathForGsVersion: aGsVerString [

|ws sep|
sep := self separator .
ws := WriteStream on: String new.
ws nextPutAll: self libraryDirectory ;
	nextPut: sep ;
	nextPutAll: aGsVerString  ; "3.6.0"
	nextPut: sep ;
	nextPutAll: self vmMemoryModel asString; "32 or 64"
	nextPutAll: 'bit' .
^ws contents
]

{ #category : 'composing' }
GciInterface class >> composeCompleteLibraryPathForGsVersion: aGsVerString [

|ws sep|
sep := self separator .
ws := WriteStream with: (self composeCompleteLibraryDirectoryPathForGsVersion: aGsVerString ).
ws 	nextPut: sep ;
	nextPutAll: (self composeLibraryFileNameForGsVersion: aGsVerString)  .
^ws contents
]

{ #category : 'composing' }
GciInterface class >> composeLibraryFileNameForGsVersion: aVerString [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ self fileNameStem , aVerString, '-', self vmMemoryModel asString, '.', self sharedLibraryExtension
]

{ #category : 'converting' }
GciInterface class >> convertStringToExternalArgOrNull: byteString memoryTracker: tracker [

"Converts a byteString to an external string which can be passed to the FFI as a C string.
Converts empty strings or nils to NULL in C.
For non-empy strings, add the result to tracker so the caller can free the memory when appropriate."
^(byteString isNotNil and:[ byteString isNotEmpty ] ) 
	ifTrue:[tracker add: (GsExternalByteString newFromByteString: byteString trimBoth) ]
	ifFalse:[ FFIExternalObject null]
]

{ #category : 'subclassresponsibility' }
GciInterface class >> fileNameStem [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ self subclassResponsibility 
]

{ #category : 'library path' }
GciInterface class >> gemstoneLibraryEnvVarName [
^ 'GEMSTONE_LIB_DIR'
]

{ #category : 'library path' }
GciInterface class >> gemstoneLibraryPathFromEnv [
^Smalltalk os environment at: self gemstoneLibraryEnvVarName  ifAbsent:[ nil ]
]

{ #category : 'initialize' }
GciInterface class >> initialize [ 

FfiMutex := Mutex new.
]

{ #category : 'subclassresponsibility' }
GciInterface class >> isThreadSafe [
	^self subclassResponsibility 
]

{ #category : 'library path' }
GciInterface class >> libraryDirectory [

GemStoneLibraryDirectory ifNil:[
	(GemStoneLibraryDirectory := self gemstoneLibraryPathFromEnv)  ifNil:[
	|fd|
	fd :=FileDialogWindow basicNew
        previewType: nil;
        initialize ;
        title: 'Select GemStone Library Directory';
        answerPathName.
	self libraryDirectory: fd openModal answer ].
].
^ GemStoneLibraryDirectory
]

{ #category : 'library path' }
GciInterface class >> libraryDirectory: aDirString [

"Sets the GemStone shared library directory. Subdirectories of this directory will be dotted version names such as 3.6.1, 3.6.2, etc.
Note that this is NOT the same as a $GEMSTONE product tree.
aDirString should not end with a trailing directory separator, which is removed if present."
GemStoneLibraryDirectory := aDirString trimRight:[ :char| char == self separator] .
self initialize .
GsSession initialize.
]

{ #category : 'library path' }
GciInterface class >> libraryDirectoryIsSet [

^ GemStoneLibraryDirectory notNil 
]

{ #category : 'instance creation' }
GciInterface class >> newForGsVersion: gsVersionString [

| result |
result := self new gsVersionString: gsVersionString ; gsLibraryPath: (self composeCompleteLibraryPathForGsVersion: gsVersionString) .
"Windows needs this ext line. See bug 48680"
"Do this after the above code so the library file is verified to exist."
self addLibraryPathToSystemPath: (self composeCompleteLibraryDirectoryPathForGsVersion:  gsVersionString ) . 
^result
]

{ #category : 'constants' }
GciInterface class >> oopFalse [
	^ 12
]

{ #category : 'constants' }
GciInterface class >> oopIllegal [
	^ 1
]

{ #category : 'converting' }
GciInterface class >> oopIsSmallInt: anOopType [

"GciInterface oopIsSmallInt: 5330"
^  self OOP_TAG_SMALLINT == (anOopType bitAnd: self OOP_TAG_SPECIAL_MASK)

]

{ #category : 'constants' }
GciInterface class >> oopNil [
	^ 20
]

{ #category : 'converting' }
GciInterface class >> oopToSmallInt: anOopType [

"GciInterface oopToSmallInt: 5330"
^ (self oopIsSmallInt: anOopType)
 ifTrue:[anOopType bitShift: self OOP_NUM_TAG_BITS negated ]
ifFalse:[ anOopType error: 'receiver is not a GemStone SmallInteger']

]

{ #category : 'constants' }
GciInterface class >> oopTrue [
	^ 268
]

{ #category : 'initialize' }
GciInterface class >> resetFfiMethods [
	"Reset the FFI methods to their non-compiled form to force them to be reinitialised with the current library version"

	Stdio stdout << 'GciInterface: resetFfiMethods'; lf.
	Transcript crShow: 'GciInterface: resetFfiMethods' .
	self package classes do: [ :cls |
		cls methods do: [ :cm |
			(cm hasProperty: #ffiNonCompiledMethod) ifTrue:
				[ cm methodClass methodDict
					at: cm selector
					put: (cm propertyAt: #ffiNonCompiledMethod) ] ] ].

]

{ #category : 'convenience' }
GciInterface class >> separator [ 

^ Smalltalk os environment platform isWindows ifTrue:[  $\ ] ifFalse:[ $/ ]

]

{ #category : 'convenience' }
GciInterface class >> sharedLibraryExtension [
| plat |
plat := Smalltalk os environment platform .
plat isWindows ifTrue:[ ^ 'dll' ].
plat isMacOS ifTrue:[ ^ 'dylib' ].
plat isUnix ifTrue:[ ^ 'so' ].
self error: 'unknown platform'
]

{ #category : 'convenience' }
GciInterface class >> vmMemoryModel [
	^Smalltalk vm is64bit ifTrue:[ 64 ] ifFalse:[ 32 ]
]

{ #category : 'private' }
GciInterface >> checkFfiLibraryVersion [
"Check the current library version loaded.
If it is different to the receiver's, reset the ffi methods."

	(gsVersionString = GciLastVersionUsed) ifFalse:
		[ self class resetFfiMethods.
		GciLastVersionUsed := gsVersionString ]
]

{ #category : 'converting' }
GciInterface >> convertStringToExternalArgOrNull: byteString memoryTracker: tracker [

"Converts a ByteString to an external address"
^self class convertStringToExternalArgOrNull: byteString memoryTracker: tracker
]

{ #category : 'accessing' }
GciInterface >> ffiDo: aBlock [ 
	"Evaluate aBlock within the FFI mutex, ensuring that multiple processes don't simultaneously attempt to make calls with different versions"

	^ FfiMutex critical:
		[ self checkFfiLibraryVersion.
		aBlock value ]

]

{ #category : 'accessing' }
GciInterface >> gsLibraryPath [
	^ gsLibraryPath
]

{ #category : 'accessing' }
GciInterface >> gsLibraryPath: aByteString [
"aByteString is expected to be the full path to the gci library and must exist."
	(File isFile: aByteString)
		ifFalse:[^ FileDoesNotExistException signalWithFile: (File named: aByteString) writeMode: false] .
	gsLibraryPath := aByteString .

]

{ #category : 'accessing' }
GciInterface >> gsVersionString [
	^ gsVersionString
]

{ #category : 'accessing' }
GciInterface >> gsVersionString: anObject [
	gsVersionString := anObject
]

{ #category : 'accessing' }
GciInterface >> isThreadSafe [
	^self class isThreadSafe 
]
