Class {
	#name : #GemStoneFFITestCase,
	#superclass : #TestCase,
	#classVars : [
		'gsVersion',
		'host',
		'netldi',
		'stone'
	],
	#category : #'GemStoneFFI-Tests'
}

{ #category : #acccessing }
GemStoneFFITestCase class >> gsVersion [
^gsVersion 

]

{ #category : #acccessing }
GemStoneFFITestCase class >> gsVersion: aGsVersionString [
gsVersion := aGsVersionString 
]

{ #category : #acccessing }
GemStoneFFITestCase class >> host [
^host
]

{ #category : #acccessing }
GemStoneFFITestCase class >> host: hostOrIp [
host := hostOrIp 
]

{ #category : #acccessing }
GemStoneFFITestCase class >> netldi [ 
^netldi 
]

{ #category : #acccessing }
GemStoneFFITestCase class >> netldi: netldiNameOrPort [
netldi := netldiNameOrPort 
]

{ #category : #acccessing }
GemStoneFFITestCase class >> stone [
^stone
]

{ #category : #acccessing }
GemStoneFFITestCase class >> stone: stoneName [

stone := stoneName
]
