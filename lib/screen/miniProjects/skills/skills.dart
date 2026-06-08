import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../consts/data.dart';

/// Phase 3 — Skills rebuilt as a "system monitor".
///
/// Three tracks (Flutter / Agents / RAG) mirroring the Agent Playground tabs,
/// each shown as labelled gauges that animate to their level on open. Reads as
/// an engineered dashboard rather than a chip cloud.
class Skills extends StatelessWidget {
  const Skills({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E16),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text(
            "SYSTEM MONITOR",
            style: GoogleFonts.firaCode(
              color: accent,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "skill utilisation",
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ...skillTracks.map((t) => _TrackCard(track: t, accent: accent)),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final SkillTrack track;
  final Color accent;
  const _TrackCard({required this.track, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(track.icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                track.name,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...track.stats.map((s) => _Gauge(stat: s, accent: accent)),
        ],
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  final SkillStat stat;
  final Color accent;
  const _Gauge({required this.stat, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.name,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                ),
              ),
              Text(
                "${(stat.level * 100).round()}%",
                style: GoogleFonts.firaCode(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Animated fill bar — tweens from 0 to level on open.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: Colors.white.withOpacity(0.08)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: stat.level),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent.withOpacity(0.6), accent],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
