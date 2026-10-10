import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/moods.dart';
import '../../providers/current_state.dart';
import '../../utils/session_flag.dart';
import '../type_scale.dart';

/// `pick my mood ↓` — a one-time speech bubble beside Strobi, pointing at the
/// mood swatches. It teaches the site's main interaction, then gets out of
/// the way: gone after the first mood pick or 8s, and shown once per session.
class MascotHint extends StatefulWidget {
  const MascotHint({super.key});

  @override
  State<MascotHint> createState() => _MascotHintState();
}

class _MascotHintState extends State<MascotHint> {
  static const String _seenKey = 'ny.mascot-hint';

  bool _visible = false;
  bool _done = readSessionFlag(_seenKey);
  Mood? _moodAtShow;
  Timer? _timer;

  void _show(Mood mood) {
    _done = true;
    writeSessionFlag(_seenKey);
    _moodAtShow = mood;
    // A beat after Strobi wakes, so the two don't compete.
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _visible = true);
      _timer = Timer(const Duration(seconds: 8), _hide);
    });
  }

  void _hide() {
    _timer?.cancel();
    if (mounted && _visible) setState(() => _visible = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool booted = context.select<CurrentState, bool>((s) => s.booted);
    final Mood mood = context.select<CurrentState, Mood>((s) => s.currentMood);
    if (booted && !_done) _show(mood);
    // The visitor picked a mood: the hint has done its job.
    if (_visible && mood != _moodAtShow) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hide());
    }

    final bool still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return IgnorePointer(
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(-0.08, 0),
        duration: Duration(milliseconds: still ? 0 : 320),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: Duration(milliseconds: still ? 0 : 320),
          child: CustomPaint(
            painter: _BubblePainter(),
            child: Padding(
              // Extra left padding for the tail pointing at Strobi.
              padding: const EdgeInsets.fromLTRB(16, 7, 11, 8),
              child: Text(
                "pick my mood ↓",
                style: monoStyle(const Color(0xFF0F1B2D), size: 10.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White rounded bubble with a small tail on the left, toward Strobi.
class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double tail = 6;
    final RRect body = RRect.fromLTRBR(
      tail,
      0,
      size.width,
      size.height,
      const Radius.circular(10),
    );
    final double mid = size.height / 2;
    final Path path = Path()
      ..addRRect(body)
      ..moveTo(tail + 1, mid - 5)
      ..lineTo(0, mid)
      ..lineTo(tail + 1, mid + 5)
      ..close();
    canvas.drawShadow(path, Colors.black, 6, false);
    canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.96));
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}
