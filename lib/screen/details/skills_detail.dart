import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';

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
      "Figma",
      "Canva",
    ]),
  ];

  // Competitive programming highlight, shown as a separate stat row.
  static const _cpStats = [
    _CpStat("1616", "codechef · 3 star"),
    _CpStat("1868", "leetcode · knight"),
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: "Skills",
      eyebrow: "full stack index",
      children: [
        const SizedBox(height: 4),
        for (final g in _groups) _GroupCard(group: g),
        const _CpCard(stats: _cpStats),
      ],
    );
  }
}

class _CpStat {
  /// The rating itself — the number that carries the information.
  final String value;

  /// Lowercase caption: platform and title.
  final String label;
  const _CpStat(this.value, this.label);
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(group.title.toLowerCase()),
            const SizedBox(height: 12),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel("competitive programming"),
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Readout(
                        value: stats[i].value, label: stats[i].label),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
