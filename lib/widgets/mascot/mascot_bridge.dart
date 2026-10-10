/// Calls into `web/mascot/mascot.js` (`window.nyMascot`). Off the web there is
/// no mascot: every call is a no-op and [mascotSupported] is false.
export 'mascot_bridge_stub.dart'
    if (dart.library.js_interop) 'mascot_bridge_web.dart';
