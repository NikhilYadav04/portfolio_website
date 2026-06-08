import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Education detail — a title + timeline of education entries, each with date,
/// degree, institution, bullets, and tag chips. Matches education.png.
class EducationDetail extends StatelessWidget {
  const EducationDetail({super.key});

  static const _entries = [
    _Edu(
      "Aug 2023 — May 2027",
      "B.Tech, Electronics and Communication Engineering",
      "Indian Institute of Information Technology Ranchi",
      [
        "Grade: 8.96 CGPA.",
      ],
      ["Flutter", "Express.js", "+14 skills"],
      logo: "assets/edu/iiit.jpg",
    ),
    _Edu(
      "Jun 2020 — Apr 2022",
      "HSC (Higher Secondary)",
      "Kamaladevi College of Science, Arts and Commerce, Kalyan",
      [
        "Grade: 80.83%.",
      ],
      [],
    ),
    _Edu(
      "Jun 2016 — Mar 2020",
      "SSC (Secondary)",
      "St. Mary's High School, Kalyan",
      [
        "Grade: 93.00%.",
      ],
      [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return DetailScaffold(
      title: "Portfolio",
      children: [
        Text("Education",
            style: GoogleFonts.inter(
                color: ink, fontWeight: FontWeight.w800, fontSize: 28)),
        const SizedBox(height: 4),
        Text("Academic background and continuous learning journey.",
            style: GoogleFonts.inter(color: ink.withOpacity(0.65), fontSize: 13)),
        const SizedBox(height: 18),
        for (final e in _entries) _EduBlock(edu: e),
      ],
    );
  }
}

class _Edu {
  final String dates;
  final String degree;
  final String institution;
  final List<String> bullets;
  final List<String> tags;
  final String? logo;
  const _Edu(
      this.dates, this.degree, this.institution, this.bullets, this.tags,
      {this.logo});
}

class _EduBlock extends StatelessWidget {
  final _Edu edu;
  const _EduBlock({required this.edu});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final ink = state.inkAccent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail.
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: state.accent, width: 2),
                ),
              ),
              Expanded(
                child: Container(width: 2, color: state.accent.withOpacity(0.25)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (edu.logo != null) ...[
                          _EduLogo(path: edu.logo!),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(edu.dates,
                                  style: GoogleFonts.inter(
                                      color: ink.withOpacity(0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(edu.degree,
                                  style: GoogleFonts.inter(
                                      color: ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.account_balance_outlined,
                                      size: 13, color: ink.withOpacity(0.6)),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(edu.institution,
                                        style: GoogleFonts.inter(
                                            color: ink.withOpacity(0.7),
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...edu.bullets.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Icon(Icons.circle_outlined,
                                    size: 9, color: state.accent),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(b,
                                    style: GoogleFonts.inter(
                                        color: ink.withOpacity(0.75),
                                        fontSize: 12.5,
                                        height: 1.45)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          edu.tags.map((t) => SoftChip(label: t)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded institution logo on a white backing for the education cards.
class _EduLogo extends StatelessWidget {
  final String path;
  const _EduLogo({required this.path});

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
            const Icon(Icons.school, size: 22, color: Colors.black38),
      ),
    );
  }
}
