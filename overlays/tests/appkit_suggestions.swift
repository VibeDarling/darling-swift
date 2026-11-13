// NSSuggestionItem, NSSuggestionItemResponse and NSTextSuggestionsDelegate from the AppKit overlay, under Darling.
import AppKit
import _DarlingAppKitShims

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

final class Delegate: NSTextSuggestionsDelegate {
    var selected: [Int] = []
    func textField(_ textField: NSTextField, provideUpdatedSuggestions responseHandler: @escaping (NSSuggestionItemResponse<Int>) -> Void) {
        responseHandler(NSSuggestionItemResponse(items: [NSSuggestionItem(representedValue: 7, title: "seven")]))
    }
    func textField(_ textField: NSTextField, textCompletionFor item: NSSuggestionItem<Int>) -> String? { return "completion" }
    func textField(_ textField: NSTextField, didSelect item: NSSuggestionItem<Int>) { selected.append(item.representedValue) }
}

var item = NSSuggestionItem(representedValue: 42, title: "answer")
check(item.representedValue == 42 && item.image == nil, "item")

var response = NSSuggestionItemResponse<Int>()
check(response.phase == .final, "phase defaults to final")
response = NSSuggestionItemResponse(items: [item])
check(response.phase == .final, "items init keeps the default phase")
response.phase = .intermediate
check(response.phase == .intermediate && NSSuggestionItemResponse<Int>.Phase.final != response.phase, "phase")

let delegate = Delegate()
var delivered = 0
delegate.textField(NSTextField(), provideUpdatedSuggestions: { _ in delivered += 1 })
check(delivered == 1, "the delegate answers through the response handler")
check(delegate.textField(NSTextField(), textCompletionFor: item) == "completion", "completion")
delegate.textField(NSTextField(), didSelect: item)
check(delegate.selected == [42], "selection")

let field = NSTextField()
check(field.suggestionsDelegate == nil, "no delegate at first")
field.suggestionsDelegate = delegate
check(field.suggestionsDelegate === delegate, "delegate is stored")
do {
    let transient = Delegate()
    field.suggestionsDelegate = transient
}
check(field.suggestionsDelegate == nil, "delegate is not retained")

if failures != 0 { exit(1) }
