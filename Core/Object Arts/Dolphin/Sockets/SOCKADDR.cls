﻿"Filed out from Dolphin Smalltalk 7"!

ExternalStructure subclass: #SOCKADDR
	instanceVariableNames: ''
	classVariableNames: '_OffsetOf_sa_data _OffsetOf_sa_family'
	poolDictionaries: 'WinSocketConstants'
	classInstanceVariableNames: ''!
SOCKADDR guid: (GUID fromString: '{0299d3de-9695-4177-9ce6-42ad495c8e57}')!
SOCKADDR addClassConstant: '_OffsetOf_sa_data' value: 16r2!
SOCKADDR addClassConstant: '_OffsetOf_sa_family' value: 16r0!
SOCKADDR comment: '<SOCKADDR> is an <ExternalStructure> class to wrap the struct ''Win32.SOCKADDR'' from type information in the ''Win32 API'' library.

The type library contains the following helpstring for this struct
	"Structure used by kernel to store most addresses."

Warning: This comment was automatically generated from the struct''s type information, but any changes made here will not be overwritten if the wrapper class is regenerated.

IDL definition follows:

typedef [uuid(0299D3DE-9695-4177-9CE6-42AD495C8E57), helpstring("Structure used by kernel to store most addresses.")]
struct tagSOCKADDR {
	[helpstring("Address family; AF_INET if an IPv4 address, AF_INET6 if IPv6")] ADDRESS_FAMILY sa_family;
	[hidden, helpstring("Up to 14 bytes of direct address (note in network order, not host order)")] char sa_data[14];
} SOCKADDR;
'!
!SOCKADDR categoriesForClass!Win32-Structs! !
!SOCKADDR methodsFor!

displayOn: aStream
	"Append to the <puttableStream>, aStream, a <String> whose characters are a representation
	of the receiver as a user would want to see it. In this case we print the address in the
	standard IPv4 or IPv6 format."

	| buf len |
	(self isNull or: [self sa_family == 0]) ifTrue: [^self].
	buf := String newFixed: INET6_ADDRSTRLEN.
	len := DWORDBytes fromInteger: buf size.
	(WS2_32Library default
		wsaAddressToStringA: bytes
		dwAddressLength: self byteSize
		lpProtocolInfo: nil
		lpszAddressString: buf
		lpdwAddressStringLength: len) == 0
		ifFalse: [SocketError signal].
	aStream
		next: len value - 1
		putAll: buf
		startingAt: 1!

initialize
	self sa_family: self class addressFamily!

printFieldsOn: aStream limit: anInteger
	self isNull ifTrue: [aStream nextPutAll: 'NULL'] ifFalse: [self displayOn: aStream]!

sa_family
	"Answer the <Integer> value of the receiver's 'sa_family' field."

	^bytes wordAtOffset: _OffsetOf_sa_family!

sa_family: anInteger
	"Set the receiver's 'sa_family' field to the value of the argument, anInteger"

	bytes wordAtOffset: _OffsetOf_sa_family put: anInteger! !
!SOCKADDR categoriesFor: #displayOn:!displaying!public! !
!SOCKADDR categoriesFor: #initialize!initializing!private! !
!SOCKADDR categoriesFor: #printFieldsOn:limit:!development!printing!private! !
!SOCKADDR categoriesFor: #sa_family!**compiled accessors**!public! !
!SOCKADDR categoriesFor: #sa_family:!**compiled accessors**!public! !

!SOCKADDR class methodsFor!

addressFamily
	^AF_INET!

defineFields
	"Define the fields of the SOCKADDR structure.

	SOCKADDR compileDefinition

		typedef [uuid(0299d3de-9695-4177-9ce6-42ad495c8e57), helpstring('Structure used by kernel to store most addresses.')]
		struct tagSOCKADDR {
			[helpstring('Address family; AF_INET if an IPv4 address, AF_INET6 if IPv6')] ADDRESS_FAMILY sa_family;
			[hidden, helpstring('Up to 14 bytes of direct address (note in network order, not host order)')] BYTE sa_data[14];
		} SOCKADDR;
"

	self
		defineField: #sa_family type: WORDField new offset: 0;
		defineField: #sa_data type: (ArrayField type: ExternalArray length: 14) beFiller offset: 2.
	self byteSize: 16!

fromAddress: anAddress
	"Answer a new sub-instance of the correct type to represent the the IP address structure
	stored at the specified memory location."

	| family ptr |
	anAddress isNull ifTrue: [^nil].
	ptr := anAddress asExternalAddress.
	family := ptr wordAtOffset: 0.
	^(family == AF_INET
		ifTrue: [SOCKADDR_IN]
		ifFalse: [family == AF_INET6 ifTrue: [SOCKADDR_IN6] ifFalse: [SOCKADDR]]) basicNew
		initializeAtAddress: ptr!

fromString: aString
	"Answer a new sub-instance of the correct type to describe the IP address represented by the <String> argument.
		self fromString: '192.168.1.6:80'.
		(self fromString: '[fe80::a221:b7ff:fe70:6185%7]:443') 
	"

	| buf ret family |
	buf := NET_ADDRESS_INFO newBuffer.
	ret := IpHlpApiLibrary default
				parseNetworkString: aString
				types: ##(NET_STRING_IP_ADDRESS | NET_STRING_IP_SERVICE)
				addressInfo: buf
				portNumber: nil
				prefixLength: nil.
	ret == 0
		ifFalse: 
			[^ret == Win32Errors.ERROR_INVALID_PARAMETER
				ifTrue: [InvalidFormat signalWith: self]
				ifFalse: [Win32Error signalWith: ret]].
	family := buf Format.
	^(family == NET_ADDRESS_IPV6
		ifTrue: [buf Ipv6Address]
		ifFalse: [family == NET_ADDRESS_IPV4 ifTrue: [buf Ipv4Address] ifFalse: [buf IpAddress]]) copy!

getFieldNames
	^#(#sa_family)! !
!SOCKADDR class categoriesFor: #addressFamily!constants!public! !
!SOCKADDR class categoriesFor: #defineFields!**auto generated**!public!template definition! !
!SOCKADDR class categoriesFor: #fromAddress:!instance creation!public! !
!SOCKADDR class categoriesFor: #fromString:!public! !
!SOCKADDR class categoriesFor: #getFieldNames!**compiled accessors**!constants!private! !

