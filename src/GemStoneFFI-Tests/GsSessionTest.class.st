Class {
	#name : 'GsSessionTest',
	#superclass : 'GemStoneFFITestCase',
	#category : 'GemStoneFFI-Tests',
	#package : 'GemStoneFFI-Tests'
}

{ #category : 'instance creation' }
GsSessionTest class >> newLoggedInSession [

^ self newSession loginWithGsUser: 'DataCurator' password: 'swordfish' ; keepGemLog ; yourself 

]

{ #category : 'instance creation' }
GsSessionTest class >> newSession [

^ GsSession newForGsVersion: self gsVersion threadSafe: true stone: self stone host: self host netldi: self netldi
]

{ #category : 'tests' }
GsSessionTest >> buildStringForSessionId: id [

"Build a string to be executed by session 2. This code will wait for up to 60 seconds for the session with the given id to exit.
It will then return the value of the shared counter, which should be 30."
| ws |
ws := WriteStream on: String new.
ws 
	nextPutAll: '| end delay result |' ; lf ;
	nextPutAll: 'end := DateTime now addSeconds: 60.' ; lf ;
	nextPutAll: 'delay := Delay forMilliseconds: 250.' ; lf ;
	nextPutAll: '[System currentSessions includesIdentical: ' ; nextPutAll: id asString ; nextPutAll: ' ] whileTrue:[' ; lf ;
	nextPutAll: ' DateTime now > end ifTrue:[ ^ false asString ].' ; lf ;
	nextPutAll: 'delay wait.' ; lf ;
	nextPutAll: '].' ; lf ;
	nextPutAll: 'result := System sharedCounter: 1.' ; lf ;
	nextPutAll: 'GsFile gciLogServer: (''result was '', result asString) . ' ; lf ;
	nextPutAll: '^ result' .
^ ws contents
	
		
]

{ #category : 'tests' }
GsSessionTest >> doTestForkAndDetachWith: ses1 and: ses2 [

"Test fork and detach. session 1 is forked and increments a shared counter in the server 30 times, sleeping 500 ms 
 after each increment. session 2 waits for session 1 to exit and verifies the counter value is 30.
Test takes approx 15 seconds depending on network speed and stone loading."
| ses1id ses1str ses2str r1 r2 |
ses1str := '| delay |
System sharedCounter: 1 setValue: 0 .
delay := Delay forMilliseconds: 500.
30 timesRepeat:[
  System sharedCounter: 1 incrementBy: 1 .
  delay wait
].
System logout' .
ses1id := ses1 gemSessionId .
ses2str := self buildStringForSessionId: ses1id .
r1 := ses1 executeStringAndDetachNb: ses1str.
ses1 logoutNbNoError .
r2 := ses2 executeString: ses2str.
self assert: r2 equals: 30 .
^ self



]

{ #category : 'tests' }
GsSessionTest >> testForkAndDetach [
|ses1  ses2  |
self timeLimit: 1 minute. "this test takes awhile"
ses1 := self class newLoggedInSession .
ses2 := self class newLoggedInSession .
[ self doTestForkAndDetachWith: ses1 and: ses2 ] 
	ensure:[ ses1 logoutNbNoError. ses2 logoutNbNoError ] .
^ self

]

{ #category : 'tests' }
GsSessionTest >> testGemLogFileContents [

| s |
s := self class newLoggedInSession.
[ | tmp | self assert: (tmp := s gemLogFileNameContents) class identicalTo: ByteString ] 
	ensure:[ s logoutNbNoError ].
^ self

]

{ #category : 'tests' }
GsSessionTest >> testGemLogFileName [

| s |
s := self class newLoggedInSession.
[ | tmp | self assert: (tmp := s gemLogFileName) class identicalTo: ByteString ] 
	ensure:[ s logoutNbNoError ].
^ self

]

{ #category : 'tests' }
GsSessionTest >> testGemProcessId [

| s |
s := self class newLoggedInSession.
[ | tmp | self assert: (tmp := s gemProcessId) isInteger ] ensure:[ s logoutNbNoError ].
^ self

]

{ #category : 'tests' }
GsSessionTest >> testGemSessionId [

| s |
s := self class newLoggedInSession.
[ | tmp | self assert: (tmp := s gemSessionId) isInteger ] ensure:[ s logoutNbNoError ].
^ self

]

{ #category : 'tests' }
GsSessionTest >> testGetNbCallStatus [
|s r|
s := self class newSession .
self assert: (s loginWithGsUser: 'DataCurator' password: 'swordfish');
		assert: s isLoggedIn.
[ |delay res|
	delay := Delay forMilliseconds: 100.
	self assert: (s executeStringNb: 'System sleep: 3. true').
	[ res := s getNbCallStatusWithMaxDelay: 0 ] whileFalse:[ delay wait ].
	self assert: res.
  r := s blockAndFetchNbResult. 
] ensure:[ s logout ].
self assert: r.
^self
]

{ #category : 'tests' }
GsSessionTest >> testHelloWorld [
|s r|
s := self class newSession .
self assert: s class identicalTo: GsSession.
self assert: (s loginWithGsUser: 'DataCurator' password: 'swordfish').
[ r := s executeStringAndFetchResultString: '''Hello, World!''' ] ensure:[ s logout ].
self assert: r equals: 'Hello, World!'.
^self
]

{ #category : 'tests' }
GsSessionTest >> testHelloWorldNb [
|s r|
s := self class newSession .
self assert: s class identicalTo: GsSession.
self assert: (s loginWithGsUser: 'DataCurator' password: 'swordfish').
[ self assert: (s executeStringNb: '''Hello, World!''').
  r := s blockAndFetchNbResult. ] ensure:[ s logout ].
self assert: r equals: 'Hello, World!'.
^self
]

{ #category : 'tests' }
GsSessionTest >> testKeepGemLog [

| s |
s := self class newLoggedInSession.
[ | tmp| self assert: (tmp := s keepGemLog) ] ensure:[ s logoutNbNoError ].
^ self

]

{ #category : 'tests' }
GsSessionTest >> testLogin [

|sess|
sess := self class newSession .
self 
	assert: (sess loginWithGsUser: 'DataCurator' password: 'swordfish') ;
	assert: sess isLoggedIn ;
	assert: sess logout .
^self

]

{ #category : 'tests' }
GsSessionTest >> testLoginWithSpaces [

"Test issue 5: login with leading and trailing spaces"

| stn hst nldi sess |
stn := '  ', self class stone, '  '.
host := 
hst := '  ', self class host, '  '.
nldi := ' ', self class netldi, ' '.

sess := GsSession 
	newForGsVersion: self class gsVersion 
	threadSafe: true 
	stone: stn
	host: hst
	netldi: nldi.
[ self
	assert: sess class identicalTo: GsSession ;
	assert: (sess loginWithGsUser: 'DataCurator' password: 'swordfish') 
] ensure:[ sess ifNotNil:[ sess logoutNbNoError ] ].
	
^ self

]

{ #category : 'tests' }
GsSessionTest >> testLogoutError [
"test issue 12"
|sess|
sess := self class newSession .
self should:[ sess logout ] raise: Error.
^self

]

{ #category : 'tests' }
GsSessionTest >> testLogoutWhenNotLoggedIn [
|sess|
sess := self class newSession .
self should:[sess logout] raise: Error .
^self

]

{ #category : 'tests' }
GsSessionTest >> testVersion [

|sess fullVerFromGci verFromGci verFromTestInit |
sess := self class newSession .
fullVerFromGci := sess gciVersionString .
verFromTestInit := self class gsVersion .
self 
	assert: (fullVerFromGci isKindOf: ByteString) ;
	assert: (sess isKindOf: GsSession).
verFromGci := (ReadStream on: fullVerFromGci) upTo: Character space .
self assert: verFromGci equals: verFromTestInit .
^ self	

		
]
