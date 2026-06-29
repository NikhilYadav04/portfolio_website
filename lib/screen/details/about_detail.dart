import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// About detail — avatar, name, role, fact chips, a Philosophy bio card, and
/// two stat cards. Matches the about.png mockup; light + mood-adaptive.
class AboutDetail extends StatelessWidget {
  const AboutDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final accent = state.accent;

    return DetailScaffold(
      title: "About",
      children: [
        const SizedBox(height: 8),
        // Avatar.
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 18)],
            ),
            child: ClipOval(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.asset(
                "assets/app/profile.jpeg",
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                cacheWidth: 288,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text("Nikhil Yadav",
              style: GoogleFonts.inter(
                  color: state.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text("Building AI Agents & Mobile Apps",
              style: GoogleFonts.inter(
                  color: state.inkAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ),
        const SizedBox(height: 20),
        // About card.
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("About",
                  style: GoogleFonts.inter(
                      color: state.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
              const SizedBox(height: 12),
              Text(
                "I'm a developer from IIIT Ranchi who builds across mobile and AI. "
                "I ship production Flutter & Android apps, and I design "
                "AI systems — chatbots, RAG/query pipelines, and multi-agent "
                "architectures that turn messy real-world problems into "
                "reliable, automated workflows.\n\n"
                "Over 1+ year and 3 internships I've taken projects from idea to "
                "the Play Store, won hackathons, and led teams — always focused "
                "on making things genuinely useful, not just demos.",
                style: GoogleFonts.inter(
                    color: state.textPrimary.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Stat cards.
        Row(
          children: [
            Expanded(
              child: _stat(state, Icons.rocket_launch_outlined, "7+",
                  "Projects Built"),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _stat(
                  state, Icons.work_outline, "3+", "Internships"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(
      CurrentState state, IconData icon, String value, String label) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: state.inkAccent, size: 26),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.inter(
                  color: state.inkAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 22)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  color: state.textMuted, fontSize: 11.5)),
        ],
      ),
    );
  }
}
