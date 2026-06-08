import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../consts/data.dart';
import '../../../models/experience_model.dart';

/// Phase 3 — Experience rebuilt as a "git log".
///
/// Each job is a commit node on a vertical branch: a hash, the role as the
/// commit message, company/date as metadata, and bullet points as the diff —
/// expandable. On-brand for a developer and far more memorable than a list.
class Experience extends StatefulWidget {
  const Experience({super.key});

  @override
  State<Experience> createState() => _ExperienceState();
}

class _ExperienceState extends State<Experience> {
  int? _expanded = 0; // first commit open by default

  String _hash(int i) {
    // Deterministic pseudo-hash so it looks like real git output.
    const chars = "0123456789abcdef";
    final seed = (i * 2654435761) & 0xFFFFFF;
    var v = seed;
    final sb = StringBuffer();
    for (var k = 0; k < 7; k++) {
      sb.write(chars[v % 16]);
      v ~/= 16;
      if (v == 0) v = seed + k + 3;
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E16),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 12, 24),
        children: [
          Text(
            r"$ git log --author=me",
            style: GoogleFonts.firaCode(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(jobExperiences.length, (i) {
            return _Commit(
              job: jobExperiences[i],
              hash: _hash(i),
              accent: accent,
              isLast: i == jobExperiences.length - 1,
              expanded: _expanded == i,
              isHead: i == 0,
              onTap: () =>
                  setState(() => _expanded = _expanded == i ? null : i),
            );
          }),
        ],
      ),
    );
  }
}

class _Commit extends StatelessWidget {
  final JobExperience job;
  final String hash;
  final Color accent;
  final bool isLast;
  final bool expanded;
  final bool isHead;
  final VoidCallback onTap;
  const _Commit({
    required this.job,
    required this.hash,
    required this.accent,
    required this.isLast,
    required this.expanded,
    required this.isHead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch rail with the commit node.
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHead ? accent : const Color(0xFF0B0E16),
                  border: Border.all(color: accent, width: 2),
                  boxShadow: isHead
                      ? [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 8)]
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: accent.withOpacity(0.25)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          hash,
                          style: GoogleFonts.firaCode(
                            color: accent,
                            fontSize: 11,
                          ),
                        ),
                        if (isHead) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "HEAD",
                              style: GoogleFonts.firaCode(
                                color: accent,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Commit message = role.
                    Text(
                      job.title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${job.company} · ${job.startDate} – ${job.endDate} · ${job.location}",
                      style: GoogleFonts.firaCode(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10.5,
                      ),
                    ),
                    // Diff = bullet points, expandable.
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: expanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: job.bulletPoints.map((b) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "+ ",
                                    style: GoogleFonts.firaCode(
                                      color: Colors.greenAccent
                                          .withOpacity(0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: GoogleFonts.firaCode(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "› ${job.bulletPoints.length} changes — tap to expand",
                          style: GoogleFonts.firaCode(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
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
