/// Phase 2 — AgentOS branding.
///
/// All the strings that make the phone read as a custom operating system live
/// here, so renaming is a one-file change. Currently placeholder initials
/// (NY → "nyOS"); swap [initials] / [osName] for the real ones anytime.
class OsBrand {
  /// Shown as the "carrier" in the status bar (top-left of the phone).
  static const String initials = "NY";

  /// The OS name shown on the boot screen.
  static const String osName = "nyOS";

  static const String osVersion = "v1.0";

  /// Boot loader caption.
  static const String bootTagline = "Initializing Profile…";
}
