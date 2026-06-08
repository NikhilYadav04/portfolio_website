import 'package:awesome_portfolio/consts/moods.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String get selectedCloud => mood.cloudSvg;
  Color get accent => mood.accent;
  RainIntensity get rain => mood.rain;

  // Light inner-screen surfaces derived from the active mood (see MoodSurfaces).
  Color get surfaceTop => mood.surfaceTop;
  Color get surfaceMid => mood.surfaceMid;
  Color get surfaceBottom => mood.surfaceBottom;
  Color get cardFill => mood.cardFill;
  Color get softAccent => mood.softAccent;
  Color get inkAccent => mood.inkAccent;

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

  Offset pointer = Offset.zero;

  /// Feed a raw global pointer position + the screen size; we normalize here so
  /// callers stay dumb. Clamped to [-1, 1].
  void updatePointer(Offset position, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final double nx = ((position.dx / size.width) * 2 - 1).clamp(-1.0, 1.0);
    final double ny = ((position.dy / size.height) * 2 - 1).clamp(-1.0, 1.0);
    final Offset next = Offset(nx, ny);
    if (next == pointer) return;
    pointer = next;
    notifyListeners();
  }

  void resetPointer() {
    if (pointer == Offset.zero) return;
    pointer = Offset.zero;
    notifyListeners();
  }

  void changeSelectedDevice(DeviceInfo device) async {
    currentDevice = device;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Phase 2 — AgentOS boot. The boot sequence plays once per load; this flag
  // flips to true when it finishes so HomePage swaps to the real desktop.
  // ---------------------------------------------------------------------------
  bool booted = false;
  void markBooted() {
    if (booted) return;
    booted = true;
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

  void changePhoneScreen(Widget change, bool isMain, {String? titlee}) {
    title = titlee;
    currentScreen = change;
    isMainScreen = isMain;
    notifyListeners();
  }
}
