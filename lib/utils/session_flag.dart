/// A yes/no flag that lasts for the browser tab's session (survives reloads,
/// cleared when the tab closes). Off the web there is no session, so the flag
/// is never set.
export 'session_flag_stub.dart'
    if (dart.library.js_interop) 'session_flag_web.dart';
