project(swift)

include(darling_lib)

set(DARLING_LIB_64BIT_ONLY TRUE)

set(DYLIB_INSTALL_NAME "/usr/lib/swift/libswiftCoreCompat.dylib")
add_darling_library(swiftCoreCompat SHARED
	swift_compat.S
)
target_link_libraries(swiftCoreCompat system)
set_target_properties(swiftCoreCompat PROPERTIES
	LINKER_LANGUAGE C
	OUTPUT_NAME "swiftCoreCompat"
)
set_property(TARGET swiftCoreCompat APPEND_STRING PROPERTY
	LINK_FLAGS " -Wl,-U,_swift_getTypeByMangledNameInContext -Wl,-U,_\$ss12_ArrayBufferV19_getElementSlowPathyyXlSiF"
)
install(TARGETS swiftCoreCompat DESTINATION libexec/darling/usr/lib/swift)

set(DYLIB_INSTALL_NAME "/usr/lib/swift/libswiftUniformTypeIdentifiers.dylib")
add_darling_library(swiftUniformTypeIdentifiers SHARED
	libswiftUniformTypeIdentifiers.S
)
target_link_libraries(swiftUniformTypeIdentifiers system)
set_target_properties(swiftUniformTypeIdentifiers PROPERTIES
	LINKER_LANGUAGE C
	OUTPUT_NAME "swiftUniformTypeIdentifiers"
)
set_property(TARGET swiftUniformTypeIdentifiers APPEND_STRING PROPERTY
	LINK_FLAGS " -Wl,-U,_\$sBOWV -Wl,-U,_\$ss22__RawDictionaryStorageC5emptys07__EmptyB9SingletonCvgZ"
)
install(TARGETS swiftUniformTypeIdentifiers DESTINATION libexec/darling/usr/lib/swift)

file(GLOB DYLIBS "*.dylib")
if(DYLIBS)
	install(FILES ${DYLIBS} DESTINATION libexec/darling/usr/lib/swift)
endif()
