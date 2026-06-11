import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Projects detail — a curated list of project cards, each with a thumbnail,
/// name, description, tech chips, rating + installs, and a View Project button.
/// Matches projects.png; light + mood-adaptive.
class ProjectsDetail extends StatelessWidget {
  const ProjectsDetail({super.key});

  static const _projects = [
    _Project(
      "Analytics Dashboard",
      "A high-performance analytics platform with real-time data processing and interactive visualizations.",
      ["React", "Tailwind CSS", "D3.js"],
      "4.9",
      "10k+",
      Icons.insights,
    ),
    _Project(
      "Wanderlust Travel App",
      "A social travel planner that helps users discover, organize, and share their itineraries with friends.",
      ["React Native", "Supabase", "Framer Motion"],
      "4.8",
      "25k+",
      Icons.travel_explore,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return DetailScaffold(
      title: "Portfolio",
      children: [
        Text("Projects",
            style: GoogleFonts.inter(
                color: state.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 28)),
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
  final String desc;
  final List<String> tech;
  final String rating;
  final String installs;
  final IconData icon;
  const _Project(
      this.name, this.desc, this.tech, this.rating, this.installs, this.icon);
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
      padding: const EdgeInsets.only(bottom: 18),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail.
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withOpacity(0.55), accent.withOpacity(0.2)],
                ),
              ),
              child: Icon(project.icon,
                  size: 46, color: Colors.white.withOpacity(0.85)),
            ),
            const SizedBox(height: 14),
            Text(project.name,
                style: GoogleFonts.inter(
                    color: ink, fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 6),
            Text(project.desc,
                style: GoogleFonts.inter(
                    color: ink.withOpacity(0.72), fontSize: 12.5, height: 1.45)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.tech.map((t) => SoftChip(label: t)).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: accent),
                const SizedBox(width: 4),
                Text(project.rating,
                    style: GoogleFonts.inter(
                        color: ink, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(width: 14),
                Icon(Icons.download_outlined,
                    size: 15, color: ink.withOpacity(0.6)),
                const SizedBox(width: 3),
                Text(project.installs,
                    style: GoogleFonts.inter(
                        color: ink.withOpacity(0.7), fontSize: 13)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("View Project",
                      style: GoogleFonts.inter(
                          color: state.inkAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
