import Testing

/// Semantic tags that split the suite into its two tiers. `.unit` tests inject a
/// fake runner and never spawn a process; `.functional` tests drive the real
/// `Process` pipeline through a stub binary. Filter with the tag in Xcode or a
/// test plan when you want one tier in isolation.
extension Tag {
    @Tag static var unit: Self
    @Tag static var functional: Self
}
