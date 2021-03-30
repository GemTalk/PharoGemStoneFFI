"
A representation of the GciTsObjInfo C structure, which is used by the thread-safe GCI to return certain attributes of an OopType (object).
Allocated on the C heap and must be freed.
"
Class {
	#name : 'GciTsObjInfo',
	#superclass : 'FFIStructure',
	#classVars : [
		'OFFSET_ACCESS',
		'OFFSET_NAMEDSIZE',
		'OFFSET_OBJCLASS',
		'OFFSET_OBJECTSECURITYPOLICYID',
		'OFFSET_OBJID',
		'OFFSET_OBJSIZE',
		'OFFSET__BITS'
	],
	#pools : [
		'GciTypes'
	],
	#category : 'GemStoneFFI'
}

{ #category : 'field definition' }
GciTsObjInfo class >> fieldsDesc [
^ #(
	OopType objId;
	OopType objClass;
	int64 objSize;
	int namedSize;
	uint32 access;
	uint16 objectSecurityPolicyId;
	uint16 _bits;
	)
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> _bits [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET__BITS
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> _bits: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET__BITS put: anObject
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> access [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_ACCESS
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> access: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_ACCESS put: anObject
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> namedSize [
	"This method was automatically generated"
	^handle signedLongAt: OFFSET_NAMEDSIZE
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> namedSize: anObject [
	"This method was automatically generated"
	handle signedLongAt: OFFSET_NAMEDSIZE put: anObject
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objClass [
	"This method was automatically generated"
	^handle unsignedLongLongAt: OFFSET_OBJCLASS
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objClass: anObject [
	"This method was automatically generated"
	handle unsignedLongLongAt: OFFSET_OBJCLASS put: anObject
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objId [
	"This method was automatically generated"
	^handle unsignedLongLongAt: OFFSET_OBJID
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objId: anObject [
	"This method was automatically generated"
	handle unsignedLongLongAt: OFFSET_OBJID put: anObject
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objSize [
	"This method was automatically generated"
	^handle signedLongLongAt: OFFSET_OBJSIZE
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objSize: anObject [
	"This method was automatically generated"
	handle signedLongLongAt: OFFSET_OBJSIZE put: anObject
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objectSecurityPolicyId [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_OBJECTSECURITYPOLICYID
]

{ #category : 'accessing structure variables' }
GciTsObjInfo >> objectSecurityPolicyId: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_OBJECTSECURITYPOLICYID put: anObject
]
