import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/consts/moods.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/session_flag.dart';

import '../screen/homescreen/phone_home_page.dart';

class CurrentState extends ChangeNotifier {
  DeviceInfo currentDevice = Devices.ios.iPhone13;

  // ---------------------------------------------------------------------------
  // Phase 1 — reactive world state
  // ---------------------------------------------------------------------------

  /// Default mood is midday so the first paint matches the original blue sky.
  Mood currentMood = Mood.midday;
  MoodSpec get mood => moodSpec(currentMood);

  // Derived sky properties — UI reads these instead of holding their own copies.
  Gradient get bgGradient => mood.gradient;
  List<Color> get hillTones => mood.hillTones;
  Color get accent => mood.accent;
  RainIntensity get rain => mood.rain;

  // Light inner-screen surfaces derived from the active mood (see MoodSurfaces).
  Color get surfaceTop => mood.surfaceTop;
  Color get surfaceMid => mood.surfaceMid;
  Color get surfaceBottom => mood.surfaceBottom;
  Color get cardFill => mood.cardFill;
  Color get softAccent => mood.softAccent;
  Color get inkAccent => mood.inkAccent;
  Color get textPrimary => mood.textPrimary;
  Color get textMuted => mood.textMuted;
  Color get hairline => mood.hairline;
  Color get railLine => mood.railLine;
  Color get chipFill => mood.chipFill;

  /// Index of the current mood in [moods] — the picker uses this to show which
  /// swatch is selected (replaces the old `selectedColor`).
  int get selectedMoodIndex => moods.indexWhere((m) => m.mood == currentMood);

  void setMood(Mood next) {
    if (next == currentMood) return;
    currentMood = next;
    notifyListeners();
  }

  void setMoodByIndex(int index) {
    if (index < 0 || index >= moods.length) return;
    setMood(moods[index].mood);
  }

  // ---------------------------------------------------------------------------
  // Pointer parallax — normalized cursor position in [-1, 1] on each axis,
  // (0,0) = screen centre. Layers multiply this by their own depth factor.
  // ---------------------------------------------------------------------------

  /// Its own notifier, not part of this ChangeNotifier: the cursor moves many
  /// times a second, and notifying through [CurrentState] rebuilt every
  /// widget that watches it — the whole phone UI included — on each move.
  /// Only the parallax layers listen to this.
  final ValueNotifier<Offset> pointer = ValueNotifier(Offset.zero);

  /// Feed a raw global pointer position + the screen size; we normalize here so
  /// callers stay dumb. Clamped to [-1, 1].
  ///
  /// The raw value is eased toward (low-pass filtered) and small deltas are
  /// ignored, so the parallax glides instead of snapping on every pixel of
  /// mouse movement — far smoother and far fewer rebuilds.
  void updatePointer(Offset position, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final double nx = ((position.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final double ny = ((position.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);

    // Ease toward the target (0..1; lower = smoother/heavier).
    const double ease = 0.18;
    final Offset p = pointer.value;
    final Offset eased = Offset(
      p.dx + (nx - p.dx) * ease,
      p.dy + (ny - p.dy) * ease,
    );

    // Skip near-identical updates so we don't rebuild on micro-movements.
    if ((eased.dx - p.dx).abs() < 0.004 && (eased.dy - p.dy).abs() < 0.004) {
      return;
    }
    pointer.value = eased;
  }

  void resetPointer() => pointer.value = Offset.zero;

  @override
  void dispose() {
    pointer.dispose();
    super.dispose();
  }

  void changeSelectedDevice(DeviceInfo device) async {
    currentDevice = device;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // AgentOS boot. The boot sequence plays once per browser session: a reload
  // skips straight to the home screen. The flag flips when it finishes (or is
  // tapped to skip).
  // ---------------------------------------------------------------------------
  static const String _bootedKey = 'ny.booted';
  bool booted = readSessionFlag(_bootedKey);
  void markBooted() {
    if (booted) return;
    booted = true;
    writeSessionFlag(_bootedKey);
    notifyListeners();
  }

  bool isMainScreen = true;
  String? title;

  Widget currentScreen = const PhoneHomeScreen();

  /// Legacy entry point kept so existing callers/tests don't break while the UI
  /// migrates to [setMoodByIndex]. The 6 color buttons map 1:1 onto the 6 moods.
  void changeGradient(int index) => setMoodByIndex(index);

  Future<void> launchInBrowser(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  /// Opens the résumé PDF in a new tab. Resolved against the page URL so it
  /// works on any host (local server, custom domain).
  Future<void> openResume() =>
      launchInBrowser(Uri.base.resolve(resumePath).toString());

  void changePhoneScreen(Widget change, bool isMain, {String? titlee}) {
    title = titlee;
    currentScreen = change;
    isMainScreen = isMain;
    notifyListeners();
  }
}
