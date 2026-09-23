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

set(DYLIB_INSTALL_NAME "/usr/lib/swift/libswiftWebKit.dylib")
add_darling_library(swiftWebKit SHARED
	libswiftWebKit.S
)
target_link_libraries(swiftWebKit system)
set_target_properties(swiftWebKit PROPERTIES
	LINKER_LANGUAGE C
	OUTPUT_NAME "swiftWebKit"
)
install(TARGETS swiftWebKit DESTINATION libexec/darling/usr/lib/swift)

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

# Combine is a Swift framework, not a /usr/lib/swift overlay dylib, so it installs into the
# framework layout rather than through the glob above. Built by overlays/build.sh. The binary is
# arm64 only, unlike the fat dylibs above, so it is skipped on roots without an arm64 slice.
if (TARGET_ARM64)
	include(InstallSymlink)
	set(COMBINE_FRAMEWORK_DIR "libexec/darling/System/Library/Frameworks/Combine.framework")
	install(PROGRAMS Combine.framework/Versions/A/Combine
		DESTINATION "${COMBINE_FRAMEWORK_DIR}/Versions/A")
	InstallSymlink(A "${CMAKE_INSTALL_PREFIX}/${COMBINE_FRAMEWORK_DIR}/Versions/Current")
	InstallSymlink(Versions/Current/Combine "${CMAKE_INSTALL_PREFIX}/${COMBINE_FRAMEWORK_DIR}/Combine")

	set(CRYPTOKIT_FRAMEWORK_DIR "libexec/darling/System/Library/Frameworks/CryptoKit.framework")
	install(PROGRAMS CryptoKit.framework/Versions/A/CryptoKit
		DESTINATION "${CRYPTOKIT_FRAMEWORK_DIR}/Versions/A")
	InstallSymlink(A "${CMAKE_INSTALL_PREFIX}/${CRYPTOKIT_FRAMEWORK_DIR}/Versions/Current")
	InstallSymlink(Versions/Current/CryptoKit "${CMAKE_INSTALL_PREFIX}/${CRYPTOKIT_FRAMEWORK_DIR}/CryptoKit")

	set(GROUPACTIVITIES_FRAMEWORK_DIR "libexec/darling/System/Library/Frameworks/GroupActivities.framework")
	install(PROGRAMS GroupActivities.framework/Versions/A/GroupActivities
		DESTINATION "${GROUPACTIVITIES_FRAMEWORK_DIR}/Versions/A")
	InstallSymlink(A "${CMAKE_INSTALL_PREFIX}/${GROUPACTIVITIES_FRAMEWORK_DIR}/Versions/Current")
	InstallSymlink(Versions/Current/GroupActivities "${CMAKE_INSTALL_PREFIX}/${GROUPACTIVITIES_FRAMEWORK_DIR}/GroupActivities")
endif()
