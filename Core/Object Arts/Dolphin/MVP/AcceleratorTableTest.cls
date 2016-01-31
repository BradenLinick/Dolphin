"Filed out from Dolphin Smalltalk 7"!

DolphinTest subclass: #AcceleratorTableTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: 'Win32Constants'
	classInstanceVariableNames: ''!
AcceleratorTableTest guid: (GUID fromString: '{FFC00C13-8DA5-4B75-B82D-F96BBA254EFE}')!
AcceleratorTableTest comment: ''!
!AcceleratorTableTest categoriesForClass!Unclassified! !
!AcceleratorTableTest methodsFor!

testKeycodeFromString
	"for alphanumerics, the keycode corresponds with the ascii code point"

	($A codePoint to: $Z codePoint) , ($0 codePoint to: $9 codePoint) do: 
			[:each | 
			| code keyString |
			code := each | (FVIRTKEY << 9).
			keyString := (Character value: each) asString.
			self assert: code = (AcceleratorTable keyCodeFromString: keyString).
			self assert: (code | (FCONTROL << 9)) = (AcceleratorTable keyCodeFromString: 'Ctrl+' , keyString).
			self assert: (code | (FSHIFT << 9)) = (AcceleratorTable keyCodeFromString: 'Shift+' , keyString).
			self assert: (code | (FALT << 9)) = (AcceleratorTable keyCodeFromString: 'Alt+' , keyString).
			self assert: (code | ((FSHIFT | FCONTROL) << 9)) 
						= (AcceleratorTable keyCodeFromString: 'Ctrl+Shift+' , keyString)].
	"Other keys where the VK code is not the Ascii codepoint"
	(Array 
		with: ',' -> VK_OEM_COMMA
		with: '-' -> VK_OEM_MINUS
		with: '.' -> VK_OEM_PERIOD) 
			, ((1 to: 9) collect: [:each | ('NUM ' , each displayString) -> (VK_NUMPAD1 + each - 1)]) do: 
				[:each | 
				| code keyString |
				code := each value | (FVIRTKEY << 9).
				keyString := each key.
				self assert: code = (AcceleratorTable keyCodeFromString: keyString).
				self assert: (code | (FCONTROL << 9)) = (AcceleratorTable keyCodeFromString: 'Ctrl+' , keyString).
				self assert: (code | (FSHIFT << 9)) = (AcceleratorTable keyCodeFromString: 'Shift+' , keyString).
				self assert: (code | (FALT << 9)) = (AcceleratorTable keyCodeFromString: 'Alt+' , keyString).
				self assert: (code | ((FSHIFT | FCONTROL) << 9)) 
							= (AcceleratorTable keyCodeFromString: 'Ctrl+Shift+' , keyString)].
	"		with: '+' -> VK_OEM_PLUS"
	"Extended keys"
	(Array 
		with: 'END' -> VK_END
		with: 'DOWN' -> VK_DOWN
		with: 'PGUP' -> VK_PRIOR) do: 
				[:each | 
				| code keyString |
				code := each value | 16r100 | (FVIRTKEY << 9).
				keyString := each key.
				self assert: code = (AcceleratorTable keyCodeFromString: keyString).
				self assert: (code | (FCONTROL << 9)) = (AcceleratorTable keyCodeFromString: 'Ctrl+' , keyString).
				self assert: (code | (FSHIFT << 9)) = (AcceleratorTable keyCodeFromString: 'Shift+' , keyString).
				self assert: (code | (FALT << 9)) = (AcceleratorTable keyCodeFromString: 'Alt+' , keyString).
				self assert: (code | ((FSHIFT | FCONTROL) << 9)) 
							= (AcceleratorTable keyCodeFromString: 'Ctrl+Shift+' , keyString)].
	#(#('CTRL+NUM 1' 4705) #('PAUSE' 531)) do: 
			[:each | 
			self assert: each last = (AcceleratorTable keyCodeFromString: each first).
			self]! !
!AcceleratorTableTest categoriesFor: #testKeycodeFromString!public!unit tests! !
