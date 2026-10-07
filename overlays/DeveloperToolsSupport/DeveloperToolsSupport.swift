// DeveloperToolsSupport overlay for Darling. Photo Booth and other macOS 26 apps import
// ImageResource through NSImage.init(resource:) and its init(name:bundle:); the toolchain's
// prebuilt macOS modules do not include DeveloperToolsSupport, so the small surface the apps
// use is provided here. Only what those binaries import is implemented.
import Foundation

/// Describes an image resource for `NSImage.init(resource:)`.
public struct ImageResource {
    public let name: String
    public let bundle: Bundle

    /// Creates a resource for the image named `name` in `bundle`.
    public init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }
}