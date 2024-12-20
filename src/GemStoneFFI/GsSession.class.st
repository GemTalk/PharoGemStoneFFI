"
An object representing a GemStone session. Most messages are passed to my gciInterface via doesNotUnderstand: .

Instance Variables
	gciInterface:			<GciLegacyInterface or GciThreadSafeInterface >
	sessionParameters:		<GsSessionParameters >


"
Class {
	#name : 'GsSession',
	#superclass : 'Object',
	#instVars : [
		'gciInterface',
		'sessionParameters'
	],
	#classVars : [
		'AllSessions'
	],
	#category : 'GemStoneFFI'
}

{ #category : 'Session Tracking' }
GsSession class >> addSession: aSession [

AllSessions add: aSession
]

{ #category : 'as yet unclassified' }
GsSession class >> cleanupOldSessions [
	AllSessions removeAll 
]

{ #category : 'examples' }
GsSession class >> example1 [
"Get the GCI version string from the 3.7.0 GCI library and the path to the gci library file.
Be sure the path to the GCI client libraries is set. Use this code to set it if necessary:

GciInterface libraryDirectory:  'C:\cygwin64\home\normg\clientlibs'
"

|sess|
sess := GsSession newForGsVersion: '3.7.0' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
^Array with: sess gciVersionString  with: sess gsLibraryPath 

]

{ #category : 'examples' }
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

{ #category : 'examples (non-blocking)' }
GsSession class >> example3 [
"Log in to GemStone and get the file size report via nonblocking RPC call.
Be sure the path to the GCI client libraries is set. Use this code to set it if necessary:

GciInterface libraryDirectory:  'C:\cygwin64\home\normg\clientlibs'

GsSession example3
"
| sess result timeMicro |
sess := GsSession newForGsVersion: '3.7.0' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
sess loginWithGsUser: 'DataCurator' password: 'swordfish'.
sess executeStringNb: 'SystemRepository fileSizeReport'. "Start the NB command"
timeMicro := Time microsecondsToRun:[ 
				result := sess blockAndFetchNbResult  
				]. "Block for result and measure time spent waiting in microseconds"
sess logout.
^Array with: result with: timeMicro
]

{ #category : 'examples (non-blocking)' }
GsSession class >> example4 [
"Log in to GemStone and get the file size report via nonblocking RPC call.
Be sure the path to the GCI client libraries is set. Use this code to set it if necessary:

GciInterface libraryDirectory:  'C:\cygwin64\home\normg\clientlibs'

GsSession example4
"
| sess result timeMicro delay |
sess := GsSession newForGsVersion: '3.7.0' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
sess loginWithGsUser: 'DataCurator' password: 'swordfish'.
sess executeStringNb: 'SystemRepository fileSizeReport'. "Start the NB command"
delay := Delay forMilliseconds: 20 .
"Poll for the command to complete. 0 means do not block, just return"
[ sess getNbCallStatusWithMaxDelay: 0 ] whileFalse:[ delay wait].
result := sess blockAndFetchNbResult .
sess logout.
^result
]

{ #category : 'examples' }
GsSession class >> example5 [
"Log in to GemStone and get a 10K byte array filed with random bytes.
Be sure the path to the GCI client libraries is set. Use this code to set it if necessary:

GciInterface libraryDirectory:  'C:\cygwin64\home\normg\clientlibs'

GsSession example5
"

|sess result|
sess := GsSession newForGsVersion: '3.7.0' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
sess loginWithGsUser: 'DataCurator' password: 'swordfish'.
result := sess executeStringAndFetchResultByteArray: 'ByteArray withRandomBytes: 10240' maxResultSize: 10240 . 
sess logout.
^result

]

{ #category : 'examples' }
GsSession class >> example6 [
"Log in to GemStone and fork a string to execute in the gem and detach the client from the gem.
The gem will print a timestamp to the gem log each second for 30 seconds then logout.
Requires 3.7.1 or later.


GsSession example6
"

|sess result str |
sess := GsSession newForGsVersion: '3.7.2' threadSafe: true stone: 'norm' host: 'moop' netldi: '10117'.
sess loginWithGsUser: 'DataCurator' password: 'swordfish'.
str := '30 timesRepeat:[ GsFile gciLogServer: DateTime now asString. System sleep: 1]. System logout'.
result := sess executeStringAndDetachNb: str.
sess logoutNbNoError. "Will not block"
^result

]

{ #category : 'class initialization' }
GsSession class >> initialize [ 

"Init class var"
AllSessions ifNil:[ AllSessions := IdentitySet new ].

"Add startup hook to clear stale sessions."
(SessionManager default hasRegistered: self name asString)
  ifFalse:[ SessionManager default register: (ClassSessionHandler forClassNamed: self name asString)
				inCategory: SessionManager default systemCategory.
		].
]

{ #category : 'instance creation' }
GsSession class >> newForGsVersion: aGsVersion threadSafe: aBoolean [

|gci|
gci := aBoolean ifTrue: [ GciThreadSafeInterface newForGsVersion: aGsVersion  ] ifFalse:[ GciLegacyInterface newForGsVersion: aGsVersion ].
self new gciInterface: gci.


]

{ #category : 'instance creation' }
GsSession class >> newForGsVersion: aGsVersion threadSafe: aBoolean stone: stoneName host: hostName netldi: netldiName [

|gci parms|
gci := aBoolean ifTrue: [ GciThreadSafeInterface newForGsVersion: aGsVersion  ] ifFalse:[ GciLegacyInterface newForGsVersion: aGsVersion ].
parms := GsSessionParameters newForStoneName: stoneName host: hostName netldi: netldiName .
^ self new 
	gciInterface: gci ;
	sessionParameters: parms


]

{ #category : 'Session Tracking' }
GsSession class >> removeSession: aSession [

AllSessions remove: aSession ifAbsent: [  ]
]

{ #category : 'Session Tracking' }
GsSession class >> sessionIsValid: aSession [

^ AllSessions includes: aSession
]

{ #category : 'system startup' }
GsSession class >> shutdown: aBool [

Transcript show: ('Got shutdown:', aBool asString)
]

{ #category : 'system startup' }
GsSession class >> startUp: coldStart [

coldStart ifTrue:[ self initialize ; cleanupOldSessions ].

]

{ #category : 'reflective operations' }
GsSession >> doesNotUnderstand: aMessage [
	^ self gciInterface
		perform: aMessage selector 
		withArguments: aMessage arguments
]

{ #category : 'accessing' }
GsSession >> gciInterface [
	^ gciInterface
]

{ #category : 'accessing' }
GsSession >> gciInterface: anObject [
	gciInterface := anObject
]

{ #category : 'login' }
GsSession >> loginWithGsUser: uid password: pw [ 

^self loginWithGsUser: uid password: pw hostUserId: nil hostPassword: nil
]

{ #category : 'login' }
GsSession >> loginWithGsUser: uid password: pw hostUserId: hostu hostPassword: hostpw [

self gciInterface loginWithHostUserId: hostu hostPassword: hostpw gsUserId: uid gsPassword: pw sessionParameters: self sessionParameters.
self class addSession: self.
^ true
]

{ #category : 'login' }
GsSession >> logout [

	^ [ 
	  (self class sessionIsValid: self) ifTrue: [ gciInterface logout ] ] 
		  ensure: [ self class removeSession: self ]
]

{ #category : 'login' }
GsSession >> logoutNoError [

[(self class sessionIsValid: self) ifTrue:[ gciInterface logoutNoError] ] ensure:[ self class removeSession: self ]


]

{ #category : 'accessing' }
GsSession >> sessionParameters [
	^ sessionParameters
]

{ #category : 'accessing' }
GsSession >> sessionParameters: anObject [
	sessionParameters := anObject
]
