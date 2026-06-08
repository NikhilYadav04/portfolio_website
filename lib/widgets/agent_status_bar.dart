import 'dart:async';

import 'package:awesome_portfolio/consts/os_brand.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 2 — AgentOS status bar.
///
/// The custom top strip of the phone: the OS "carrier" (your initials), signal
/// dots, a live ticking clock, battery, and a pulsing agent orb that carries
/// the AI identity even before any app is opened. Tinted by the active mood's
/// accent.
class AgentStatusBar extends StatefulWidget {
  const AgentStatusBar({super.key});

  @override
  State<AgentStatusBar> createState() => _AgentStatusBarState();
}

class _AgentStatusBarState extends State<AgentStatusBar>
    with SingleTickerProviderStateMixin {
  late final Timer _clock;
  late final AnimationController _pulse;
  TimeOfDay _now = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = TimeOfDay.now();
      if (next != _now && mounted) setState(() => _now = next);
    });
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _clock.cancel();
    _pulse.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final int h = _now.hourOfPeriod == 0 ? 12 : _now.hourOfPeriod;
    final String m = _now.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.transparent,
      child: Row(
        children: [
          // Carrier = your initials, then signal dots.
          Text(
            OsBrand.initials,
            style: GoogleFonts.exo(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          ...List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.only(right: 2),
              width: 3,
              height: 3 + i.toDouble() * 1.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
          const Spacer(),
          // Live clock.
          Text(
            _timeLabel,
            style: GoogleFonts.firaCode(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Pulsing agent orb — the AI identity anchor.
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final double t = _pulse.value;
              return Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4 + t * 0.5),
                      blurRadius: 4 + t * 7,
                      spreadRadius: t * 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Battery.
          Container(
            width: 22,
            height: 11,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
            ),
            padding: const EdgeInsets.all(1.5),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
