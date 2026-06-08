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
    final ink = state.inkAccent;
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
                  color: ink, fontWeight: FontWeight.w800, fontSize: 22)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text("Flutter Developer & AI Agent Engineer",
              style: GoogleFonts.inter(
                  color: ink.withOpacity(0.65), fontSize: 12.5)),
        ),
        const SizedBox(height: 16),
        // Fact chips.
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            SoftChip(label: "Vancouver, BC", icon: Icons.location_on_outlined),
            SoftChip(label: "8+ Years Exp", icon: Icons.schedule),
            SoftChip(label: "Product Strategy", icon: Icons.workspaces_outline),
          ],
        ),
        const SizedBox(height: 20),
        // Philosophy card.
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Philosophy",
                  style: GoogleFonts.inter(
                      color: ink, fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 12),
              Text(
                "I bridge the gap between elegant design and robust architecture. "
                "My passion lies in crafting user interfaces that feel native, "
                "intuitive, and remarkably fast.\n\n"
                "With a background in both structural engineering and digital "
                "design, I approach frontend development as a craft. I believe "
                "that clean code is the foundation of inclusive, accessible, and "
                "delightful user experiences.",
                style: GoogleFonts.inter(
                    color: ink.withOpacity(0.75), fontSize: 13, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Stat cards.
        Row(
          children: [
            Expanded(
              child: _stat(ink, Icons.rocket_launch_outlined, "12+",
                  "Apps Shipped"),
            ),
            const SizedBox(width: 14),
            Expanded(
              child:
                  _stat(ink, Icons.groups_outlined, "500k+", "Users Reached"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(Color ink, IconData icon, String value, String label) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: ink, size: 26),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.inter(
                  color: ink, fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  color: ink.withOpacity(0.6), fontSize: 11.5)),
        ],
      ),
    );
  }
}
