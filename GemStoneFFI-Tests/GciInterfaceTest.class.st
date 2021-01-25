Class {
	#name : #GciInterfaceTest,
	#superclass : #GemStoneFFITestCase,
	#category : #'GemStoneFFI-Tests'
}

{ #category : #tests }
GciInterfaceTest >> testAsLocalObject [

self 
	assert: (GciInterface asLocalObject: GciInterface oopTrue) identicalTo: true ;
	assert: (GciInterface asLocalObject: GciInterface oopFalse) identicalTo: false ;
	assert: (GciInterface oopIsSmallInt: 5330) ;
	deny: (GciInterface oopIsSmallInt: 5332) ;
	assert: (GciInterface asLocalObject: 5330) identicalTo: 666 ;
	assert: (GciInterface asLocalObject: GciInterface OOP_CLASS_SYMBOL) identicalTo: nil .
^ self
]
