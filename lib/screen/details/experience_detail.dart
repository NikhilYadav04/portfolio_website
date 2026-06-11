import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Experience detail — a timeline of roles, one self-contained card per role:
/// logo + title (slate) + company (accent), a muted meta line, divider,
/// bullets, and skill chips. Current roles carry a "PRESENT" badge.
class ExperienceDetail extends StatelessWidget {
  const ExperienceDetail({super.key});

  static const _roles = [
    _Role(
      dates: "May 2026 - Present",
      title: "Summer Research Intern",
      company: "National Institute of Technology Calicut",
      kind: "Internship",
      location: "Kozhikode, Kerala · On-site",
      bullets: [
        "Agentic AI for Digital Evaluation and Feedback System.",
      ],
      logo: "assets/exp/nit.jpg",
      current: true,
    ),
    _Role(
      dates: "Jan 2026 - Present",
      title: "SDE Intern",
      company: "Navicon Infraprojects Pvt. Ltd.",
      kind: "Internship",
      location: "Noida, Uttar Pradesh · Remote",
      bullets: [],
      current: true,
    ),
    _Role(
      dates: "Sep 2025 - Dec 2025",
      title: "Technical Contributor — Faculty-Mentored Project",
      company: "SNDT Women's University, Mumbai",
      kind: "Internship",
      location: "Mumbai, Maharashtra · Remote",
      bullets: [
        "Core contributor to the faculty-mentored PillBin project, leading end-to-end delivery and coordination.",
        "Collaborated with faculty mentors on testing, documentation, and Play Store release; received LOR.",
      ],
      skills: ["Flutter", "LangChain", "+6 skills"],
      logo: "assets/exp/sndt.jpg",
    ),
    _Role(
      dates: "Jun 2025 - Aug 2025",
      title: "App Development Intern",
      company: "Boomlex Technologies Private Limited",
      kind: "Internship",
      location: "Bengaluru, Karnataka · Remote",
      bullets: [
        "Built responsive Flutter UI for feeds, stories, posts, and reels with smooth cross-device support.",
        "Integrated Firebase Auth, Firestore/Realtime DB, and SQL for secure, real-time data handling.",
      ],
      skills: ["Flutter", "Firebase", "+7 skills"],
      logo: "assets/exp/boomlex.jpg",
    ),
    _Role(
      dates: "May 2026 - Present",
      title: "Open Source Contributor",
      company: "GirlScript Summer of Code",
      kind: "Part-time",
      location: "Remote",
      bullets: [],
      logo: "assets/exp/gssoc.jpg",
      current: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: "Experience",
      children: [
        const SizedBox(height: 4),
        for (int i = 0; i < _roles.length; i++)
          _TimelineEntry(role: _roles[i], isLast: i == _roles.length - 1),
      ],
    );
  }
}

class _Role {
  final String dates;
  final String title;
  final String company;

  /// "Internship" / "Part-time" — shown next to the company.
  final String kind;
  final String location;
  final List<String> bullets;
  final List<String> skills;
  final String? logo;
  final bool current;
  const _Role({
    required this.dates,
    required this.title,
    required this.company,
    required this.kind,
    required this.location,
    required this.bullets,
    this.skills = const [],
    this.logo,
    this.current = false,
  });
}

/// Timeline rail (dot + connector) alongside one role card.
class _TimelineEntry extends StatelessWidget {
  final _Role role;
  final bool isLast;
  const _TimelineEntry({required this.role, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 22),
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: role.current ? state.accent : Colors.white,
                  border: Border.all(color: state.accent, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 2, color: state.accent.withOpacity(0.25)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RoleCard(role: role),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _Role role;
  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overline: dates + PRESENT badge.
          Row(
            children: [
              Expanded(
                child: Text(
                  role.dates.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: state.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (role.current)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: state.accent.withOpacity(0.4)),
                  ),
                  child: Text(
                    "PRESENT",
                    style: GoogleFonts.inter(
                      color: state.inkAccent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Identity row: logo + title/company.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (role.logo != null) ...[
                _Logo(path: role.logo!),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: GoogleFonts.inter(
                        color: state.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${role.company} · ${role.kind}",
                      style: GoogleFonts.inter(
                        color: state.inkAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12.5, color: state.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            role.location,
                            style: GoogleFonts.inter(
                                color: state.textMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (role.bullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: state.textMuted.withOpacity(0.15)),
            const SizedBox(height: 12),
            ...role.bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.inter(
                            color: state.textPrimary.withOpacity(0.85),
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (role.skills.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: role.skills.map((s) => SoftChip(label: s)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// A rounded company/institution logo with a white backing so transparent or
/// off-white logos still read on the card.
class _Logo extends StatelessWidget {
  final String path;
  const _Logo({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        cacheWidth: 126,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.business, size: 20, color: Colors.black38),
      ),
    );
  }
}
