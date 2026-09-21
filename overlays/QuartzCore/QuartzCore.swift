// Minimal QuartzCore Swift overlay for Darling, written from Core Animation's public Swift API documentation. It
// provides the one QuartzCore Swift symbol apps import that the vendored 5.2.2 x86_64 slice predates; the rest of
// Core Animation is Objective-C and needs no overlay.

import _DarlingQuartzCoreShims

extension CAFrameRateRange {
    /// A frame rate range with the given bounds, in frames per second.
    ///
    /// `preferred` is the frame rate Core Animation should aim for within the range; `nil` means no preference,
    /// which `CAFrameRateRangeMake` spells as `0`.
    public init(minimum: Float, maximum: Float, preferred: Float?) {
        self.init()
        self.minimum = minimum
        self.maximum = maximum
        self.preferred = preferred ?? 0
    }
}
