"
An object to represent a GemStone Network Resource. Network Resource Strings (NRS) are required to login to GemStoone.
All inst vars are ByteStrings. Valid NRS string formats are documented here: https://downloads.gemtalksystems.com/docs/GemStone64/3.6.x/GS64-SysAdminGuide-3.6/GS64-SysAdminGuide-3.6.htm


Instance Variables
	dirPattern:		<String> - pattern for specifying a directory where log files go. See docs for supported wildcard characters (optional)
	host:				<String> - a hostname or IP address. (required)
	logPattern:		<String> - pattern for specifying a log file name. See docs for supported wildcard characters. (optional)
	name:				<String> - name of the resource. For a stone NRS, this is the name of the stone (default: gs64stone). For a gem NRS, this is the name of the script used to start the gem (default: gemnetobject) (required)
	netldi:			<String> - name or port number of the netlid running on host. If a name is specified, it must be resolvable to a port number by /etc/services.dat on the client machine. (required)

The #asNrsString message is used to construct an NRS valid for login to GemStone.
"
Class {
	#name : #GsNetworkResource,
	#superclass : #Object,
	#instVars : [
		'name',
		'host',
		'netldi',
		'dirPattern',
		'logPattern'
	],
	#category : #GemStoneFFI
}

{ #category : #defaults }
GsNetworkResource class >> debugGemResourceName [

^'gemnetdebug'
]

{ #category : #defaults }
GsNetworkResource class >> defaultGemResourceName [

^'gemnetobject'
]

{ #category : #gem }
GsNetworkResource class >> newDebugGemOnHost: aHost netldi: aNetldi [
"Creates a new instance with a debug gem resource, directory and log patterns."
^self newWithName: self debugGemResourceName  host: aHost netldi: aNetldi

]

{ #category : #gem }
GsNetworkResource class >> newDefaultGemOnHost: aHost netldi: aNetldi [
"Creates a new instance with default gem resource, directory and log patterns."
^self newWithName: self defaultGemResourceName  host: aHost netldi: aNetldi

]

{ #category : #stone }
GsNetworkResource class >> newForStoneNamed: stoneName host: aHost netldi: aNetldi [

"Creates a new instance with default directory and log patterns."
^self newWithName: stoneName host: aHost netldi: aNetldi dirPattern: nil logPattern: nil

]

{ #category : #'instance creation' }
GsNetworkResource class >> newWithName: aName host: aHost netldi: aNetldi [

"Creates a new instance with default directory and log patterns."
^self newWithName: aName host: aHost netldi: aNetldi dirPattern: nil logPattern: nil

]

{ #category : #'instance creation' }
GsNetworkResource class >> newWithName: aName host: aHost netldi: aNetldi dirPattern: aDirPattern logPattern: aLogPattern [
"Creates a new instance"
^ self new 
	name: aName ;
	host: aHost ;
	netldi: aNetldi ;
	dirPattern: aDirPattern ;
	logPattern: aLogPattern ;
	yourself 
				
]

{ #category : #converting }
GsNetworkResource >> asNrsString [

|ws|
ws := WriteStream on: String new.
ws nextPutAll: '!@' ;
	nextPutAll: self host ;
	nextPutAll: '#netldi:' ;
	nextPutAll: self netldi.
	self logPattern ifNotNil: [ ws nextPutAll: '#log:' ; nextPutAll: self logPattern].
	self dirPattern ifNotNil: [ ws nextPutAll: '#dir:' ; nextPutAll: self dirPattern].
	ws nextPut: $! ;
		nextPutAll: self name.
	^ws contents
]

{ #category : #accessing }
GsNetworkResource >> dirPattern [
	^ dirPattern
]

{ #category : #accessing }
GsNetworkResource >> dirPattern: anObject [
	dirPattern := anObject
]

{ #category : #accessing }
GsNetworkResource >> host [
	^ host
]

{ #category : #accessing }
GsNetworkResource >> host: anObject [
	host := anObject
]

{ #category : #accessing }
GsNetworkResource >> logPattern [
	^ logPattern
]

{ #category : #accessing }
GsNetworkResource >> logPattern: anObject [
	logPattern := anObject
]

{ #category : #accessing }
GsNetworkResource >> name [
	^ name
]

{ #category : #accessing }
GsNetworkResource >> name: anObject [
	name := anObject
]

{ #category : #accessing }
GsNetworkResource >> netldi [
	^ netldi
]

{ #category : #accessing }
GsNetworkResource >> netldi: anObject [
	netldi := anObject asString
]
