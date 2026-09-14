// Stand-ins for the parts of Apple's UniformTypeIdentifiers Swift overlay that apps bind to.
//
// Apps compile against the resilient overlay, so UTType and UTTagClass are address-only to them: values
// are returned through the indirect-result register (arm64 x8, x86_64 rax), `self` arrives by address
// (x20, r13) and initializer arguments are owned. Both types use Builtin.NativeObject's value witnesses
// (one strong reference; null is Optional.none). Every UTType and UTTagClass value made here holds the
// runtime's immortal empty-dictionary singleton, so copying or destroying one is a no-op.
//
//   UTType.data, UTTagClass.filenameExtension                that placeholder value
//   UTType.init(_:), UTType.init(filenameExtension:conformingTo:)   nil
//   UTType.identifier                                        ""
//   UTType.tags                                              [:]
//   UTType.isDynamic                                         false
//   UTType._bridgeToObjectiveC()                             UTTypeData from UniformTypeIdentifiers.framework

.data
.globl __swift_FORCE_LOAD_$_swiftUniformTypeIdentifiers
__swift_FORCE_LOAD_$_swiftUniformTypeIdentifiers:
    .quad 0

module_name:
    .asciz "UniformTypeIdentifiers"
tag_name:
    .asciz "UTTagClass"
type_name:
    .asciz "UTType"

.p2align 2
module_descriptor:
    .long 0x00000000   // Flags: Module
    .long 0   // Parent
    .long (module_name - .)   // Name (relative pointer)

.p2align 3
.globl _$s22UniformTypeIdentifiers10UTTagClassVMn
_$s22UniformTypeIdentifiers10UTTagClassVMn:
    .long 0x00000051   // Flags: Struct | IsUnique (not generic)
    .long (module_descriptor - .)   // Parent (relative pointer)
    .long (tag_name - .)   // Name (relative pointer)
    .long (_$s22UniformTypeIdentifiers10UTTagClassVMa - .)   // Access function
    .long 0   // FieldDescriptor
    .long 0   // NumFields
    .long 0   // FieldOffsetVectorOffset

.p2align 3
.globl _$s22UniformTypeIdentifiers6UTTypeVMn
_$s22UniformTypeIdentifiers6UTTypeVMn:
    .long 0x00000051   // Flags: Struct | IsUnique (not generic)
    .long (module_descriptor - .)   // Parent (relative pointer)
    .long (type_name - .)   // Name (relative pointer)
    .long (_$s22UniformTypeIdentifiers6UTTypeVMa - .)   // Access function
    .long 0   // FieldDescriptor
    .long 0   // NumFields
    .long 0   // FieldOffsetVectorOffset

.p2align 3
.globl _$s22UniformTypeIdentifiers10UTTagClassVSHAAMc
_$s22UniformTypeIdentifiers10UTTagClassVSHAAMc:
    .long 0x80000000   // protocol: null relative pointer
    .long 0x80000000   // typeRef: null relative pointer
    .long 0x80000000   // witnessTable: null relative pointer
    .long 0   // flags

.p2align 3
.globl _$s22UniformTypeIdentifiers10UTTagClassVSQAAMc
_$s22UniformTypeIdentifiers10UTTagClassVSQAAMc:
    .long 0x80000000   // protocol: null relative pointer
    .long 0x80000000   // typeRef: null relative pointer
    .long 0x80000000   // witnessTable: null relative pointer
    .long 0   // flags

.p2align 3
.globl _$s22UniformTypeIdentifiers10UTTagClassVs23CustomStringConvertibleAAMc
_$s22UniformTypeIdentifiers10UTTagClassVs23CustomStringConvertibleAAMc:
    .long 0x80000000   // protocol: null relative pointer
    .long 0x80000000   // typeRef: null relative pointer
    .long 0x80000000   // witnessTable: null relative pointer
    .long 0   // flags

// The type metadata symbols name the kind word; the value witness table pointer sits just before it.
.p2align 3
    .quad _$sBOWV
.globl _$s22UniformTypeIdentifiers10UTTagClassVN
_$s22UniformTypeIdentifiers10UTTagClassVN:
uttagclass_metadata:
    .quad 0x200   // Struct kind
    .quad _$s22UniformTypeIdentifiers10UTTagClassVMn

.p2align 3
    .quad _$sBOWV
.globl _$s22UniformTypeIdentifiers6UTTypeVN
_$s22UniformTypeIdentifiers6UTTypeVN:
uttype_metadata:
    .quad 0x200   // Struct kind
    .quad _$s22UniformTypeIdentifiers6UTTypeVMn

.text
.p2align 2
.globl _$s22UniformTypeIdentifiers10UTTagClassV17filenameExtensionACvgZ
.globl _$s22UniformTypeIdentifiers6UTTypeV4dataACvgZ
_$s22UniformTypeIdentifiers10UTTagClassV17filenameExtensionACvgZ:
_$s22UniformTypeIdentifiers6UTTypeV4dataACvgZ:
#if defined(__x86_64__)
    movq __swiftEmptyDictionarySingleton@GOTPCREL(%rip), %rcx
    movq %rcx, (%rax)
    ret
#elif defined(__aarch64__)
    adrp x9, __swiftEmptyDictionarySingleton@GOTPAGE
    ldr x9, [x9, __swiftEmptyDictionarySingleton@GOTPAGEOFF]
    str x9, [x8]
    ret
#endif

.globl _$s22UniformTypeIdentifiers10UTTagClassVMa
_$s22UniformTypeIdentifiers10UTTagClassVMa:
#if defined(__x86_64__)
    lea uttagclass_metadata(%rip), %rax
    xor %edx, %edx   // MetadataState::Complete
    ret
#elif defined(__aarch64__)
    adrp x0, uttagclass_metadata@PAGE
    add x0, x0, uttagclass_metadata@PAGEOFF
    mov x1, #0   // MetadataState::Complete
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV10identifierSSvg
_$s22UniformTypeIdentifiers6UTTypeV10identifierSSvg:
#if defined(__x86_64__)
    xor %eax, %eax
    movabsq $0xE000000000000000, %rdx   // empty small string
    ret
#elif defined(__aarch64__)
    mov x0, #0
    mov x1, #0xE000000000000000   // empty small string
    ret
#endif

// The String argument is owned and released here. The UTType argument of init(filenameExtension:conformingTo:)
// is owned too, but it can only be one of the immortal values above.
.globl _$s22UniformTypeIdentifiers6UTTypeV17filenameExtension12conformingToACSgSS_ACtcfC
.globl _$s22UniformTypeIdentifiers6UTTypeVyACSgSScfC
_$s22UniformTypeIdentifiers6UTTypeV17filenameExtension12conformingToACSgSS_ACtcfC:
_$s22UniformTypeIdentifiers6UTTypeVyACSgSScfC:
#if defined(__x86_64__)
    movq $0, (%rax)
    movq %rsi, %rdi
    jmp _swift_bridgeObjectRelease
#elif defined(__aarch64__)
    str xzr, [x8]
    mov x0, x1
    b _swift_bridgeObjectRelease
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV19_bridgeToObjectiveCSoABCyF
_$s22UniformTypeIdentifiers6UTTypeV19_bridgeToObjectiveCSoABCyF:
#if defined(__x86_64__)
    movq _UTTypeData@GOTPCREL(%rip), %rdi
    movq (%rdi), %rdi
    jmp _objc_retain
#elif defined(__aarch64__)
    adrp x0, _UTTypeData@GOTPAGE
    ldr x0, [x0, _UTTypeData@GOTPAGEOFF]
    ldr x0, [x0]
    b _objc_retain
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV4tagsSDyAA10UTTagClassVSaySSGGvg
_$s22UniformTypeIdentifiers6UTTypeV4tagsSDyAA10UTTagClassVSaySSGGvg:
#if defined(__x86_64__)
    movq __swiftEmptyDictionarySingleton@GOTPCREL(%rip), %rax
    ret
#elif defined(__aarch64__)
    adrp x0, __swiftEmptyDictionarySingleton@GOTPAGE
    ldr x0, [x0, __swiftEmptyDictionarySingleton@GOTPAGEOFF]
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV9isDynamicSbvg
_$s22UniformTypeIdentifiers6UTTypeV9isDynamicSbvg:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov w0, #0
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeVMa
_$s22UniformTypeIdentifiers6UTTypeVMa:
#if defined(__x86_64__)
    lea uttype_metadata(%rip), %rax
    xor %edx, %edx   // MetadataState::Complete
    ret
#elif defined(__aarch64__)
    adrp x0, uttype_metadata@PAGE
    add x0, x0, uttype_metadata@PAGEOFF
    mov x1, #0   // MetadataState::Complete
    ret
#endif
