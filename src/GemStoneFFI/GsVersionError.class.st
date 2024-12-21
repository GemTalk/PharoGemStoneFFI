"
I am the error raised when the FFI detects the GCI client (client library) or GCI server (gem) version is not supported by the FFI.
"
Class {
	#name : 'GsVersionError',
	#superclass : 'Error',
	#instVars : [
		'isClient',
		'requiredVersion',
		'actualVersion'
	],
	#category : 'GemStoneFFI',
	#package : 'GemStoneFFI'
}

{ #category : 'instance creation' }
GsVersionError class >> newForRequiredVersion: reqVer actualVersion: actVer isClient: aBoolean [

| inst |
inst := self new.
^ inst
	actualVersion: actVer ;
	requiredVersion: reqVer ;
	isClient: aBoolean ;
	signal: inst buildMessageText 
]

{ #category : 'accessing' }
GsVersionError >> actualVersion [

	^ actualVersion
]

{ #category : 'accessing' }
GsVersionError >> actualVersion: anObject [

	actualVersion := anObject
]

{ #category : 'Building' }
GsVersionError >> buildMessageText [

|ws |
ws := WriteStream with: 'Incompatible version detected between FFI and GCI '.
isClient ifTrue:[ ws nextPutAll: 'client. '] ifFalse:[ ws nextPutAll: 'server. '].
ws nextPutAll: 'Required version: ' ;
	nextPutAll: self requiredVersion ;
	nextPutAll: ', Actual version: ' ;
	nextPutAll: self actualVersion.
^ ws contents.

]

{ #category : 'accessing' }
GsVersionError >> isClient [

	^ isClient
]

{ #category : 'accessing' }
GsVersionError >> isClient: anObject [

	isClient := anObject
]

{ #category : 'accessing' }
GsVersionError >> requiredVersion [

	^ requiredVersion
]

{ #category : 'accessing' }
GsVersionError >> requiredVersion: anObject [

	requiredVersion := anObject
]
