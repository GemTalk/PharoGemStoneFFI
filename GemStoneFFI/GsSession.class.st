Class {
	#name : #GsSession,
	#superclass : #Object,
	#instVars : [
		'gciInterface',
		'sessionParameters'
	],
	#category : #GemStoneFFI
}

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

{ #category : #'remote execution' }
GsSession >> executeStringAndFetchResultString: sourceString [ 

^self gciInterface executeStringAndFetchResultString: sourceString 
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

{ #category : #login }
GsSession >> logout [

^self gciInterface logout
]

{ #category : #accessing }
GsSession >> sessionParameters [
	^ sessionParameters
]

{ #category : #accessing }
GsSession >> sessionParameters: anObject [
	sessionParameters := anObject
]
