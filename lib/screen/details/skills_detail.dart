import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Skills detail — grouped category cards, each with a wrap of skill chips.
/// Matches skills.png; light + mood-adaptive.
class SkillsDetail extends StatelessWidget {
  const SkillsDetail({super.key});

  static const _groups = [
    _Group("Languages", Icons.code, [
      "C++",
      "Python",
      "Dart",
      "JavaScript",
      "C",
    ]),
    _Group("Frameworks & Libraries", Icons.widgets_outlined, [
      "Flutter",
      "Node.js",
      "Express.js",
      "FastAPI",
      "LangGraph",
      "Prisma",
    ]),
    _Group("Databases", Icons.storage_outlined, [
      "MongoDB",
      "PostgreSQL",
      "MySQL",
      "Redis",
      "Firebase",
      "Supabase",
      "Pinecone",
    ]),
    _Group("Tools & Platforms", Icons.build_outlined, [
      "REST APIs",
      "WebSockets",
      "Git",
      "GitHub",
      "Docker",
      "Postman",
      "Azure",
      "Vercel",
      "Render",
    ]),
    _Group("Design", Icons.brush_outlined, [
      "Figma",
      "Canva",
    ]),
  ];

  // Competitive programming highlight, shown as a separate stat row.
  static const _cpStats = [
    _CpStat("CodeChef", "3 Star (1616)"),
    _CpStat("LeetCode", "Knight (1868)"),
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: "Skills",
      children: [
        const SizedBox(height: 4),
        for (final g in _groups) _GroupCard(group: g),
        const _CpCard(stats: _cpStats),
      ],
    );
  }
}

class _CpStat {
  final String platform;
  final String rank;
  const _CpStat(this.platform, this.rank);
}

class _Group {
  final String title;
  final IconData icon;
  final List<String> skills;
  const _Group(this.title, this.icon, this.skills);
}

class _GroupCard extends StatelessWidget {
  final _Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: state.accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(group.icon, size: 18, color: state.inkAccent),
                ),
                const SizedBox(width: 10),
                Text(group.title,
                    style: GoogleFonts.inter(
                        color: state.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.skills.map((s) => SoftChip(label: s)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Competitive-programming highlight card — platform + rank as a stat row.
class _CpCard extends StatelessWidget {
  final List<_CpStat> stats;
  const _CpCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: state.accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.emoji_events_outlined,
                      size: 18, color: state.inkAccent),
                ),
                const SizedBox(width: 10),
                Text("Competitive Programming",
                    style: GoogleFonts.inter(
                        color: state.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: stats.map((s) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: state.accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: state.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.platform,
                            style: GoogleFonts.inter(
                                color: state.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(s.rank,
                            style: GoogleFonts.inter(
                                color: state.inkAccent,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
