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
	LINK_FLAGS " -Wl,-U,_swift_getTypeByMangledNameInContext -Wl,-U,'_\$ss12_ArrayBufferV19_getElementSlowPathyyXlSiF'"
)
install(TARGETS swiftCoreCompat DESTINATION libexec/darling/usr/lib/swift)

set(DYLIB_INSTALL_NAME "/usr/lib/swift/libswiftUniformTypeIdentifiers.dylib")
add_darling_library(swiftUniformTypeIdentifiers SHARED
	libswiftUniformTypeIdentifiers.S
)
target_link_libraries(swiftUniformTypeIdentifiers system objc UniformTypeIdentifiers)
set_target_properties(swiftUniformTypeIdentifiers PROPERTIES
	LINKER_LANGUAGE C
	OUTPUT_NAME "swiftUniformTypeIdentifiers"
)
set_property(TARGET swiftUniformTypeIdentifiers APPEND_STRING PROPERTY
	LINK_FLAGS " -Wl,-U,'_\$sBOWV' -Wl,-U,__swiftEmptyDictionarySingleton -Wl,-U,_swift_bridgeObjectRelease"
)
install(TARGETS swiftUniformTypeIdentifiers DESTINATION libexec/darling/usr/lib/swift)

set(DYLIB_INSTALL_NAME "/usr/lib/swift/libswift_errno.dylib")
add_darling_library(swift_errno SHARED
	swift_errno.S
)
target_link_libraries(swift_errno system)
set_target_properties(swift_errno PROPERTIES
	LINKER_LANGUAGE C
	OUTPUT_NAME "swift_errno"
)
set_property(TARGET swift_errno APPEND_STRING PROPERTY
	LINK_FLAGS " -Wl,-reexport_library,${CMAKE_CURRENT_SOURCE_DIR}/libswiftDarwin.dylib")
install(TARGETS swift_errno DESTINATION libexec/darling/usr/lib/swift)

file(GLOB DYLIBS "*.dylib")
if(DYLIBS)
	install(FILES ${DYLIBS} DESTINATION libexec/darling/usr/lib/swift)
endif()
