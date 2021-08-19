Class {
	#name : 'GsSessionTest',
	#superclass : 'GemStoneFFITestCase',
	#category : 'GemStoneFFI-Tests'
}

{ #category : 'instance creation' }
GsSessionTest class >> newSession [

^ GsSession newForGsVersion: self gsVersion threadSafe: true stone: self stone host: self host netldi: self netldi
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
