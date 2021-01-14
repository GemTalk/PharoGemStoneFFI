"
aGciInterface
"
Class {
	#name : #GciInterface,
	#superclass : #Object,
	#instVars : [
		'gsVersionString',
		'gsLibraryPath'
	],
	#classVars : [
		'GemStoneLibraryDirectory'
	],
	#pools : [
		'GciTypes'
	],
	#category : #GemStoneFFI
}

{ #category : #constants }
GciInterface class >> OOP_CLASS_STRING [

^ 74753
]

{ #category : #constants }
GciInterface class >> OOP_NUM_TAG_BITS [
	^3
]

{ #category : #constants }
GciInterface class >> OOP_TAG_SMALLINT [
	^2
]

{ #category : #constants }
GciInterface class >> OOP_TAG_SPECIAL_MASK [
	^6
]

{ #category : #converting }
GciInterface class >> asLocalObject: anOopType [

anOopType == self oopTrue ifTrue:[ ^ true ].
anOopType == self oopFalse ifTrue:[ ^ false ].
anOopType == self oopNil ifTrue:[ ^ nil ].
(self oopIsSmallInt: anOopType) ifTrue:[ ^ self oopToSmallInt: anOopType ].
^self error: 'Exceeded limitations of primitive asLocalObject method'
]

{ #category : #'library path' }
GciInterface class >> clearLibraryDirectory [ 
	GemStoneLibraryDirectory := nil
]

{ #category : #composing }
GciInterface class >> composeCompleteLibraryPathForGsVersion: aGsVerString [

|ws sep|
sep := self separator .
ws := WriteStream on: String new.
ws nextPutAll: self libraryDirectory ;
	nextPut: sep ;
	nextPutAll: aGsVerString  ; "3.6.0"
	nextPut: sep ;
	nextPutAll: self vmMemoryModel asString; "32 or 64"
	nextPutAll: 'bit' ;
	nextPut: sep ;
	nextPutAll: (self composeLibraryFileNameForGsVersion: aGsVerString)  .
^ws contents
]

{ #category : #composing }
GciInterface class >> composeLibraryFileNameForGsVersion: aVerString [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ self fileNameStem , aVerString, '-', self vmMemoryModel asString, '.', self sharedLibraryExtension
]

{ #category : #converting }
GciInterface class >> convertStringToExternalArgOrNull: byteString memoryTracker: tracker [

"Converts a byteString to an external string which can be passed to the FFI as a C string.
Converts empty strings or nils to NULL in C.
For non-empy strings, add the result to tracker so the caller can free the memory when appropriate."
^(byteString isNotNil and:[ byteString isNotEmpty ] ) 
	ifTrue:[tracker add: (GsExternalByteString newFromByteString: byteString) ]
	ifFalse:[ FFIExternalObject null]
]

{ #category : #subclassresponsibility }
GciInterface class >> fileNameStem [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ self subclassResponsibility 
]

{ #category : #'library path' }
GciInterface class >> gemstoneLibraryEnvVarName [
^ 'GEMSTONE_LIB_DIR'
]

{ #category : #'library path' }
GciInterface class >> gemstoneLibraryPathFromEnv [
^Smalltalk os environment at: self gemstoneLibraryEnvVarName  ifAbsent:[ nil ]
]

{ #category : #subclassresponsibility }
GciInterface class >> isThreadSafe [
	^self subclassResponsibility 
]

{ #category : #'library path' }
GciInterface class >> libraryDirectory [

GemStoneLibraryDirectory ifNil:[
	(GemStoneLibraryDirectory := self gemstoneLibraryPathFromEnv) ifNil:[
	|fd|
	fd :=FileDialogWindow basicNew
        previewType: nil;
        initialize ;
        title: 'Select GemStone Library Directory';
        answerPathName.
	GemStoneLibraryDirectory := (World openModal: fd) answer.].
].
^ GemStoneLibraryDirectory
]

{ #category : #'library path' }
GciInterface class >> libraryDirectory: aDirString [

"Sets the GemStone shared library directory. Subdirectories of this directory will be dotted version names such as 3.6.1, 3.6.2, etc.
Note that this is NOT the same as a $GEMSTONE product tree.
aDirString should not end with a trailing directory separator, which is removed if present."
GemStoneLibraryDirectory := aDirString trimRight:[ :char| char == self separator] 
]

{ #category : #'instance creation' }
GciInterface class >> newForGsVersion: gsVersionString [

^ self new gsVersionString: gsVersionString ; gsLibraryPath: (self composeCompleteLibraryPathForGsVersion: gsVersionString)
]

{ #category : #constants }
GciInterface class >> oopFalse [
	^ 12
]

{ #category : #constants }
GciInterface class >> oopIllegal [
	^ 1
]

{ #category : #converting }
GciInterface class >> oopIsSmallInt: anOopType [

"GciInterface oopIsSmallInt: 5330"
^ self OOP_TAG_SMALLINT == (anOopType bitAnd: self OOP_TAG_SPECIAL_MASK)

]

{ #category : #constants }
GciInterface class >> oopNil [
	^ 20
]

{ #category : #converting }
GciInterface class >> oopToSmallInt: anOopType [

"GciInterface oopToSmallInt: 5330"
^ anOopType bitShift: self OOP_NUM_TAG_BITS negated 

]

{ #category : #constants }
GciInterface class >> oopTrue [
	^ 268
]

{ #category : #convenience }
GciInterface class >> separator [ 
	^ FileSystem disk separator
]

{ #category : #convenience }
GciInterface class >> sharedLibraryExtension [
| plat |
plat := Smalltalk os environment platform .
plat isWindows ifTrue:[ ^ 'dll' ].
plat isMacOS ifTrue:[ ^ 'dylib' ].
plat isUnix ifTrue:[ ^ 'so' ].
self error: 'unknown platform'
]

{ #category : #convenience }
GciInterface class >> vmMemoryModel [
	^Smalltalk vm is64bit ifTrue:[ 64 ] ifFalse:[ 32 ]
]

{ #category : #converting }
GciInterface >> convertStringToExternalArgOrNull: byteString memoryTracker: tracker [

"Converts a ByteString to an external address"
^self class convertStringToExternalArgOrNull: byteString memoryTracker: tracker
]

{ #category : #accessing }
GciInterface >> gsLibraryPath [
	^ gsLibraryPath
]

{ #category : #accessing }
GciInterface >> gsLibraryPath: anObject [
	gsLibraryPath := anObject
]

{ #category : #accessing }
GciInterface >> gsVersionString [
	^ gsVersionString
]

{ #category : #accessing }
GciInterface >> gsVersionString: anObject [
	gsVersionString := anObject
]

{ #category : #accessing }
GciInterface >> isThreadSafe [
	^self class isThreadSafe 
]
