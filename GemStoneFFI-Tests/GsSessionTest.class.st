Class {
	#name : #GsSessionTest,
	#superclass : #GemStoneFFITestCase,
	#category : #'GemStoneFFI-Tests'
}

{ #category : #'instance creation' }
GsSessionTest class >> newSession [

^ GsSession newForGsVersion: self gsVersion threadSafe: true stone: self stone host: self host netldi: self netldi
]

{ #category : #tests }
GsSessionTest >> testLogin [

|sess|
sess := self class newSession .
self 
	assert: (sess loginWithGsUser: 'DataCurator' password: 'swordfish') ;
	assert: sess logout .
^self

]

{ #category : #tests }
GsSessionTest >> testLogoutWhenNotLoggedIn [
|sess|
sess := self class newSession .
self should:[sess logout] raise: Error .
^self

]

{ #category : #tests }
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
