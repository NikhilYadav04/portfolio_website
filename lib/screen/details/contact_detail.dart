import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Contact detail — wave badge, "Let's connect!", a Book a call button, and a
/// 2x2 grid of social tiles. Matches contact.png; light + mood-adaptive.
class ContactDetail extends StatelessWidget {
  const ContactDetail({super.key});

  static const _linkedIn =
      "https://www.linkedin.com/in/nikhil-yadav-1a14062a2";
  static const _github = "https://github.com/NikhilYadav04";
  static const _instagram = "https://www.instagram.com/yadav_17_05/";
  static const _email = "byadav1723@gmail.com";

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final ink = state.inkAccent;
    final accent = state.accent;

    return DetailScaffold(
      title: "Contact",
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.6),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
            ),
            child: Icon(Icons.waving_hand_outlined, color: ink, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text("Let's connect!",
              style: GoogleFonts.inter(
                  color: state.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "I'm always open to discussing new projects, creative ideas or "
              "opportunities to be part of your visions.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: state.textMuted, fontSize: 13, height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 22),
        // Email me — primary action.
        GestureDetector(
          onTap: () => state.launchInBrowser("mailto:$_email"),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.35), blurRadius: 14)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mail_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text("Email me",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 2x2 social grid — each tile opens the real link.
        Row(
          children: [
            Expanded(
                child: _social(context, ink, Icons.mail_outline, "Email",
                    "mailto:$_email")),
            const SizedBox(width: 14),
            Expanded(
                child:
                    _social(context, ink, Icons.code, "GitHub", _github)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _social(
                    context, ink, Icons.work_outline, "LinkedIn", _linkedIn)),
            const SizedBox(width: 14),
            Expanded(
                child: _social(context, ink, Icons.camera_alt_outlined,
                    "Instagram", _instagram)),
          ],
        ),
      ],
    );
  }

  Widget _social(BuildContext context, Color ink, IconData icon, String label,
      String url) {
    final textPrimary = context.read<CurrentState>().textPrimary;
    return GestureDetector(
      onTap: () => context.read<CurrentState>().launchInBrowser(url),
      behavior: HitTestBehavior.opaque,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Icon(icon, color: ink, size: 24),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.inter(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
