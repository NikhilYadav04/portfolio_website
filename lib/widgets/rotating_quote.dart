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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
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
