import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Achievements detail — awards, recognitions and certifications as cards,
/// using the shared light/mood-adaptive template.
class AchievementsDetail extends StatelessWidget {
  const AchievementsDetail({super.key});

  static const _items = [
    _Achievement(
      icon: Icons.emoji_events,
      title: "1st Prize — YPIPA State Hackathon",
      org: "Young Pharmacist Innovation & Patent Award",
      desc:
          "Won 1st place out of 20+ teams at the state-level YPIPA hackathon for "
          "PillBin, a smart medicine-management ecosystem. Also represented the "
          "project at Avishkar & Anveshan (State Level).",
    ),
    _Achievement(
      icon: Icons.brush,
      title: "Best UI/UX Award — Cinecode 2026",
      org: "Hackathon by Storyvord",
      desc:
          "Awarded Best UI/UX for designing Storyboardiac, a collaborative movie "
          "script editor and storyboarding platform.",
    ),
    _Achievement(
      icon: Icons.workspace_premium,
      title: "Smart India Hackathon Finalist",
      org: "Top 0.5% of 2500+ teams",
      desc:
          "Led a team of 5 to the finals of Smart India Hackathon after "
          "institution-level selection, architecting the backend for a plant "
          "disease detection project.",
    ),
    _Achievement(
      icon: Icons.military_tech,
      title: "Certificate of Merit — CIIA Innovators Exhibition",
      org: "Mumbai · Top 50 Team",
      desc:
          "Recognized for Research & Innovation Impact for \"PillBin — Drug "
          "Disposal Platform\" at the CIIA India Innovators Exhibition, Mumbai.",
    ),
    _Achievement(
      icon: Icons.verified,
      title: "Postman API Fundamentals — Student Expert",
      org: "Postman",
      desc:
          "Earned the Student Expert badge, demonstrating strong proficiency in "
          "API development and testing.",
    ),
    _Achievement(
      icon: Icons.description,
      title: "Letter of Recommendation — SNDT",
      org: "Faculty-Mentored PillBin Project",
      desc:
          "Core contributor who owned end-to-end coordination, testing, "
          "documentation, and the Google Play Store release; received a formal "
          "LOR.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return DetailScaffold(
      title: "Achievements",
      children: [
        Text("Achievements",
            style: GoogleFonts.inter(
                color: state.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 26)),
        const SizedBox(height: 4),
        Text("Awards, recognitions & certifications.",
            style: GoogleFonts.inter(color: state.textMuted, fontSize: 13)),
        const SizedBox(height: 18),
        for (final a in _items) _AchievementCard(item: a),
      ],
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String org;
  final String desc;
  const _Achievement({
    required this.icon,
    required this.title,
    required this.org,
    required this.desc,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement item;
  const _AchievementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: state.accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: state.inkAccent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: GoogleFonts.inter(
                          color: state.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          height: 1.3)),
                  const SizedBox(height: 2),
                  Text(item.org,
                      style: GoogleFonts.inter(
                          color: state.inkAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(item.desc,
                      style: GoogleFonts.inter(
                          color: state.textPrimary.withOpacity(0.8),
                          fontSize: 12,
                          height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
