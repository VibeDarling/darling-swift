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

.globl __swift_classIsSwiftMask
__swift_classIsSwiftMask:
    .quad 2

.text
.p2align 2
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

.globl _$s2os6LoggerV9logObjectSo03OS_a1_C0Cvg
_$s2os6LoggerV9logObjectSo03OS_a1_C0Cvg:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s2os6LoggerV9subsystem8categoryACSS_SStcfC
_$s2os6LoggerV9subsystem8categoryACSS_SStcfC:
#if defined(__x86_64__)
    xorps %xmm0, %xmm0
    movups %xmm0, (%rdi)
    movups %xmm0, 16(%rdi)
    ret
#elif defined(__aarch64__)
    stp xzr, xzr, [x8]
    stp xzr, xzr, [x8, #16]
    ret
#endif

.globl _$s2os6LoggerVMa
_$s2os6LoggerVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    xor %edx, %edx
    ret
#elif defined(__aarch64__)
    mov x0, #0
    mov x1, #0
    ret
#endif

.data
.globl _$s2os6LoggerVMn
_$s2os6LoggerVMn:
    .quad 0, 0, 0, 0

.text
.globl _$s2os0A4_log_3dso0B04type_ys12StaticStringV_SVSgSo03OS_a1_B0CSo0a1_b1_D2_tas7CVarArg_pdtF
_$s2os0A4_log_3dso0B04type_ys12StaticStringV_SVSgSo03OS_a1_B0CSo0a1_b1_D2_tas7CVarArg_pdtF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$sSo17NSKeyedUnarchiverC10FoundationE24unarchivedArrayOfObjects7ofClass4fromSayxGSgxm_AC4DataVtKSo8NSObjectCRbzSo14NSSecureCodingRzlFZ
_$sSo17NSKeyedUnarchiverC10FoundationE24unarchivedArrayOfObjects7ofClass4fromSayxGSgxm_AC4DataVtKSo8NSObjectCRbzSo14NSSecureCodingRzlFZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.data
.globl _$s12CoreGraphics7CGFloatVMn
_$s12CoreGraphics7CGFloatVMn:
    .quad 0, 0, 0, 0

.globl _$s12CoreGraphics7CGFloatVN
_$s12CoreGraphics7CGFloatVN:
    .quad 0, 0, 0, 0

.globl _$s12CoreGraphics7CGFloatVSeAAMc
_$s12CoreGraphics7CGFloatVSeAAMc:
    .quad 0, 0, 0, 0

.globl _$s12CoreGraphics7CGFloatVSEAAMc
_$s12CoreGraphics7CGFloatVSEAAMc:
    .quad 0, 0, 0, 0

.globl _$s12CoreGraphics7CGFloatVSQAAMc
_$s12CoreGraphics7CGFloatVSQAAMc:
    .quad 0, 0, 0, 0

.text
.globl _NSIntegralRectWithOptions
_NSIntegralRectWithOptions:
#if defined(__x86_64__)
    xorps %xmm0, %xmm0
    movups %xmm0, (%rdi)
    movups %xmm0, 16(%rdi)
    ret
#elif defined(__aarch64__)
    stp xzr, xzr, [x8]
    stp xzr, xzr, [x8, #16]
    ret
#endif

.data
.globl _NSToolbarSidebarTrackingSeparatorItemIdentifier
_NSToolbarSidebarTrackingSeparatorItemIdentifier:
    .quad 0

.globl _NSURLContentTypeKey
_NSURLContentTypeKey:
    .quad 0

.globl _OBJC_CLASS_$_NSTrackingSeparatorToolbarItem
_OBJC_CLASS_$_NSTrackingSeparatorToolbarItem:
    .space 80, 0

.globl _OBJC_METACLASS_$_NSTrackingSeparatorToolbarItem
_OBJC_METACLASS_$_NSTrackingSeparatorToolbarItem:
    .space 80, 0

.text
.globl _$s7Combine10PublishersO8SequenceVAASlRzs5NeverORs_rlE5firstSqAAE9PublisherVy7ElementQz_GyF
_$s7Combine10PublishersO8SequenceVAASlRzs5NeverORs_rlE5firstSqAAE9PublisherVy7ElementQz_GyF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s7Combine16ObservableObjectP7SwiftUIE15focusedValueKeys08WritableH4PathCyAD13FocusedValuesVxSgGvgZ
_$s7Combine16ObservableObjectP7SwiftUIE15focusedValueKeys08WritableH4PathCyAD13FocusedValuesVxSgGvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.globl _$s7Combine16ObservableObjectP7SwiftUIE16environmentStores15WritableKeyPathCyAD17EnvironmentValuesVxSgGvgZ
_$s7Combine16ObservableObjectP7SwiftUIE16environmentStores15WritableKeyPathCyAD17EnvironmentValuesVxSgGvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

.data
.globl _$sSq7CombineE9PublisherVMn
_$sSq7CombineE9PublisherVMn:
    .quad 0, 0, 0, 0

/* Autogenerated stubs for newer Foundation symbols */
.text
.globl _$s10Foundation17URLResourceValuesV22UniformTypeIdentifiersE07contentE0AD6UTTypeVSgvg
_$s10Foundation17URLResourceValuesV22UniformTypeIdentifiersE07contentE0AD6UTTypeVSgvg:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation24FloatingPointFormatStyleV6localeACyxGAA6LocaleV_tcfC
_$s10Foundation24FloatingPointFormatStyleV6localeACyxGAA6LocaleV_tcfC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$s10Foundation24FloatingPointFormatStyleVMn
_$s10Foundation24FloatingPointFormatStyleVMn:
    .quad 0, 0, 0, 0
.data
.globl _$s10Foundation24FloatingPointFormatStyleVyxGAA09ParseabledE0AAMc
_$s10Foundation24FloatingPointFormatStyleVyxGAA09ParseabledE0AAMc:
    .quad 0, 0, 0, 0
.text
.globl _$s10Foundation32FormatStyleCapitalizationContextV10standaloneACvgZ
_$s10Foundation32FormatStyleCapitalizationContextV10standaloneACvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation32FormatStyleCapitalizationContextV7unknownACvgZ
_$s10Foundation32FormatStyleCapitalizationContextV7unknownACvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation32FormatStyleCapitalizationContextVMa
_$s10Foundation32FormatStyleCapitalizationContextVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV13DirectoryHintO13inferFromPathyA2EmFWC
_$s10Foundation3URLV13DirectoryHintO13inferFromPathyA2EmFWC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV13DirectoryHintOMa
_$s10Foundation3URLV13DirectoryHintOMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV16libraryDirectoryACvgZ
_$s10Foundation3URLV16libraryDirectoryACvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV4path14percentEncodedSSSb_tF
_$s10Foundation3URLV4path14percentEncodedSSSb_tF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV6append9component13directoryHintyx_AC09DirectoryF0OtSyRzlF
_$s10Foundation3URLV6append9component13directoryHintyx_AC09DirectoryF0OtSyRzlF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV8filePath13directoryHint10relativeToACSS_AC09DirectoryF0OACSgtcfC
_$s10Foundation3URLV8filePath13directoryHint10relativeToACSS_AC09DirectoryF0OACSgtcfC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation3URLV9appending4path13directoryHintACx_AC09DirectoryF0OtSyRzlF
_$s10Foundation3URLV9appending4path13directoryHintACx_AC09DirectoryF0OtSyRzlF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV04TimeD0V9shortenedAGvgZ
_$s10Foundation4DateV11FormatStyleV04TimeD0V9shortenedAGvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV04TimeD0VMa
_$s10Foundation4DateV11FormatStyleV04TimeD0VMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$s10Foundation4DateV11FormatStyleV04TimeD0VMn
_$s10Foundation4DateV11FormatStyleV04TimeD0VMn:
    .quad 0, 0, 0, 0
.text
.globl _$s10Foundation4DateV11FormatStyleV0bD0V4longAGvgZ
_$s10Foundation4DateV11FormatStyleV0bD0V4longAGvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV0bD0VMa
_$s10Foundation4DateV11FormatStyleV0bD0VMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$s10Foundation4DateV11FormatStyleV0bD0VMn
_$s10Foundation4DateV11FormatStyleV0bD0VMn:
    .quad 0, 0, 0, 0
.text
.globl _$s10Foundation4DateV11FormatStyleV3dayyA2E6SymbolV3DayVF
_$s10Foundation4DateV11FormatStyleV3dayyA2E6SymbolV3DayVF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV4date4time6locale8calendar0F4Zone21capitalizationContextA2E0bD0VSg_AE04TimeD0VSgAA6LocaleVAA8CalendarVAA0lI0VAA0cd14CapitalizationK0VtcfC
_$s10Foundation4DateV11FormatStyleV4date4time6locale8calendar0F4Zone21capitalizationContextA2E0bD0VSg_AE04TimeD0VSgAA6LocaleVAA8CalendarVAA0lI0VAA0cd14CapitalizationK0VtcfC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV4houryA2E6SymbolV4HourVF
_$s10Foundation4DateV11FormatStyleV4houryA2E6SymbolV4HourVF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV4yearyA2E6SymbolV4YearVF
_$s10Foundation4DateV11FormatStyleV4yearyA2E6SymbolV4YearVF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV5monthyA2E6SymbolV5MonthVF
_$s10Foundation4DateV11FormatStyleV5monthyA2E6SymbolV5MonthVF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV3DayV9twoDigitsAIvgZ
_$s10Foundation4DateV11FormatStyleV6SymbolV3DayV9twoDigitsAIvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV3DayVMa
_$s10Foundation4DateV11FormatStyleV6SymbolV3DayVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV4HourV13defaultDigits4amPMA2I9AMPMStyleV_tFZ
_$s10Foundation4DateV11FormatStyleV6SymbolV4HourV13defaultDigits4amPMA2I9AMPMStyleV_tFZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV4HourV9AMPMStyleV11abbreviatedAKvgZ
_$s10Foundation4DateV11FormatStyleV6SymbolV4HourV9AMPMStyleV11abbreviatedAKvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV4HourV9AMPMStyleVMa
_$s10Foundation4DateV11FormatStyleV6SymbolV4HourV9AMPMStyleVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV4HourVMa
_$s10Foundation4DateV11FormatStyleV6SymbolV4HourVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV4YearV13defaultDigitsAIvgZ
_$s10Foundation4DateV11FormatStyleV6SymbolV4YearV13defaultDigitsAIvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV4YearVMa
_$s10Foundation4DateV11FormatStyleV6SymbolV4YearVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV5MonthV11abbreviatedAIvgZ
_$s10Foundation4DateV11FormatStyleV6SymbolV5MonthV11abbreviatedAIvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV5MonthVMa
_$s10Foundation4DateV11FormatStyleV6SymbolV5MonthVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV6MinuteV9twoDigitsAIvgZ
_$s10Foundation4DateV11FormatStyleV6SymbolV6MinuteV9twoDigitsAIvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6SymbolV6MinuteVMa
_$s10Foundation4DateV11FormatStyleV6SymbolV6MinuteVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV11FormatStyleV6minuteyA2E6SymbolV6MinuteVF
_$s10Foundation4DateV11FormatStyleV6minuteyA2E6SymbolV6MinuteVF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$s10Foundation4DateV11FormatStyleVAadAMc
_$s10Foundation4DateV11FormatStyleVAadAMc:
    .quad 0, 0, 0, 0
.text
.globl _$s10Foundation4DateV11FormatStyleVMa
_$s10Foundation4DateV11FormatStyleVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleV05UnitsE0V11abbreviatedAGvgZ
_$s10Foundation4DateV19RelativeFormatStyleV05UnitsE0V11abbreviatedAGvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleV05UnitsE0VMa
_$s10Foundation4DateV19RelativeFormatStyleV05UnitsE0VMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleV12PresentationV5namedAGvgZ
_$s10Foundation4DateV19RelativeFormatStyleV12PresentationV5namedAGvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleV12PresentationVMa
_$s10Foundation4DateV19RelativeFormatStyleV12PresentationVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleV12presentation05unitsE06locale8calendar21capitalizationContextA2E12PresentationV_AE05UnitsE0VAA6LocaleVAA8CalendarVAA0de14CapitalizationK0VtcfC
_$s10Foundation4DateV19RelativeFormatStyleV12presentation05unitsE06locale8calendar21capitalizationContextA2E12PresentationV_AE05UnitsE0VAA6LocaleVAA8CalendarVAA0de14CapitalizationK0VtcfC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleV6localeAA6LocaleVvs
_$s10Foundation4DateV19RelativeFormatStyleV6localeAA6LocaleVvs:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$s10Foundation4DateV19RelativeFormatStyleVAA0dE0AAMc
_$s10Foundation4DateV19RelativeFormatStyleVAA0dE0AAMc:
    .quad 0, 0, 0, 0
.text
.globl _$s10Foundation4DateV19RelativeFormatStyleVMa
_$s10Foundation4DateV19RelativeFormatStyleVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV3nowACvgZ
_$s10Foundation4DateV3nowACvgZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV9formatted4date4timeSSAC11FormatStyleV0bG0V_AH04TimeG0VtF
_$s10Foundation4DateV9formatted4date4timeSSAC11FormatStyleV0bG0V_AH04TimeG0VtF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$s10Foundation4DateV9formattedy12FormatOutputQzxAA0D5StyleRzAC0D5InputRtzlF
_$s10Foundation4DateV9formattedy12FormatOutputQzxAA0D5StyleRzAC0D5InputRtzlF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif

/* Autogenerated comprehensive Foundation stubs */
.text
    .quad 0, 0, 0, 0
.data
    .quad 0, 0, 0, 0
.text
    .quad 0, 0, 0, 0
.text
    .quad 0, 0, 0, 0
.text
    .quad 0, 0, 0, 0
.text
    .quad 0, 0, 0, 0
.text
.globl _$sSo12NSFileHandleC10FoundationE9readToEndAC4DataVSgyKF
_$sSo12NSFileHandleC10FoundationE9readToEndAC4DataVSgyKF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo12NSURLSessionC10FoundationE4data3for8delegateAC4DataV_So13NSURLResponseCtAC10URLRequestV_So0A12TaskDelegate_pSgtYaKF
_$sSo12NSURLSessionC10FoundationE4data3for8delegateAC4DataV_So13NSURLResponseCtAC10URLRequestV_So0A12TaskDelegate_pSgtYaKF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo12NSURLSessionC10FoundationE4data3for8delegateAC4DataV_So13NSURLResponseCtAC10URLRequestV_So0A12TaskDelegate_pSgtYaKFTu
_$sSo12NSURLSessionC10FoundationE4data3for8delegateAC4DataV_So13NSURLResponseCtAC10URLRequestV_So0A12TaskDelegate_pSgtYaKFTu:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo14NSItemProviderC22UniformTypeIdentifiersE22loadDataRepresentation3for17completionHandlerSo10NSProgressCAC6UTTypeV_y10Foundation0G0VSg_s5Error_pSgtYbctF
_$sSo14NSItemProviderC22UniformTypeIdentifiersE22loadDataRepresentation3for17completionHandlerSo10NSProgressCAC6UTTypeV_y10Foundation0G0VSg_s5Error_pSgtYbctF:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text

/* Autogenerated AppKit Invalidating stubs */
.text
.globl _$sSo6NSViewC6AppKitE12InvalidatingV12wrappedValue_AEy_xq_Gx_q_tcfC
_$sSo6NSViewC6AppKitE12InvalidatingV12wrappedValue_AEy_xq_Gx_q_tcfC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo6NSViewC6AppKitE12InvalidatingV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAJyqd__AEy_xq_GGtcABRbd__luigZ
_$sSo6NSViewC6AppKitE12InvalidatingV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAJyqd__AEy_xq_GGtcABRbd__luigZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo6NSViewC6AppKitE12InvalidatingV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAJyqd__AEy_xq_GGtcABRbd__luisZ
_$sSo6NSViewC6AppKitE12InvalidatingV18_enclosingInstance7wrapped7storagexqd___s24ReferenceWritableKeyPathCyqd__xGAJyqd__AEy_xq_GGtcABRbd__luisZ:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo6NSViewC6AppKitE12InvalidatingVMa
_$sSo6NSViewC6AppKitE12InvalidatingVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$sSo6NSViewC6AppKitE12InvalidatingVMn
_$sSo6NSViewC6AppKitE12InvalidatingVMn:
    .quad 0, 0, 0, 0
.data
.globl _$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVAC0A12InvalidatingACWP
_$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVAC0A12InvalidatingACWP:
    .quad 0, 0, 0, 0
.text
.globl _$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVAGycfC
_$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVAGycfC:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVMa
_$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVMa:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.data
.globl _$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVMn
_$sSo6NSViewC6AppKitE13InvalidationsO7DisplayVMn:
    .quad 0, 0, 0, 0

/* SearchKit stubs */
.text
.globl _SKDocumentCopyURL
_SKDocumentCopyURL:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKDocumentCreateWithURL
_SKDocumentCreateWithURL:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexAddDocument
_SKIndexAddDocument:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexAddDocumentWithText
_SKIndexAddDocumentWithText:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexClose
_SKIndexClose:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexCompact
_SKIndexCompact:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexCopyDocumentURLsForDocumentIDs
_SKIndexCopyDocumentURLsForDocumentIDs:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexCopyTermIDArrayForDocumentID
_SKIndexCopyTermIDArrayForDocumentID:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexCopyTermStringForTermID
_SKIndexCopyTermStringForTermID:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexCreateWithMutableData
_SKIndexCreateWithMutableData:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexCreateWithURL
_SKIndexCreateWithURL:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexDocumentIteratorCopyNext
_SKIndexDocumentIteratorCopyNext:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexDocumentIteratorCreate
_SKIndexDocumentIteratorCreate:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexFlush
_SKIndexFlush:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexGetAnalysisProperties
_SKIndexGetAnalysisProperties:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexGetDocumentID
_SKIndexGetDocumentID:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexGetDocumentState
_SKIndexGetDocumentState:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexGetDocumentTermCount
_SKIndexGetDocumentTermCount:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexGetDocumentTermFrequency
_SKIndexGetDocumentTermFrequency:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexOpenWithMutableData
_SKIndexOpenWithMutableData:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexOpenWithURL
_SKIndexOpenWithURL:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKIndexRemoveDocument
_SKIndexRemoveDocument:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKLoadDefaultExtractorPlugIns
_SKLoadDefaultExtractorPlugIns:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKSearchCancel
_SKSearchCancel:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKSearchCreate
_SKSearchCreate:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text
.globl _SKSearchFindMatches
_SKSearchFindMatches:
#if defined(__x86_64__)
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
    mov x0, #0
    ret
#endif
.text