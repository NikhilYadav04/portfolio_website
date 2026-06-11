import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/homescreen/phone_home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Shared shell for the light, mood-adaptive detail screens (About, Experience,
/// Projects). Renders the mood gradient background, a back arrow that returns to
/// the carousel home, and a centered title — matching the design mockups.
class DetailScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const DetailScaffold({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [state.surfaceTop, state.surfaceMid, state.surfaceBottom],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header: back + centered title.
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context
                        .read<CurrentState>()
                        .changePhoneScreen(const PhoneHomeScreen(), true),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back,
                          color: state.inkAccent, size: 22),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: state.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A frosted glass card used across detail screens.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Near-opaque white so content sits on a calm neutral surface and the
        // card clearly lifts off the tinted background.
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          // Soft ambient + tight contact shadow: real elevation, not a blur smear.
          BoxShadow(
            color: state.accent.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Small rounded fact / tech chip.
class SoftChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const SoftChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: state.softAccent.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: state.accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: state.inkAccent),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              color: state.inkAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
