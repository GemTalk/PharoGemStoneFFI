"
An object representing a GemStone session. Most messages are passed to my gciInterface via doesNotUnderstand: .

Instance Variables
	gciInterface:			<GciLegacyInterface or GciThreadSafeInterface >
	sessionParameters:		<GsSessionParameters >


"
Class {
	#name : #GsSession,
	#superclass : #Object,
	#instVars : [
		'gciInterface',
		'sessionParameters'
	],
	#category : #GemStoneFFI
}

{ #category : #examples }
GsSession class >> example1 [
"Get the GCI version string from the 3.7.0 GCI library and the path to the gci library file.
Be sure the path to the GCI client libraries is set. Use this code to set it if necessary:

GciInterface libraryDirectory:  'C:\cygwin64\home\normg\clientlibs'
"

|sess|
sess := GsSession newForGsVersion: '3.7.0' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
^Array with: sess gciVersionString  with: sess gsLibraryPath 

]

{ #category : #examples }
GsSession class >> example2 [
"Log in to GemStone and get the file size report via blocking RPC call.
Be sure the path to the GCI client libraries is set. Use this code to set it if necessary:

GciInterface libraryDirectory:  'C:\cygwin64\home\normg\clientlibs'

GsSession example2
"

|sess result|
sess := GsSession newForGsVersion: '3.7.0' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
sess loginWithGsUser: 'DataCurator' password: 'swordfish'.
result := sess executeStringAndFetchResultString: 'SystemRepository fileSizeReport'.
sess logout.
^result

]

{ #category : #'instance creation' }
GsSession class >> newForGsVersion: aGsVersion threadSafe: aBoolean [

|gci|
gci := aBoolean ifTrue: [ GciThreadSafeInterface newForGsVersion: aGsVersion  ] ifFalse:[ GciLegacyInterface newForGsVersion: aGsVersion ].
self new gciInterface: gci.


]

{ #category : #'instance creation' }
GsSession class >> newForGsVersion: aGsVersion threadSafe: aBoolean stone: stoneName host: hostName netldi: netldiName [

|gci parms|
gci := aBoolean ifTrue: [ GciThreadSafeInterface newForGsVersion: aGsVersion  ] ifFalse:[ GciLegacyInterface newForGsVersion: aGsVersion ].
parms := GsSessionParameters newForStoneName: stoneName host: hostName netldi: netldiName .
^ self new 
	gciInterface: gci ;
	sessionParameters: parms


]

{ #category : #'reflective operations' }
GsSession >> doesNotUnderstand: aMessage [
	^ self gciInterface
		perform: aMessage selector 
		withArguments: aMessage arguments
]

{ #category : #accessing }
GsSession >> gciInterface [
	^ gciInterface
]

{ #category : #accessing }
GsSession >> gciInterface: anObject [
	gciInterface := anObject
]

{ #category : #login }
GsSession >> loginWithGsUser: uid password: pw [ 

^self gciInterface loginWithHostUserId: nil hostPassword: nil gsUserId: uid gsPassword: pw sessionParameters: self sessionParameters 
]

{ #category : #accessing }
GsSession >> sessionParameters [
	^ sessionParameters
]

{ #category : #accessing }
GsSession >> sessionParameters: anObject [
	sessionParameters := anObject
]
