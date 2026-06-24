import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Projects detail — a list of real project cards: gradient header with an
/// icon + name + tagline, description, tech chips, and a View on GitHub button.
class ProjectsDetail extends StatelessWidget {
  const ProjectsDetail({super.key});

  static const _projects = [
    _Project(
      name: "PillBin",
      tagline: "Smart, offline-first medicine management",
      desc:
          "An offline-first medicine manager for patients and medical centers: "
          "track medicines, get smart expiry alerts, find nearby disposal "
          "centers, donate unused medicines through a verified vendor pipeline, "
          "and chat with PillBot — a multi-agent RAG assistant over medical PDFs.",
      tech: ["Flutter", "Agno", "RAG", "Node.js"],
      icon: Icons.medication_outlined,
      logo: "assets/app/pillbin.webp",
      url: "https://github.com/NikhilYadav04/pillbin_v2",
    ),
    _Project(
      name: "TrialMatch",
      tagline: "AI clinical trial matching agent",
      desc:
          "A multi-agent system that matches patients to clinical trials by "
          "reading their medical profile and evaluating thousands of trials from "
          "ClinicalTrials.gov criterion by criterion — 7 specialized agents from "
          "profile parsing to ranking and report generation.",
      tech: ["Multi-Agent", "RAG", "ClinicalTrials.gov", "Python"],
      icon: Icons.biotech_outlined,
      logo: "assets/app/trial.png",
      url: "https://github.com/NikhilYadav04/clinical_trial",
    ),
    _Project(
      name: "Storyboardiac",
      tagline: "AI screenwriting & storyboard generation",
      desc:
          "A collaborative screenwriting tool for filmmakers. Writers co-edit "
          "scripts in real time; one click parses scenes, characters and "
          "locations, GPT breaks each scene into cinematic shots, and FLUX.2-Pro "
          "renders storyboard frames with full edit history.",
      tech: ["Django", "Azure OpenAI", "FLUX.2-Pro", "WebSockets"],
      icon: Icons.movie_filter_outlined,
      logo: "assets/app/story.png",
      url: "https://github.com/NikhilYadav04/storyboardiac",
    ),
    _Project(
      name: "SplitEase",
      tagline: "Real-time group expense splitting",
      desc:
          "A full-stack app for splitting shared expenses with real-time sync. "
          "Tracks who paid, minimises settlements with a debt-simplification "
          "algorithm, supports equal/custom splits, QR/invite-code joining, and "
          "one-tap PDF export. JWT auth with silent token refresh.",
      tech: ["Flutter", "WebSocket", "JWT", "Puppeteer"],
      icon: Icons.receipt_long_outlined,
      url: "https://github.com/NikhilYadav04/split_ease",
    ),
    _Project(
      name: "Attend Ease",
      tagline: "Attendance & leave management for companies",
      desc:
          "A full-stack workforce attendance app. HR admins define a company "
          "geo-radius; employees clock in only inside it, via Twilio OTP and "
          "biometrics. Handles leave requests, daily reports, PDF export and "
          "real-time video calls. Feature-first clean architecture.",
      tech: ["Flutter", "Node.js", "MongoDB", "GoRouter"],
      icon: Icons.fingerprint,
      logo: "assets/app/attend.png",
      url: "https://github.com/NikhilYadav04/attend_ease",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return DetailScaffold(
      title: "Projects",
      children: [
        Text("Projects",
            style: GoogleFonts.inter(
                color: state.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 26)),
        const SizedBox(height: 4),
        Text("A curated selection of recent work.",
            style: GoogleFonts.inter(color: state.textMuted, fontSize: 13)),
        const SizedBox(height: 18),
        for (final p in _projects) _ProjectCard(project: p),
      ],
    );
  }
}

class _Project {
  final String name;
  final String tagline;
  final String desc;
  final List<String> tech;
  final IconData icon;

  /// Optional app logo; falls back to [icon] when null.
  final String? logo;
  final String url;
  const _Project({
    required this.name,
    required this.tagline,
    required this.desc,
    required this.tech,
    required this.icon,
    this.logo,
    required this.url,
  });
}

class _ProjectCard extends StatelessWidget {
  final _Project project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final ink = state.textPrimary;
    final accent = state.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header band: icon tile + name + tagline.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withOpacity(0.85), accent.withOpacity(0.45)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: project.logo != null
                        ? Image.asset(
                            project.logo!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            cacheWidth: 138,
                            errorBuilder: (_, __, ___) => Icon(project.icon,
                                color: accent, size: 26),
                          )
                        : Icon(project.icon, color: accent, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name,
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        const SizedBox(height: 2),
                        Text(project.tagline,
                            style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11.5,
                                height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(project.desc,
                style: GoogleFonts.inter(
                    color: ink.withOpacity(0.8), fontSize: 12.5, height: 1.5)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.tech.map((t) => SoftChip(label: t)).toList(),
            ),
            const SizedBox(height: 14),
            // View on GitHub.
            GestureDetector(
              onTap: () =>
                  context.read<CurrentState>().launchInBrowser(project.url),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code, size: 16, color: state.inkAccent),
                    const SizedBox(width: 8),
                    Text("View on GitHub",
                        style: GoogleFonts.inter(
                            color: state.inkAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
