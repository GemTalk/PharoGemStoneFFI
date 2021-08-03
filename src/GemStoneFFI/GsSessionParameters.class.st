"
An object represeting the parameters needed to log into GemStone.

Instance Variables:
	gemResource:			<GsNetworkResource>
	stoneResource:		<GsNetworkResource>


"
Class {
	#name : 'GsSessionParameters',
	#superclass : 'Object',
	#instVars : [
		'stoneResource',
		'gemResource'
	],
	#category : 'GemStoneFFI'
}

{ #category : 'instance creation' }
GsSessionParameters class >> newDebugForStoneName: stoneName host: hostName netldi: netldiName [
"Createa a new instance that creates a debug gem where both the stone name stoneName and gem session are on host hostName and using netldi netldiName."

^ self new 
		stoneResource: (GsNetworkResource newForStoneNamed: stoneName host: hostName  netldi: netldiName) ;
		gemResource: (GsNetworkResource newDebugGemOnHost: hostName netldi: netldiName ) 
]

{ #category : 'instance creation' }
GsSessionParameters class >> newForStoneName: stoneName host: hostName netldi: netldiName [
"Createa a new instance where both the stone name stoneName and gem session are on host hostName and using netldi netldiName."

^ self new 
		stoneResource: (GsNetworkResource newForStoneNamed: stoneName host: hostName  netldi: netldiName) ;
		gemResource: (GsNetworkResource newDefaultGemOnHost: hostName netldi: netldiName ) 
]

{ #category : 'instance creation' }
GsSessionParameters class >> newWithStoneResource: stoneNetworkResource gemResource: gemNetworkResource [

^ self new stoneResource: stoneNetworkResource ; gemResource: gemNetworkResource 
]

{ #category : 'converting' }
GsSessionParameters >> gemNrs [
	^self gemResource asNrsString
]

{ #category : 'accessing' }
GsSessionParameters >> gemResource [
	^ gemResource
]

{ #category : 'accessing' }
GsSessionParameters >> gemResource: anObject [
	gemResource := anObject
]

{ #category : 'converting' }
GsSessionParameters >> stoneNrs [
	^self stoneResource asNrsString
]

{ #category : 'accessing' }
GsSessionParameters >> stoneResource [
	^ stoneResource
]

{ #category : 'accessing' }
GsSessionParameters >> stoneResource: anObject [
	stoneResource := anObject
]
