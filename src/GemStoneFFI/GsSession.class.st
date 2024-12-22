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
	#category : 'GemStoneFFI',
	#package : 'GemStoneFFI'
}

{ #category : 'Session Tracking' }
GsSession class >> addSession: aSession [

AllSessions add: aSession
]

{ #category : 'private' }
GsSession class >> allSessions [

	^ AllSessions 
]

{ #category : 'version management' }
GsSession class >> checkVersionString: verString isClient: aboolean [

"Validate the version string is recent enough to use the FFI. Raises a GsVersionError if not."
^ (self validateVersionString: verString)
	ifTrue:[ true ]
	ifFalse:[ self raiseVersionErrorFor: verString isClient: aboolean ].
	
]

{ #category : 'private' }
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

{ #category : 'version management' }
GsSession class >> gsMajorVersionFromString: aString [

^ (aString at: 1) digitValue
]

{ #category : 'version management' }
GsSession class >> gsMinorVersionFromString: aString [

^ (aString at: 3) digitValue
]

{ #category : 'version management' }
GsSession class >> gsPatchVersionFromString: aString [

^ (aString at: 5) digitValue
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

{ #category : 'version management' }
GsSession class >> minGsMajorVersion [

^self gsMajorVersionFromString: self minGsVersionString 
]

{ #category : 'version management' }
GsSession class >> minGsMinorVersion [

^self gsMinorVersionFromString: self minGsVersionString 
]

{ #category : 'version management' }
GsSession class >> minGsPatchVersion [

^self gsPatchVersionFromString: self minGsVersionString 
]

{ #category : 'version management' }
GsSession class >> minGsVersionString [

"Answer the minimum GemStone version required for using this FFI. 
Applies to both the GCI client (client libraries) and the GCI server (gem process).

First digit it the major version number.
Second digit is the minor version number.
Third digit is the patch level."

^ '3.7.1'
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

{ #category : 'version management' }
GsSession class >> raiseVersionErrorFor: verString isClient: aboolean [

^ GsVersionError 
	newForRequiredVersion: self minGsVersionString 
	actualVersion: verString 
	isClient: aboolean
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

{ #category : 'version management' }
GsSession class >> validateVersionString: verString [

"Must be 3.x"
| major minor patch |
major := self gsMajorVersionFromString: verString .
major == self minGsMajorVersion 
	ifFalse:[ ^ false ].	
minor := self gsMinorVersionFromString: verString .
"Must be at least 3.7.x"
minor >= self minGsMinorVersion 
	ifFalse:[ ^ false ].
"Do not check patch level if 3.8 or later"
minor > self minGsMinorVersion 
	ifTrue:[ ^ true ].
"We have 3.7.x if we get here, ensure we are not using 3.7.0"	
patch := self gsPatchVersionFromString: verString .
patch >= self minGsPatchVersion 
	ifFalse:[ ^ false ].
"Success!"	
^ true

]

{ #category : 'version strings' }
GsSession >> clientVersionString [

"Answer the long version for the GCI client (client library)"
^ self gciInterface gciVersionString
]

{ #category : 'version strings' }
GsSession >> clientVersionStringShort [

"Answer the short version for the GCI client (client library)"
^ self gciInterface gciVersionStringShort
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

{ #category : 'accessing - gem' }
GsSession >> gemLogFileName [

"Answer a ByteString representing the log file name of the gem. Receiver must be logged in."
^ self executeStringAndFetchResultString: 'System gemLogFileName'
]

{ #category : 'accessing - gem' }
GsSession >> gemLogFileNameContents [

"Answer a ByteString representing the contents of the gem log file. Receiver must be logged in."

| str sz |
"Find out how big it is."
sz := self executeString: 'GsFile sizeOfOnServer: System gemLogFileName'.
"Allow for some growth"
sz := sz + 512.
"Fetch the file contents"
str := '|gsf r | gsf := GsFile openReadOnServer: System gemLogFileName. r := gsf contents. gsf close. ^r'.
^ self executeStringAndFetchResultString: str maxResultSize: sz.

]

{ #category : 'accessing - gem' }
GsSession >> gemProcessId [

"Answer a SmallInteger which is the process ID of the gem process. Receiver must be logged in."
^ self executeString: 'System gemProcessId'
]

{ #category : 'accessing - gem' }
GsSession >> gemSessionId [

"Answer a SmallInteger which is the session ID of the gem. Receiver must be logged in."
^ self executeString: 'System session'
]

{ #category : 'accessing - gem' }
GsSession >> keepGemLog [

"Prevents the gem from removing the gem log upon exit. Receiver must be logged in."
^ self executeString: 'System removeGemLogOnExit: false. true'
]

{ #category : 'login' }
GsSession >> loginWithGsUser: uid password: pw [ 

^self loginWithGsUser: uid password: pw hostUserId: nil hostPassword: nil
]

{ #category : 'login' }
GsSession >> loginWithGsUser: uid password: pw hostUserId: hostu hostPassword: hostpw [

self gciInterface loginWithHostUserId: hostu hostPassword: hostpw gsUserId: uid gsPassword: pw sessionParameters: self sessionParameters.
self class addSession: self.

"Validate the GCI client and server versions are recent enough"
[self validateVersions ] 
	on: GsVersionError 
	do:[:ex| 	self logoutNbNoError . ex pass ].
^ true
]

{ #category : 'login' }
GsSession >> logout [

(self class sessionIsValid: self)
	ifFalse:[ ^ self error: 'session is not logged in' ].

^ [ gciInterface logout ] ensure: [ self class removeSession: self ]
]

{ #category : 'login' }
GsSession >> logoutNbNoError [

"Non blocking version of logout. Same as logoutNoError except the client does not wait for a response from the gem."

[(self class sessionIsValid: self) ifTrue:[ gciInterface logoutNbNoError] ] ensure:[ self class removeSession: self ]


]

{ #category : 'login' }
GsSession >> logoutNoError [

[(self class sessionIsValid: self) ifTrue:[ gciInterface logoutNoError] ] ensure:[ self class removeSession: self ]


]

{ #category : 'version strings' }
GsSession >> serverVersionString [

"Answer the long version for the GCI server (gem process)"
^ self gciInterface executeStringAndFetchResultString: 'System _gemVersion'
]

{ #category : 'version strings' }
GsSession >> serverVersionStringShort [
"Answer the short version for the GCI server (gem process). Example: '3.7.1' "

^ (ReadStream on: self serverVersionString) upTo: $,

]

{ #category : 'accessing' }
GsSession >> sessionParameters [
	^ sessionParameters
]

{ #category : 'accessing' }
GsSession >> sessionParameters: anObject [
	sessionParameters := anObject
]

{ #category : 'version strings' }
GsSession >> validateVersions [

self class checkVersionString: self clientVersionStringShort isClient: true.
self class checkVersionString: self serverVersionStringShort isClient: false.
^ self

]
