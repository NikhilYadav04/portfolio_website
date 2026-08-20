import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:awesome_portfolio/widgets/type_scale.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Achievements detail — awards, recognitions and certifications as cards,
/// using the shared light/mood-adaptive template.
class AchievementsDetail extends StatelessWidget {
  const AchievementsDetail({super.key});

  static const _items = [
    _Achievement(
      category: "1st prize",
      icon: Icons.emoji_events,
      title: "1st Prize — YPIPA State Hackathon",
      org: "Young Pharmacist Innovation & Patent Award",
      desc:
          "Won 1st place out of 20+ teams at the state-level YPIPA hackathon for "
          "PillBin, a smart medicine-management ecosystem. Also represented the "
          "project at Avishkar & Anveshan (State Level).",
      tier: 0,
    ),
    _Achievement(
      category: "ui/ux",
      icon: Icons.brush_outlined,
      title: "Best UI/UX Award — Cinecode 2026",
      org: "Hackathon by Storyvord",
      desc:
          "Awarded Best UI/UX for designing Storyboardiac, a collaborative movie "
          "script editor and storyboarding platform.",
      tier: 0,
    ),
    _Achievement(
      category: "finalist",
      icon: Icons.workspace_premium_outlined,
      title: "Smart India Hackathon Finalist",
      org: "Top 0.5% of 2500+ teams",
      desc:
          "Led a team of 5 to the finals of Smart India Hackathon after "
          "institution-level selection, architecting the backend for a plant "
          "disease detection project.",
      tier: 1,
    ),
    _Achievement(
      category: "merit",
      icon: Icons.military_tech_outlined,
      title: "Certificate of Merit — CIIA Innovators Exhibition",
      org: "Mumbai · Top 50 Team",
      desc:
          "Recognized for Research & Innovation Impact for \"PillBin — Drug "
          "Disposal Platform\" at the CIIA India Innovators Exhibition, Mumbai.",
      tier: 1,
    ),
    _Achievement(
      category: "cert",
      icon: Icons.verified_outlined,
      title: "Postman API Fundamentals — Student Expert",
      org: "Postman",
      desc:
          "Earned the Student Expert badge, demonstrating strong proficiency in "
          "API development and testing.",
      tier: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: "Achievements",
      eyebrow: "${_items.length} awards · 2 first place",
      children: [
        for (final a in _items) _AchievementCard(item: a),
      ],
    );
  }
}

class _Achievement {
  /// Lowercase kind of award, shown as the row's mono overline.
  final String category;

  /// Mark for the row's left column.
  final IconData icon;
  final String title;
  final String org;
  final String desc;
  final int tier;
  const _Achievement({
    required this.category,
    required this.icon,
    required this.title,
    required this.org,
    required this.desc,
    this.tier = 1,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.tier == 0
                    ? state.accent.withOpacity(0.22)
                    : state.chipFill,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon,
                  size: item.tier == 0 ? 23 : 20, color: state.inkAccent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category,
                      style: monoStyle(state.inkAccent.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  Text(item.title,
                      style: displayStyle(state.textPrimary,
                              size: item.tier == 0 ? 15.5 : 14.5)
                          .copyWith(height: 1.3)),
                  const SizedBox(height: 2),
                  Text(item.org,
                      style: GoogleFonts.inter(
                          color: state.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(item.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
