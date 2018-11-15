"
I'm an extension of FFIExternalStructure.
I am packing tightly all of my fields.
"
Class {
	#name : #FFIExternalPackedStructure,
	#superclass : #FFIExternalStructure,
	#category : #'UnifiedFFI-Objects'
}

{ #category : #private }
FFIExternalPackedStructure class >> compileFields: specArray withAccessors: defineBoolean [
	| offset fieldSpec |
			
	fieldSpec := self fieldSpec.
	offset := 0.	
	externalStructureAlignment := self packedStructureAlignment.
	fieldSpec fieldsAndTypesDo: [ :fieldName :type | 
		self defineFieldOffset: fieldName value: offset + 1.  
		(defineBoolean and: [ fieldName isSymbol ]) ifTrue: [ 
			self defineFieldAccessorsFor: fieldName type: type ]. 
		offset := offset + type typeSize.
	].
	offset := offset alignedTo: externalStructureAlignment.
	
	"Real compiled spec is the compiled spec of fields plus a header with structure size and 
	 structure flag"
	"Temporal type to ensure cyclic (pointer) references will work (case of linked lists, 
	 for example). I do not like it, but it works :S"
	compiledSpec := {ExternalType pointerSpec}. 
	"Now I can reconsider it"
	compiledSpec := fieldSpec compileSpec copyWithFirst: (offset bitOr: FFIFlagStructure).
	ExternalType noticeModificationOf: self.
	^ compiledSpec
]

{ #category : #'register marshalling' }
FFIExternalPackedStructure class >> emitFlatStructureLayoutInto: flatStructureLayout [
	flatStructureLayout addMemoryFieldSize: self structureSize alignment: self structureAlignment
]

{ #category : #accessing }
FFIExternalPackedStructure class >> packedStructureAlignment [
	^ 1
]