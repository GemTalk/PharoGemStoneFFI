Class {
	#name : #GciLegacyInterface,
	#superclass : #GciInterface,
	#category : #GemStoneFFI
}

{ #category : #constants }
GciLegacyInterface class >> fileNameStem [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ 'libgcirpc-'
]

{ #category : #testing }
GciLegacyInterface class >> isThreadSafe [
	^ false
]
