Class {
	#name : 'GemStoneFFITestCase',
	#superclass : 'TestCase',
	#classVars : [
		'gsVersion',
		'host',
		'netldi',
		'stone'
	],
	#category : 'GemStoneFFI-Tests'
}

{ #category : 'acccessing' }
GemStoneFFITestCase class >> gsVersion [
^gsVersion 

]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> gsVersion: aGsVersionString [
gsVersion := aGsVersionString 
]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> host [
^host
]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> host: hostOrIp [
host := hostOrIp 
]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> netldi [ 
^netldi 
]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> netldi: netldiNameOrPort [
netldi := netldiNameOrPort 
]

{ #category : 'examples' }
GemStoneFFITestCase class >> simpleSetup [

	"Run this example, suitably edited for your environment, 
	as a prerequisite to running tests that log in to GemStone.
	You will also need to set the path to a clientLibs directory:
	  GciInterface libraryDirectory: '/path/to/somewhere/clientlibs'"

	<example>
	
	self
		gsVersion: '3.7.0';
		host: 'localhost';
		netldi: 'gs64ldi';
		stone: 'gs64stone'
		
	
]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> stone [
^stone
]

{ #category : 'acccessing' }
GemStoneFFITestCase class >> stone: stoneName [

stone := stoneName
]
