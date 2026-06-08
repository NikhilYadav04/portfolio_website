import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Experience detail — a vertical list of roles, each with a date pill, title,
/// company, location, and bullet items in a glass card. Matches exp.png.
class ExperienceDetail extends StatelessWidget {
  const ExperienceDetail({super.key});

  static const _roles = [
    _Role(
      "May 2026 - Present",
      "Summer Research Intern",
      "National Institute of Technology Calicut · Internship",
      "Kozhikode, Kerala, India · On-site",
      [
        "Agentic AI for Digital Evaluation and Feedback System.",
      ],
      logo: "assets/exp/nit.jpg",
    ),
    _Role(
      "Jan 2026 - Present",
      "SDE Intern",
      "Navicon Infraprojects Pvt. Ltd. · Internship",
      "Noida, Uttar Pradesh, India · Remote",
      [],
    ),
    _Role(
      "Sep 2025 - Dec 2025",
      "Technical Contributor — Faculty-Mentored Project",
      "SNDT Women's University, Mumbai · Internship",
      "Mumbai, Maharashtra, India · Remote",
      [
        "Core contributor to the faculty-mentored PillBin project, leading end-to-end delivery and coordination.",
        "Collaborated with faculty mentors on testing, documentation, and Play Store release; received LOR.",
      ],
      skills: "Flutter, LangChain and +6 skills",
      logo: "assets/exp/sndt.jpg",
    ),
    _Role(
      "Jun 2025 - Aug 2025",
      "App Development Intern",
      "Boomlex Technologies Private Limited · Internship",
      "Bengaluru, Karnataka, India · Remote",
      [
        "Built responsive Flutter UI for feeds, stories, posts, and reels with smooth cross-device support.",
        "Integrated Firebase Auth, Firestore/Realtime DB, and SQL for secure, real-time data handling.",
      ],
      skills: "Flutter, Firebase and +7 skills",
      logo: "assets/exp/boomlex.jpg",
    ),
    _Role(
      "May 2026 - Present",
      "Open Source Contributor",
      "GirlScript Summer of Code · Part-time",
      "Remote",
      [],
      logo: "assets/exp/gssoc.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: "Experience",
      children: [
        for (final r in _roles) _RoleBlock(role: r),
      ],
    );
  }
}

class _Role {
  final String dates;
  final String title;
  final String company;
  final String location;
  final List<String> bullets;

  /// Optional "Flutter, LangChain and +6 skills" line shown under the bullets.
  final String? skills;

  /// Optional company/institution logo asset path.
  final String? logo;
  const _Role(
      this.dates, this.title, this.company, this.location, this.bullets,
      {this.skills, this.logo});
}

class _RoleBlock extends StatelessWidget {
  final _Role role;
  const _RoleBlock({required this.role});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final ink = state.inkAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date pill.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: state.softAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role.dates,
                style: GoogleFonts.inter(
                    color: ink, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
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
                    Text(role.title,
                        style: GoogleFonts.inter(
                            color: ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    const SizedBox(height: 3),
                    Text(role.company,
                        style: GoogleFonts.inter(
                            color: state.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: ink.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(role.location,
                              style: GoogleFonts.inter(
                                  color: ink.withOpacity(0.6), fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (role.bullets.isNotEmpty || role.skills != null) ...[
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...role.bullets.map((b) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chevron_right,
                              size: 16, color: state.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(b,
                                style: GoogleFonts.inter(
                                    color: ink.withOpacity(0.78),
                                    fontSize: 12.5,
                                    height: 1.45)),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (role.skills != null)
                    Row(
                      children: [
                        Icon(Icons.diamond_outlined,
                            size: 14, color: state.accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(role.skills!,
                              style: GoogleFonts.inter(
                                  color: ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A rounded company/institution logo with a white backing so transparent or
/// off-white logos still read on the glass card.
class _Logo extends StatelessWidget {
  final String path;
  const _Logo({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        cacheWidth: 132,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.business, size: 22, color: Colors.black38),
      ),
    );
  }
}
