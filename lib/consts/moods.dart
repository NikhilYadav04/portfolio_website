import 'package:flutter/material.dart';

/// Phase 1 — reactive world.
///
/// A [Mood] is a complete "world state" for the sky behind the phone: a sky
/// gradient, which cloud SVG drifts across it, how hard it rains, and the
/// accent glow that ties the whole UI (phone tilt highlight, status orb,
/// picker selection) to that mood.
///
/// The six moods intentionally map 1:1 onto the six color buttons the original
/// template shipped with, so the picker keeps the same shape while gaining
/// meaning.
enum Mood {
  dawn,
  midday,
  dusk,
  storm,
  night,
  aurora,
}

/// Rain intensity drives the Rive rain widget + how many rain bands we show.
/// Kept as a small enum (instead of a raw double) so callers read clearly.
enum RainIntensity { none, light, heavy }

class MoodSpec {
  final Mood mood;
  final String label;
  final Gradient gradient;
  final String cloudSvg;

  /// The single accent color for this mood. Used for the picker selection ring,
  /// the agent orb glow, and the phone's tilt highlight. This is the swatch
  /// shown on the mood button too.
  final Color accent;
  final RainIntensity rain;

  const MoodSpec({
    required this.mood,
    required this.label,
    required this.gradient,
    required this.cloudSvg,
    required this.accent,
    required this.rain,
  });
}

const String _cloudBlue = "assets/images/cloudyBlue.svg";
const String _cloudRed = "assets/images/cloudRed.svg";

/// Ordered list — the mood picker renders these in this order, and index 1
/// (midday) is the default so the first paint matches the original blue sky.
const List<MoodSpec> moods = [
  MoodSpec(
    mood: Mood.dawn,
    label: "Dawn",
    accent: Color(0xFFFFC371),
    cloudSvg: _cloudRed,
    rain: RainIntensity.none,
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [Color(0xFFFF8C42), Color(0xFF5B2A86)],
    ),
  ),
  MoodSpec(
    mood: Mood.midday,
    label: "Midday",
    accent: Color(0xFF4DA3FF),
    cloudSvg: _cloudBlue,
    rain: RainIntensity.light,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      colors: [Colors.blue, Colors.black45],
    ),
  ),
  MoodSpec(
    mood: Mood.dusk,
    label: "Dusk",
    accent: Color(0xFFFF6B9D),
    cloudSvg: _cloudBlue,
    rain: RainIntensity.none,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(-0.31, 0.95),
      colors: [Color(0xFFE96443), Color(0xFF904E95)],
    ),
  ),
  MoodSpec(
    mood: Mood.storm,
    label: "Storm",
    accent: Color(0xFF7AA0C4),
    cloudSvg: _cloudBlue,
    rain: RainIntensity.heavy,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF232526), Color(0xFF414345)],
    ),
  ),
  MoodSpec(
    mood: Mood.night,
    label: "Night",
    accent: Color(0xFF8E7BFF),
    cloudSvg: _cloudBlue,
    rain: RainIntensity.light,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
    ),
  ),
  MoodSpec(
    mood: Mood.aurora,
    label: "Aurora",
    accent: Color(0xFF00E0C6),
    cloudSvg: _cloudBlue,
    rain: RainIntensity.none,
    gradient: LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xFF00EBD5), Color(0xFF293474)],
    ),
  ),
];

MoodSpec moodSpec(Mood mood) => moods.firstWhere((m) => m.mood == mood);

// ---------------------------------------------------------------------------
// Light "inside-screen" surfaces derived from a mood.
//
// The phone's inner UI (carousel home, detail screens) stays bright and airy
// like the design mockups, but tints subtly toward the active mood: we blend
// the mood's gradient colours over a near-white base so Dawn reads warm peach,
// Aurora soft mint, Night cool lilac — never dark. Accents (dots, buttons,
// badges) use the mood's full-strength [MoodSpec.accent].
// ---------------------------------------------------------------------------

extension MoodSurfaces on MoodSpec {
  Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  /// A warm-shifted partner of the accent so every gradient has a peach-ish
  /// top like the mockups, regardless of the mood's own hue.
  HSLColor get _hsl => HSLColor.fromColor(accent);

  /// Brighter, slightly desaturated tint of the accent — used for the light
  /// surface washes so the screen is colourful but never muddy.
  Color _airy(double lightness, [double hueShift = 0]) {
    final h = (_hsl.hue + hueShift) % 360;
    return HSLColor.fromAHSL(
      1,
      h,
      (_hsl.saturation * 0.85).clamp(0.0, 1.0),
      lightness,
    ).toColor();
  }

  /// Inner background gradient — three vivid-but-light stops, warm at the top
  /// (hue nudged toward peach) cooling downward. Reads like the mockups.
  Color get surfaceTop => _airy(0.90, 18);
  Color get surfaceMid => _airy(0.86, 0);
  Color get surfaceBottom => _airy(0.82, -12);

  /// The frosted card fill — bright white tinted by the accent, opaque enough
  /// to clearly stand off the background.
  Color get cardFill => _mix(Colors.white, accent, 0.10).withOpacity(0.78);

  /// Soft accent tint for chips / icon badges.
  Color get softAccent => _airy(0.84);

  /// Readable dark version of the accent for text / arrows on light cards.
  Color get inkAccent {
    // Darken via HSL so it stays the mood's hue and reads as colour, not grey.
    return HSLColor.fromAHSL(
      1,
      _hsl.hue,
      (_hsl.saturation * 0.9).clamp(0.0, 1.0),
      0.38,
    ).toColor();
  }
}
