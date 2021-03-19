"
The class used to call the legacy non-thread-safe GCI via the Pharo FFI.
Not yet implemented, contact Norm Green if you need it to work.
"
Class {
	#name : 'GciLegacyInterface',
	#superclass : 'GciInterface',
	#category : 'GemStoneFFI'
}

{ #category : 'constants' }
GciLegacyInterface class >> fileNameStem [

"Gci Lbraries are named this way:
  libgcirpc-ver1.ver2.ver3-mmodel.ext"
^ 'libgcirpc-'
]

{ #category : 'testing' }
GciLegacyInterface class >> isThreadSafe [
	^ false
]
