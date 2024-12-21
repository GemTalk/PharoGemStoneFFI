Class {
	#name : 'GsSessionTest',
	#superclass : 'GemStoneFFITestCase',
	#category : 'GemStoneFFI-Tests',
	#package : 'GemStoneFFI-Tests'
}

{ #category : 'instance creation' }
GsSessionTest class >> newSession [

^ GsSession newForGsVersion: self gsVersion threadSafe: true stone: self stone host: self host netldi: self netldi
]

{ #category : 'tests' }
GsSessionTest >> buildStringForSessionId: idstr [

| ws |
ws := WriteStream on: String new.
ws 
	nextPutAll: '| end delay result |' ; lf ;
	nextPutAll: 'end := DateTime now addSeconds: 60.' ; lf ;
	nextPutAll: 'delay := Delay forMilliseconds: 250.' ; lf ;
	nextPutAll: '[System currentSessions includesIdentical: ' ; nextPutAll: idstr ; nextPutAll: ' ] whileTrue:[' ; lf ;
	nextPutAll: ' DateTime now > end ifTrue:[ ^ false asString ].' ; lf ;
	nextPutAll: 'delay wait.' ; lf ;
	nextPutAll: '].' ; lf ;
	nextPutAll: 'result := 30 == (System sharedCounter: 1).' ; lf ;
	nextPutAll: 'GsFile gciLogServer: (''result was '', result asString) . ' ; lf ;
	nextPutAll: '^ result asString' .
^ ws contents
	
		
]

{ #category : 'tests' }
GsSessionTest >> testForkAndDetach [
|ses1 ses1id ses2 ses1str ses2str r1 r2 |
self timeLimit: 1 minute. "this test takes awhile"
ses1 := self class newSession .
ses2 := self class newSession .
[ 
	ses1 loginWithGsUser: 'DataCurator' password: 'swordfish'  ; keepGemLog .
	ses2 loginWithGsUser: 'DataCurator' password: 'swordfish' ; keepGemLog .
	ses1id := ses1 gemSessionId .
	ses2str := self buildStringForSessionId: ses1id .
	ses1str := '| delay |
		System sharedCounter: 1 setValue: 0 .
		delay := Delay forMilliseconds: 500.
		30 timesRepeat:[
		  System sharedCounter: 1 incrementBy: 1 .
		  delay wait
		].
		System logout' .
	r1 := ses1 executeStringAndDetachNb: ses1str.
	ses1 logoutNbNoError .
	r2 := ses2 executeStringAndFetchResultString: ses2str.
] ensure:[ ses1 logoutNbNoError. ses2 logoutNbNoError ].
self assert: r2 equals: 'true'.
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
