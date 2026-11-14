// The NSTextField suggestions API (macOS 15), reduced to the names Notes imports. The types are plain values and a
// protocol; nothing calls the delegate yet, the text field only stores it.
//
// Provenance. Names: imported by Notes (rung 5, llvm-nm -u -m). Rung 3, Apple's public documentation:
// https://developer.apple.com/documentation/appkit/nssuggestionitem (an unconstrained generic struct with
// `title`, `image`, `representedValue` and `init(representedValue:title:)`), .../nstextsuggestionsdelegate
// (class-bound protocol with one associated type) and .../nssuggestionitemresponse (one unconstrained generic
// parameter, `phase` defaulting to `.final`).
// GUESS (no public source): the declaration order of the three protocol requirements (it fixes the witness-table
// layout), the declaration order of the Phase cases, and the internal storage of the response.
// Left out because no named app imports them: a public `title`, NSSuggestionItemSection and itemSections, default implementations
// of the delegate methods, `@MainActor` on the protocol, Equatable and Hashable on the response, `preferredHighlight`.

@_exported import Foundation
#if DARLING_APPKIT_CLANG_MODULE
@_exported import AppKit
#else
import _DarlingAppKitShims
#endif
import ObjectiveC

/// One suggestion shown in a text field's suggestions list.
public struct NSSuggestionItem<SuggestionItemType> {
    // Not public: Notes imports no accessor of it, so none is exported. The public API's `title` is left out.
    var title: String

    /// An optional image shown beside the title.
    public var image: NSImage?

    /// The value the suggestion stands for, handed back to the delegate on selection.
    public let representedValue: SuggestionItemType

    public init(representedValue: SuggestionItemType, title: String) {
        self.representedValue = representedValue
        self.title = title
    }
}

/// The delegate's answer to a request for suggestions.
public struct NSSuggestionItemResponse<SuggestionItemType> {
    /// Whether the response is a first approximation or the complete list.
    public enum Phase {
        /// More suggestions may follow.
        case intermediate
        /// The complete list.
        case final
    }

    public var phase: Phase = .final
    var items: [NSSuggestionItem<SuggestionItemType>]

    public init() {
        items = []
    }

    /// A response holding `items`.
    public init(items: [NSSuggestionItem<SuggestionItemType>]) {
        self.items = items
    }
}

/// Supplies suggestions to an `NSTextField` and learns which the user picked.
public protocol NSTextSuggestionsDelegate: AnyObject {
    associatedtype SuggestionItemType

    /// Asks for suggestions for the field's current text; call `responseHandler` with the result.
    func textField(_ textField: NSTextField,
                   provideUpdatedSuggestions responseHandler: @escaping (NSSuggestionItemResponse<SuggestionItemType>) -> Void)

    /// The text to complete the field with for `item`; `nil` leaves the text alone.
    func textField(_ textField: NSTextField, textCompletionFor item: NSSuggestionItem<SuggestionItemType>) -> String?

    /// Called when the user chooses `item`.
    func textField(_ textField: NSTextField, didSelect item: NSSuggestionItem<SuggestionItemType>)
}

// A weak box: delegates are not retained, and a Swift existential cannot be stored in an Objective-C property.
private final class SuggestionsDelegateBox {
    weak var delegate: AnyObject?
    var suggestions: (any NSTextSuggestionsDelegate)? { return delegate as? any NSTextSuggestionsDelegate }
    init(_ delegate: AnyObject?) { self.delegate = delegate }
}

private var suggestionsDelegateKey: UInt8 = 0

extension NSTextField {
    /// The object asked for suggestions while the user types. Held weakly.
    public var suggestionsDelegate: (any NSTextSuggestionsDelegate)? {
        get {
            return (objc_getAssociatedObject(self, &suggestionsDelegateKey) as? SuggestionsDelegateBox)?.suggestions
        }
        set {
            objc_setAssociatedObject(self, &suggestionsDelegateKey, SuggestionsDelegateBox(newValue),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
