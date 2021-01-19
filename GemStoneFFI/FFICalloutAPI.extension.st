Extension { #name : #FFICalloutAPI }

{ #category : #'*GemStoneFFI' }
FFICalloutAPI >> function: functionSignature library: moduleNameOrLibrary [

	| sender ffiMethod ffiMethodSelector |
	sender := self senderContext.
	ffiMethodSelector := self uFFIEnterMethodSelector. "Build new method"
	ffiMethod := self newBuilder build: [ :builder | 
		             builder
			             signature: functionSignature;
			             sender: sender;
			             library: moduleNameOrLibrary ].
	ffiMethod
		selector: sender selector;
		methodClass: sender methodClass. "Replace with generated ffi method, but save old one for future use"
	ffiMethod
		propertyAt: #ffiNonCompiledMethod
		put: (sender methodClass methodDict at: sender selector). "For senders search, one need to keep the selector in the properties"
	ffiMethod propertyAt: #ffiMethodSelector put: ffiMethodSelector.
	"Norm Green: Disable replacing our FFI compiled method for GCI libraries, otherwise the moduleNameOrLibrary arg is ignored after the first invocation 
	and Pharo caches the function pointer in the new compile method.
	This becomes a problem when we change GCI versions and the wrong GCI library is called!
	If there's a better way to do this I'd love to know about it."
	( '*libgci*' match: moduleNameOrLibrary libraryName)
		ifFalse:[
			sender methodClass methodDict at: sender selector put: ffiMethod.	
			FFIMethodRegistry uniqueInstance registerMethod: ffiMethod .
		].

	sender return:
		(sender receiver withArgs: sender arguments executeMethod: ffiMethod).
	^ self
]
