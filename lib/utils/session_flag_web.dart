import 'package:web/web.dart' as web;

// sessionStorage can throw (blocked storage, some private modes); treat that
// as "not set" so the app behaves as on a first visit.

bool readSessionFlag(String key) {
  try {
    return web.window.sessionStorage.getItem(key) == '1';
  } catch (_) {
    return false;
  }
}

void writeSessionFlag(String key) {
  try {
    web.window.sessionStorage.setItem(key, '1');
  } catch (_) {}
}
