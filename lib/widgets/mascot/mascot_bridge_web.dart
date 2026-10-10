import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('nyMascot')
external _NyMascot? get _bridge;

extension type _NyMascot._(JSObject _) implements JSObject {
  external void mount(web.HTMLElement element);
  external void unmount(web.HTMLElement element);
  external void play(String animation);
  external void look(String expression);
  external set onTap(JSFunction? callback);
}

/// False if `mascot.js` didn't load, so the widget renders nothing instead of
/// an empty platform view.
bool get mascotSupported => _bridge != null;

/// Starts on whatever [mascotPlay] last asked for.
void mascotMount(Object element) {
  final el = element as web.HTMLElement;
  el.style
    ..width = '100%'
    ..height = '100%';
  _bridge?.mount(el);
}

void mascotUnmount(Object element) =>
    _bridge?.unmount(element as web.HTMLElement);

void mascotPlay(String animation) => _bridge?.play(animation);

void mascotLook(String expression) => _bridge?.look(expression);

void mascotOnTap(void Function() onTap) => _bridge?.onTap = onTap.toJS;
