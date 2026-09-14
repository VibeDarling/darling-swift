.data
.globl __swift_FORCE_LOAD_$_swiftUniformTypeIdentifiers
__swift_FORCE_LOAD_$_swiftUniformTypeIdentifiers:
    .quad 0

tag_name:
    .asciz "UTTagClass"
type_name:
    .asciz "UTType"

.p2align 3
.globl _$s22UniformTypeIdentifiers10UTTagClassVMn
_$s22UniformTypeIdentifiers10UTTagClassVMn:
    .long 0x00000041   // Flags: Struct | IsUnique (not generic)
    .long 0   // Parent
    .long (tag_name - .)   // Name (relative pointer)
    .long (_$s22UniformTypeIdentifiers10UTTagClassVMa - .)   // Access function
    .long 0   // FieldDescriptor
    .long 0   // NumFields
    .long 0   // FieldOffsetVectorOffset

.p2align 3
.globl _$s22UniformTypeIdentifiers6UTTypeVMn
_$s22UniformTypeIdentifiers6UTTypeVMn:
    .long 0x00000041   // Flags: Struct | IsUnique (not generic)
    .long 0   // Parent
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

.p2align 3
.globl _$s22UniformTypeIdentifiers10UTTagClassVN
_$s22UniformTypeIdentifiers10UTTagClassVN:
    .quad _$sBOWV
uttagclass_metadata:
    .quad 0x200   // Struct kind
    .quad _$s22UniformTypeIdentifiers10UTTagClassVMn

.p2align 3
.globl _$s22UniformTypeIdentifiers6UTTypeVN
_$s22UniformTypeIdentifiers6UTTypeVN:
    .quad _$sBOWV
uttype_metadata:
    .quad 0x200   // Struct kind
    .quad _$s22UniformTypeIdentifiers6UTTypeVMn

.text
.p2align 2
.globl _$s22UniformTypeIdentifiers10UTTagClassV17filenameExtensionACvgZ
_$s22UniformTypeIdentifiers10UTTagClassV17filenameExtensionACvgZ:
#if defined(__x86_64__)
    xor %rax, %rax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s22UniformTypeIdentifiers10UTTagClassVMa
_$s22UniformTypeIdentifiers10UTTagClassVMa:
#if defined(__x86_64__)
    lea uttagclass_metadata(%rip), %rax
    ret
#elif defined(__aarch64__)
    adrp x0, uttagclass_metadata@PAGE
    add x0, x0, uttagclass_metadata@PAGEOFF
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV10identifierSSvg
_$s22UniformTypeIdentifiers6UTTypeV10identifierSSvg:
#if defined(__x86_64__)
    xor %eax, %eax
    xor %edx, %edx
    ret
#elif defined(__aarch64__)
    mov x0, #0
    mov x1, #0
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV17filenameExtension12conformingToACSgSS_ACtcfC
_$s22UniformTypeIdentifiers6UTTypeV17filenameExtension12conformingToACSgSS_ACtcfC:
#if defined(__x86_64__)
    xor %rax, %rax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV19_bridgeToObjectiveCSoABCyF
_$s22UniformTypeIdentifiers6UTTypeV19_bridgeToObjectiveCSoABCyF:
#if defined(__x86_64__)
    xor %rax, %rax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV4dataACvgZ
_$s22UniformTypeIdentifiers6UTTypeV4dataACvgZ:
#if defined(__x86_64__)
    xor %rax, %rax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeV4tagsSDyAA10UTTagClassVSaySSGGvg
_$s22UniformTypeIdentifiers6UTTypeV4tagsSDyAA10UTTagClassVSaySSGGvg:
#if defined(__x86_64__)
    jmp _$ss22__RawDictionaryStorageC5emptys07__EmptyB9SingletonCvgZ
#elif defined(__aarch64__)
    b _$ss22__RawDictionaryStorageC5emptys07__EmptyB9SingletonCvgZ
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
    ret
#elif defined(__aarch64__)
    adrp x0, uttype_metadata@PAGE
    add x0, x0, uttype_metadata@PAGEOFF
    ret
#endif

.globl _$s22UniformTypeIdentifiers6UTTypeVyACSgSScfC
_$s22UniformTypeIdentifiers6UTTypeVyACSgSScfC:
#if defined(__x86_64__)
    xor %rax, %rax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
