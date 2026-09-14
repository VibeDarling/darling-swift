// Regression test for the UniformTypeIdentifiers stubs in libswiftUniformTypeIdentifiers.S.
//
// Apps compile against Apple's resilient UniformTypeIdentifiers module, so UTType and UTTagClass are
// address-only to them: results come back through the indirect-result register, initializer arguments
// are owned, and `UTType?` metadata is built from a symbolic reference to the type descriptor. The
// declarations below reproduce that with generic @_silgen_name functions instantiated with the stubs'
// own metadata. Getters receive `self` in x0 instead of x20; the stubs ignore it either way.
//
// Build for arm64-apple-macosx26.0 and link with Darling's ld64 against libswiftCore, libobjc and the
// built libswiftUniformTypeIdentifiers.dylib; run with `darling shell`. Exits non-zero on failure.

import Darwin
import ObjectiveC

@_silgen_name("$s22UniformTypeIdentifiers6UTTypeVMa")
func utTypeMetadataAccessor(_ request: Int) -> (UnsafeRawPointer, Int)
@_silgen_name("$s22UniformTypeIdentifiers10UTTagClassVMa")
func utTagClassMetadataAccessor(_ request: Int) -> (UnsafeRawPointer, Int)

@_silgen_name("$s22UniformTypeIdentifiers6UTTypeV4dataACvgZ")
func utTypeData<T>() -> T
@_silgen_name("$s22UniformTypeIdentifiers10UTTagClassV17filenameExtensionACvgZ")
func utTagClassFilenameExtension<T>() -> T
@_silgen_name("$s22UniformTypeIdentifiers6UTTypeVyACSgSScfC")
func utTypeInit<T>(_ identifier: __owned String) -> T?
@_silgen_name("$s22UniformTypeIdentifiers6UTTypeV17filenameExtension12conformingToACSgSS_ACtcfC")
func utTypeInit<T>(filenameExtension: __owned String, conformingTo supertype: __owned T) -> T?
@_silgen_name("$s22UniformTypeIdentifiers6UTTypeV10identifierSSvg")
func utTypeIdentifier<T>(_ type: T) -> String
@_silgen_name("$s22UniformTypeIdentifiers6UTTypeV4tagsSDyAA10UTTagClassVSaySSGGvg")
func utTypeTags<T>(_ type: T) -> [String: [String]]
@_silgen_name("$s22UniformTypeIdentifiers6UTTypeV9isDynamicSbvg")
func utTypeIsDynamic<T>(_ type: T) -> Bool
@_silgen_name("$s22UniformTypeIdentifiers6UTTypeV19_bridgeToObjectiveCSoABCyF")
func utTypeBridgeToObjectiveC<T>(_ type: T) -> AnyObject

var failures = 0
func check(_ ok: Bool, _ what: String) {
	print("\(ok ? "PASS" : "FAIL"): \(what)")
	if !ok { failures += 1 }
}

func symbol(_ name: String) -> UnsafeRawPointer? {
	dlsym(UnsafeMutableRawPointer(bitPattern: -2), name).map { UnsafeRawPointer($0) }
}

func hex(_ value: UInt64) -> String { "0x" + String(value, radix: 16) }

func payload<T>(_ value: T) -> UInt64 { withUnsafeBytes(of: value) { $0.load(as: UInt64.self) } }

// A native large string's object word is its storage object's address with flags in the top nibble.
func nativeStringRetainCount(_ string: String) -> Int {
	typealias RetainCount = @convention(c) (UnsafeRawPointer) -> Int
	let retainCount = unsafeBitCast(symbol("swift_retainCount")!, to: RetainCount.self)
	let bits = unsafeBitCast(string, to: (UInt64, UInt64).self).1
	return retainCount(UnsafeRawPointer(bitPattern: UInt(bits & 0x0FFF_FFFF_FFFF_FFFF))!)
}

func metadataAddress(_ type: Any.Type) -> UnsafeRawPointer { unsafeBitCast(type, to: UnsafeRawPointer.self) }

func checkMetadata(_ name: String, _ accessor: (Int) -> (UnsafeRawPointer, Int)) -> Any.Type {
	let (metadata, state) = accessor(0)
	check(state == 0, "\(name) metadata accessor reports complete metadata (state \(state))")
	check(symbol("$s22UniformTypeIdentifiers\(name)VN") == metadata, "\(name) VN symbol is the metadata address")
	check(metadata.load(as: UInt.self) == 0x200, "\(name) metadata kind is Struct")
	check(metadata.load(fromByteOffset: -8, as: UnsafeRawPointer.self) == symbol("$sBOWV"),
	      "\(name) value witness table (at -8) is Builtin.NativeObject's")
	let descriptor = metadata.load(fromByteOffset: 8, as: UnsafeRawPointer.self)
	check(descriptor.load(as: UInt32.self) & 0x1f == 17, "\(name) type descriptor kind is Struct")
	return unsafeBitCast(metadata, to: Any.Type.self)
}

// `UTType?` as a client's mangled name spells it: an indirect symbolic reference to the descriptor, then "Sg".
func optionalMetadataFromDescriptor<T>(_: T.Type) -> UnsafeRawPointer? {
	let descriptor = metadataAddress(T.self).load(fromByteOffset: 8, as: UnsafeRawPointer.self)
	let buffer = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 8)
	defer { buffer.deallocate() }
	buffer.storeBytes(of: 0x02, toByteOffset: 0, as: UInt8.self)
	buffer.storeBytes(of: 7, toByteOffset: 1, as: Int32.self)  // relative to its own address: the pointer at +8
	buffer.storeBytes(of: UInt8(ascii: "S"), toByteOffset: 5, as: UInt8.self)
	buffer.storeBytes(of: UInt8(ascii: "g"), toByteOffset: 6, as: UInt8.self)
	buffer.storeBytes(of: 0, toByteOffset: 7, as: UInt8.self)
	buffer.storeBytes(of: descriptor, toByteOffset: 8, as: UnsafeRawPointer.self)
	// A Swift-convention runtime function; with four pointer-sized arguments that matches the C convention.
	typealias Lookup = @convention(c) (UnsafeRawPointer, UInt, UnsafeRawPointer?, UnsafeRawPointer?) -> UnsafeRawPointer?
	let lookup = unsafeBitCast(symbol("swift_getTypeByMangledNameInContext")!, to: Lookup.self)
	return lookup(buffer, 7, nil, nil)
}

func testValues<Type, TagClass>(_: Type.Type, _: TagClass.Type) {
	let identifier = utTypeIdentifier(utTypeData() as Type)
	let raw = unsafeBitCast(identifier, to: (UInt64, UInt64).self)
	check(raw == (0, 0xE000_0000_0000_0000), "identifier is the empty small string (\(hex(raw.0)), \(hex(raw.1)))")
	check(utTypeIsDynamic(utTypeData() as Type) == false, "isDynamic is false")
	check(utTypeTags(utTypeData() as Type).isEmpty, "tags is empty")

	let heapIdentifier = String(repeating: "public.data.", count: 4)
	let retainsBefore = nativeStringRetainCount(heapIdentifier)
	let none: Type? = utTypeInit(heapIdentifier)
	check(none == nil, "UTType(_:) returns nil")
	let retainsAfter = nativeStringRetainCount(heapIdentifier)
	check(retainsBefore == retainsAfter && (1...8).contains(retainsBefore), "UTType(_:) releases the owned identifier (\(retainsBefore) -> \(retainsAfter))")

	let data: Type = utTypeData()
	let bits = payload(data)
	check(bits != 0, "UTType.data is non-null (\(hex(bits)))")
	let tagClass: TagClass = utTagClassFilenameExtension()
	check(payload(tagClass) != 0, "UTTagClass.filenameExtension is non-null (\(hex(payload(tagClass))))")

	check(identifier.isEmpty && identifier.count == 0 && identifier.utf8.count == 0, "identifier is empty")
	check(identifier + "public.data" == "public.data", "appending to identifier works")

	var copies = [Type](repeating: data, count: 64)
	let stored: Type? = copies.removeLast()
	check(stored != nil, "UTType.data stored in an Optional is non-nil")
	check(copies.allSatisfy { payload($0) == bits } && payload(stored!) == bits, "copies of UTType.data are equal")
	copies.removeAll()
	check(payload(utTypeData() as Type) == bits, "UTType.data is the same value on every call")
	let tagCopies = [TagClass](repeating: tagClass, count: 64)
	check(tagCopies.allSatisfy { payload($0) == payload(tagClass) }, "copies of UTTagClass.filenameExtension are equal")

	let byExtension: Type? = utTypeInit(filenameExtension: String(repeating: "ext", count: 8), conformingTo: data)
	check(byExtension == nil, "UTType(filenameExtension:conformingTo:) returns nil")

	let object = utTypeBridgeToObjectiveC(data)
	var isUTType = false
	var cls: AnyClass? = object_getClass(object)
	while let current = cls {
		if String(cString: class_getName(current)) == "UTType" { isUTType = true }
		cls = class_getSuperclass(current)
	}
	check(isUTType, "_bridgeToObjectiveC returns a UTType object")

	check(_typeName(Type.self, qualified: true) == "UniformTypeIdentifiers.UTType",
	      "type name is \(_typeName(Type.self, qualified: true))")
	check(optionalMetadataFromDescriptor(Type.self) == metadataAddress(Optional<Type>.self),
	      "UTType? metadata resolves through the type descriptor")
}

func openTagClass<Type>(_ type: Type.Type, _ tagClass: Any.Type) {
	func open<TagClass>(_ tagClassType: TagClass.Type) { testValues(type, tagClassType) }
	_openExistential(tagClass, do: open)
}

setvbuf(stdout, nil, _IONBF, 0)  // keep the results printed before a crash
let utType = checkMetadata("6UTType", utTypeMetadataAccessor)
let utTagClass = checkMetadata("10UTTagClass", utTagClassMetadataAccessor)
func openType<Type>(_ type: Type.Type) { openTagClass(type, utTagClass) }
_openExistential(utType, do: openType)

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
