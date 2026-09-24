import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/current_state.dart';

/// The layered hills beneath the sky, recoloured for the active mood.
///
/// There is one artwork (`cloudyBlue.svg`). Its four layer fills are swapped
/// for the mood's [MoodSpec.hillTones], so the hills follow the sky instead of
/// staying navy under every mood (only Dawn used to have its own art). Mood
/// changes crossfade over 600ms, in step with the sky's `AnimatedContainer`.
class MoodHills extends StatefulWidget {
  final double height;
  const MoodHills({super.key, required this.height});

  @override
  State<MoodHills> createState() => _MoodHillsState();
}

class _MoodHillsState extends State<MoodHills> {
  static const _asset = 'assets/images/cloudyBlue.svg';

  /// The artwork's own layer fills, far to near, in document order.
  static const _layerFills = [
    '#182f5d',
    '#25467d',
    '#356cb1',
    'rgba(39, 51, 116, 1)',
  ];

  /// Loaded once for the app's lifetime.
  static Future<String>? _source;

  /// Recoloured SVG per palette. Palettes are the const lists on each
  /// `MoodSpec`, so identity is a safe key.
  static final Map<List<Color>, String> _painted = {};

  String? _svg;

  @override
  void initState() {
    super.initState();
    (_source ??= rootBundle.loadString(_asset).then(_stripBackdrop)).then((s) {
      if (mounted) setState(() => _svg = s);
    });
  }

  /// The artwork carries a full-bleed gradient rect behind the hills.
  /// flutter_svg can't resolve its percentage coordinates and skips it today,
  /// which is the only reason the sky shows through. Remove it outright so the
  /// sky never depends on that parser quirk.
  static String _stripBackdrop(String svg) => svg.replaceFirst(
    RegExp(r'<rect[^>]*fill="url\([^"]*\)"[^>]*>\s*</rect>'),
    '',
  );

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  String _paint(String svg, List<Color> tones) {
    return _painted.putIfAbsent(tones, () {
      var out = svg;
      for (var i = 0; i < _layerFills.length; i++) {
        out = out.replaceFirst(
          'fill="${_layerFills[i]}"',
          'fill="${_hex(tones[i])}"',
        );
      }
      return out;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.select<CurrentState, List<Color>>((s) => s.hillTones);
    final svg = _svg;
    if (svg == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: SvgPicture.string(
        _paint(svg, tones),
        key: ValueKey(tones),
        height: widget.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
