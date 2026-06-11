import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Education detail — a timeline of entries, one card each: logo + degree
/// (slate) + institution (accent), a grade stat pill, and tag chips.
class EducationDetail extends StatelessWidget {
  const EducationDetail({super.key});

  static const _entries = [
    _Edu(
      dates: "Aug 2023 — May 2027",
      degree: "B.Tech, Electronics and Communication Engineering",
      institution: "Indian Institute of Information Technology Ranchi",
      gradeLabel: "CGPA",
      gradeValue: "8.96",
      tags: ["Flutter", "Express.js", "+14 skills"],
      logo: "assets/edu/iiit.jpg",
    ),
    _Edu(
      dates: "Jun 2020 — Apr 2022",
      degree: "HSC (Higher Secondary)",
      institution: "Kamaladevi College of Science, Arts and Commerce, Kalyan",
      gradeLabel: "Score",
      gradeValue: "80.83%",
    ),
    _Edu(
      dates: "Jun 2016 — Mar 2020",
      degree: "SSC (Secondary)",
      institution: "St. Mary's High School, Kalyan",
      gradeLabel: "Score",
      gradeValue: "93.00%",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return DetailScaffold(
      title: "Education",
      children: [
        Text("Education",
            style: GoogleFonts.inter(
                color: state.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 26)),
        const SizedBox(height: 4),
        Text("Academic background and learning journey.",
            style:
                GoogleFonts.inter(color: state.textMuted, fontSize: 13)),
        const SizedBox(height: 18),
        for (int i = 0; i < _entries.length; i++)
          _TimelineEntry(edu: _entries[i], isLast: i == _entries.length - 1),
      ],
    );
  }
}

class _Edu {
  final String dates;
  final String degree;
  final String institution;
  final String gradeLabel;
  final String gradeValue;
  final List<String> tags;
  final String? logo;
  const _Edu({
    required this.dates,
    required this.degree,
    required this.institution,
    required this.gradeLabel,
    required this.gradeValue,
    this.tags = const [],
    this.logo,
  });
}

class _TimelineEntry extends StatelessWidget {
  final _Edu edu;
  final bool isLast;
  const _TimelineEntry({required this.edu, required this.isLast});

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
                  color: Colors.white,
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
              child: _EduCard(edu: edu),
            ),
          ),
        ],
      ),
    );
  }
}

class _EduCard extends StatelessWidget {
  final _Edu edu;
  const _EduCard({required this.edu});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu.dates.toUpperCase(),
            style: GoogleFonts.inter(
              color: state.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (edu.logo != null) ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    edu.logo!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: 126,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school,
                        size: 20, color: Colors.black38),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edu.degree,
                      style: GoogleFonts.inter(
                        color: state.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      edu.institution,
                      style: GoogleFonts.inter(
                        color: state.inkAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Grade stat pill + tags on one row (wraps if tight).
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: state.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: state.accent.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      edu.gradeLabel,
                      style: GoogleFonts.inter(
                        color: state.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      edu.gradeValue,
                      style: GoogleFonts.inter(
                        color: state.inkAccent,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              ...edu.tags.map((t) => SoftChip(label: t)),
            ],
          ),
        ],
      ),
    );
  }
}
