Extension { #name : #FFICalloutAPI }

{ #category : #'*GemStoneFFI' }
FFICalloutAPI >> function: functionSignature library: moduleNameOrLibrary [
	| sender ffiMethod ffiMethodSelector |
	sender := self senderContext.
	ffiMethodSelector := self uFFIEnterMethodSelector.	"Build new method"
	ffiMethod := self newBuilder
		build: [ :builder | 
			builder
				signature: functionSignature;
				sender: sender;
				library: moduleNameOrLibrary ].
	ffiMethod
		selector: sender selector;
		methodClass: sender methodClass.	"Replace with generated ffi method, but save old one for future use"
	ffiMethod
		propertyValueAt: #ffiNonCompiledMethod
		put: (sender methodClass methodDict at: sender selector).	"For senders search, one need to keep the selector in the properties"
	ffiMethod propertyValueAt: #ffiMethodSelector put: ffiMethodSelector.
	"Norm Green: Disable next 2 lines in GemStoneFFI. Otherwise the moduleNameOrLibrary arg is ignored after the first invocation and Pharo caches the function pointer."
	"This becomes a problem when we change GCI versions for differente sessions."
"	sender methodClass methodDict at: sender selector put: ffiMethod.	
	FFIMethodRegistry uniqueInstance registerMethod: ffiMethod . "
	
	sender
		return: (sender receiver withArgs: sender arguments executeMethod: ffiMethod).
	^ self
]
