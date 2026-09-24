import 'dart:async';

import 'package:awesome_portfolio/consts/data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Phase 4 — the right glass panel's lower card.
///
/// Cross-fades through [rotatingQuotes] on a timer so the panel feels alive
/// rather than static.
class RotatingQuote extends StatefulWidget {
  const RotatingQuote({super.key});

  @override
  State<RotatingQuote> createState() => _RotatingQuoteState();
}

class _RotatingQuoteState extends State<RotatingQuote> {
  int _i = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _i = (_i + 1) % rotatingQuotes.length);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = rotatingQuotes[_i];
    return Padding(
      padding: const EdgeInsets.all(16),
      // Sequential, not a crossfade: the outgoing quote fades away in the first
      // half and the incoming one fades up in the second. Both curves use
      // Interval(0.5, 1) because the outgoing child runs its animation in
      // reverse. A simultaneous crossfade stacked two quotes on top of each
      // other mid-transition and read as garbled text.
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: const Interval(0.5, 1, curve: Curves.easeOut),
        switchOutCurve: const Interval(0.5, 1, curve: Curves.easeIn),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
                .animate(animation),
            child: child,
          ),
        ),
        child: Column(
          key: ValueKey(_i),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '"${quote[0]}"',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                quote[1],
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
