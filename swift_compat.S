.data
.globl __swift_FORCE_LOAD_$_swiftCoreAudio
__swift_FORCE_LOAD_$_swiftCoreAudio:
    .quad 0

.globl __swift_FORCE_LOAD_$_swiftCoreFoundation
__swift_FORCE_LOAD_$_swiftCoreFoundation:
    .quad 0

.globl __swift_FORCE_LOAD_$_swiftCoreImage
__swift_FORCE_LOAD_$_swiftCoreImage:
    .quad 0

.globl __swift_FORCE_LOAD_$_swiftCoreMIDI
__swift_FORCE_LOAD_$_swiftCoreMIDI:
    .quad 0

.globl __swift_FORCE_LOAD_$_swiftCoreMedia
__swift_FORCE_LOAD_$_swiftCoreMedia:
    .quad 0

.text
.globl _swift_getTypeByMangledNameInContext2
_swift_getTypeByMangledNameInContext2:
#if defined(__x86_64__)
    jmp _swift_getTypeByMangledNameInContext
#elif defined(__aarch64__)
    b _swift_getTypeByMangledNameInContext
#endif

.globl _swift_getTypeByMangledNameInContextInMetadataState2
_swift_getTypeByMangledNameInContextInMetadataState2:
#if defined(__x86_64__)
    mov %rsi, %rdi
    mov %rdx, %rsi
    mov %rcx, %rdx
    mov %r8, %rcx
    jmp _swift_getTypeByMangledNameInContext
#elif defined(__aarch64__)
    mov x0, x1
    mov x1, x2
    mov x2, x3
    mov x3, x4
    b _swift_getTypeByMangledNameInContext
#endif

.globl _$ss12_ArrayBufferV19_getElementSlowPathyyXlSiFyXl_Ts5
_$ss12_ArrayBufferV19_getElementSlowPathyyXlSiFyXl_Ts5:
#if defined(__x86_64__)
    jmp _$ss12_ArrayBufferV19_getElementSlowPathyyXlSiF
#elif defined(__aarch64__)
    b _$ss12_ArrayBufferV19_getElementSlowPathyyXlSiF
#endif
