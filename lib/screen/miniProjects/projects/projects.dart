import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../consts/data.dart';

/// Phase 4 — Projects rebuilt as an in-phone "App Store".
///
/// Each real project is a store card: icon, name, tagline, rating, installs,
/// tags, and an Install button that deep-links out. Reads like a storefront the
/// developer published rather than a list of links.
class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;
    final CurrentState state =
        Provider.of<CurrentState>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
        children: [
          Text(
            "Apps",
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            "by ${developerName}",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ...projectApps.map((p) => _StoreCard(
                app: p,
                accent: accent,
                onInstall: () => state.launchInBrowser(p.link),
              )),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final ProjectApp app;
  final Color accent;
  final VoidCallback onInstall;
  const _StoreCard({
    required this.app,
    required this.accent,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // App icon tile.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, accent.withOpacity(0.5)],
                  ),
                ),
                child: Icon(app.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.tagline,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Install button.
              GestureDetector(
                onTap: onInstall,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "GET",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber[700]),
              const SizedBox(width: 3),
              Text(
                app.rating.toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.download_outlined, size: 14, color: Colors.black45),
              const SizedBox(width: 3),
              Text(
                app.installs,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              ...app.tags.map((t) => Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        color: accent.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
