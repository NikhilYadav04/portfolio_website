import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../consts/moods.dart';
import 'mascot_bridge.dart';

/// How Strobi's body is moving, set by the director and acted out in Flutter
/// by `Mascot` (the renderer can't move the body itself).
enum MascotPose { float, shiver, sink }

/// Decides what Strobi plays at any moment. One instance for the app, so the
/// desktop mascot and the one on the settings sheet always agree.
///
/// Keys match tool/mascot/build_strobi.py: animations are "<mood>-<name>",
/// cursor looks are "<mood>-look-<direction>". The mood part is the colour.
///
/// Layers, highest first:
///   boot screen running      → sleeping
///   clicked                  → laughing (2.4s)
///   Résumé hovered           → excited
///   mood swatch hovered      → that mood, as a preview
///   cursor moving nearby     → looks at it (until 1.5s still)
///   30s / 45s no activity    → drowsy / sleeping
///   just woke                → waking (1.2s)
///   otherwise                → the mood's own loop
class MascotDirector {
  MascotDirector._();
  static final MascotDirector instance = MascotDirector._();

  static const Duration _drowsyAfter = Duration(seconds: 30);
  static const Duration _sleepAfter = Duration(seconds: 45);
  static const Duration _lookHold = Duration(milliseconds: 1500);

  /// Readout for `?mascot=debug`: what was last sent, and which layer won.
  final ValueNotifier<String> debug = ValueNotifier('—');

  /// Body acting, read by `Mascot`.
  final ValueNotifier<MascotPose> pose = ValueNotifier(MascotPose.sink);

  /// Bumped for a hop (mood change, waking up).
  final ValueNotifier<int> hops = ValueNotifier(0);

  /// Bumped for a squash (clicked).
  final ValueNotifier<int> squashes = ValueNotifier(0);

  bool _started = false;
  Mood _mood = Mood.midday;
  bool _booted = false;

  Mood? _preview;
  bool _laughing = false;
  bool _excited = false;
  bool _waking = false;
  String? _look;
  _Doze _doze = _Doze.awake;

  Timer? _laughTimer;
  Timer? _wakeTimer;
  Timer? _lookTimer;
  DateTime _lastActivity = DateTime.now();
  DateTime _lastPointer = DateTime.now();

  /// Screen centres of the Strobis on screen, for working out where to look.
  /// The last one wins: the sheet's, while the sheet is open.
  final List<Offset? Function()> _centres = [];

  void attach(Offset? Function() centre) => _centres.add(centre);
  void detach(Offset? Function() centre) => _centres.remove(centre);

  String? _sent;

  // -------------------------------------------------------------------------
  // What to show
  // -------------------------------------------------------------------------

  /// (key, isLook, layer) for the highest layer that's active.
  (String, bool, String) get _target {
    final String m = (_preview ?? _mood).name;
    if (!_booted) return ('$m-sleeping', false, 'boot');
    if (_laughing) return ('$m-laughing', false, 'clicked');
    if (_excited) return ('$m-excited', false, 'résumé');
    if (_preview != null) return ('$m-mood', false, 'preview');
    if (_look != null) return ('$m-look-$_look', true, 'cursor');
    if (_doze == _Doze.sleeping) return ('$m-sleeping', false, 'idle');
    if (_doze == _Doze.drowsy) return ('$m-drowsy', false, 'idle');
    if (_waking) return ('$m-waking', false, 'waking');
    return ('$m-mood', false, 'mood');
  }

  void _apply() {
    final (key, isLook, layer) = _target;
    pose.value = _poseFor(layer);
    debug.value = '$key · $layer';
    if (key == _sent) return;
    _sent = key;
    isLook ? mascotLook(key) : mascotPlay(key);
  }

  MascotPose _poseFor(String layer) {
    final Mood m = _preview ?? _mood;
    if (layer == 'boot' || _doze != _Doze.awake && layer == 'idle') {
      return MascotPose.sink;
    }
    if (layer == 'mood' || layer == 'preview' || layer == 'cursor') {
      if (m == Mood.storm) return MascotPose.shiver;
      if (m == Mood.night) return MascotPose.sink;
    }
    return MascotPose.float;
  }

  void _wake(Duration hold) {
    _waking = true;
    hops.value++;
    _wakeTimer?.cancel();
    _wakeTimer = Timer(hold, () {
      _waking = false;
      _apply();
    });
    _apply();
  }

  // -------------------------------------------------------------------------
  // Inputs
  // -------------------------------------------------------------------------

  /// Called by each `Mascot` as it builds, with the app's current state.
  void sync({required Mood mood, required bool booted}) {
    if (!_started) {
      _started = true;
      _mood = mood;
      _booted = booted;
      mascotOnTap(_tap);
      // Checks the activity timestamp instead of reacting per event, so a
      // moving mouse costs one `DateTime.now()`.
      Timer.periodic(const Duration(seconds: 5), (_) => _checkIdle());
      // Typing counts as activity. Returns false: only observes keys.
      HardwareKeyboard.instance.addHandler((_) {
        activity();
        return false;
      });
      booted ? _wake(const Duration(milliseconds: 1200)) : _apply();
      return;
    }
    if (mood == _mood && booted == _booted) return;
    final bool justBooted = booted && !_booted;
    final bool moodChanged = mood != _mood;
    _mood = mood;
    _booted = booted;
    _preview = null;
    if (justBooted || mood == Mood.dawn && moodChanged) {
      _wake(const Duration(milliseconds: 1200));
    } else {
      if (moodChanged) hops.value++;
      _apply();
    }
  }

  /// Mouse, tap, scroll or key anywhere. Wakes Strobi from a doze.
  void activity() {
    _lastActivity = DateTime.now();
    if (_doze != _Doze.awake) {
      _doze = _Doze.awake;
      _wake(const Duration(seconds: 1));
    }
  }

  /// The pointer moved to [position] (global). Strobi turns toward it, but
  /// the page is only told when the direction zone changes.
  void pointer(Offset position) {
    activity();
    _lastPointer = _lastActivity;
    final Offset? c = _centres.isEmpty ? null : _centres.last();
    if (c == null) return;
    final Offset d = position - c;
    // Close to Strobi: no look, so it doesn't go cross-eyed under the cursor.
    final String? zone = d.distance < 70 ? null : _zone(d);
    if (zone != _look) {
      _look = zone;
      _apply();
    }
    _lookTimer ??= Timer(_lookHold, _lookExpired);
  }

  /// Re-arms itself until the pointer has been still for [_lookHold], so
  /// pointer events never create timers.
  void _lookExpired() {
    final Duration still = DateTime.now().difference(_lastPointer);
    if (still < _lookHold) {
      _lookTimer = Timer(_lookHold - still, _lookExpired);
      return;
    }
    _lookTimer = null;
    if (_look != null) {
      _look = null;
      _apply();
    }
  }

  static const List<String> _zones = [
    'right', 'down-right', 'down', 'down-left', //
    'left', 'up-left', 'up', 'up-right',
  ];

  /// One of 8 compass zones. Screen y grows downward, so angle 90° is "down".
  static String _zone(Offset d) {
    final double a = math.atan2(d.dy, d.dx); // -π..π, 0 = right
    final int i = ((a / (math.pi / 4)).round() + 8) % 8;
    return _zones[i];
  }

  /// While the pointer is over a mood swatch: preview that mood, or null.
  void preview(Mood? mood) {
    if (_preview == mood) return;
    final bool entering = mood != null && mood != _mood;
    _preview = mood == _mood ? null : mood;
    if (entering) hops.value++;
    _apply();
  }

  /// While the pointer is over the Résumé button.
  void resumeHover(bool hovering) {
    if (_excited == hovering) return;
    _excited = hovering;
    _apply();
  }

  void _tap() {
    activity();
    _laughing = true;
    squashes.value++;
    _laughTimer?.cancel();
    _laughTimer = Timer(const Duration(milliseconds: 2400), () {
      _laughing = false;
      _apply();
    });
    _apply();
  }

  void _checkIdle() {
    final Duration quiet = DateTime.now().difference(_lastActivity);
    final _Doze next = quiet >= _sleepAfter
        ? _Doze.sleeping
        : quiet >= _drowsyAfter
        ? _Doze.drowsy
        : _Doze.awake;
    // Only ever deepens here; waking up is [activity]'s job.
    if (next.index > _doze.index) {
      _doze = next;
      _apply();
    }
  }
}

enum _Doze { awake, drowsy, sleeping }
