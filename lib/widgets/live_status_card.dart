import 'dart:async';
import 'dart:math';

import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 4 — the left glass panel's content.
///
/// Turns the static brand card into a "live" engineered surface: a status line,
/// a ticking local clock, and a GitHub-style contribution sparkline. Reads as
/// real, changing data rather than decoration.
class LiveStatusCard extends StatefulWidget {
  const LiveStatusCard({super.key});

  @override
  State<LiveStatusCard> createState() => _LiveStatusCardState();
}

class _LiveStatusCardState extends State<LiveStatusCard> {
  late final Timer _clock;
  DateTime _now = DateTime.now();

  // Placeholder contribution data — a deterministic 7x10 grid of 0..3 levels.
  late final List<int> _grid = List.generate(70, (i) {
    final r = Random(i * 7 + 3);
    final v = r.nextInt(10);
    if (v > 7) return 3;
    if (v > 5) return 2;
    if (v > 2) return 1;
    return 0;
  });

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  String get _time {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(_now.hour)}:${two(_now.minute)}:${two(_now.second)}";
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status line with a live pulse dot.
          Row(
            children: [
              _PulseDot(color: accent),
              const SizedBox(width: 8),
              Text(
                statusLine,
                style: GoogleFonts.firaCode(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            developerName,
            style: GoogleFonts.exo(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            developerTagline,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          // Live clock.
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: accent),
              const SizedBox(width: 6),
              Text(
                "$_time  ${localTimezoneLabel}",
                style: GoogleFonts.firaCode(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contribution sparkline.
          Text(
            "contributions",
            style: GoogleFonts.firaCode(
              color: Colors.white.withOpacity(0.45),
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          _ContributionGrid(grid: _grid, accent: accent),
          const SizedBox(height: 20),
          // Social links — sit just below the contribution grid.
          const _SocialRow(),
        ],
      ),
    );
  }
}

/// Row of social link icons shown under the contributions in the left panel.
class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    final CurrentState state =
        Provider.of<CurrentState>(context, listen: false);
    final socials = <List<dynamic>>[
      ["assets/icons/github.svg", null, github],
      ["assets/icons/linkedin.svg", null, linkedIn],
      [null, FontAwesomeIcons.instagram, instagram],
      ["assets/icons/twitter.svg", null, twitter],
    ];
    return Row(
      children: socials.map((s) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => state.launchInBrowser(s[2] as String),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Center(
                child: s[0] != null
                    ? SvgPicture.asset(s[0] as String, width: 18, height: 18)
                    : Icon(s[1] as IconData, color: Colors.white, size: 18),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ContributionGrid extends StatelessWidget {
  final List<int> grid;
  final Color accent;
  const _ContributionGrid({required this.grid, required this.accent});

  @override
  Widget build(BuildContext context) {
    const int rows = 7;
    const int cols = 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: List.generate(cols, (c) {
              final level = grid[(c * rows + r) % grid.length];
              return Container(
                margin: const EdgeInsets.only(right: 3),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: level == 0
                      ? Colors.white.withOpacity(0.08)
                      : accent.withOpacity(0.25 + level * 0.25),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3 + _c.value * 0.5),
                blurRadius: 3 + _c.value * 6,
                spreadRadius: _c.value * 1.5,
              ),
            ],
          ),
        );
      },
    );
  }
}
