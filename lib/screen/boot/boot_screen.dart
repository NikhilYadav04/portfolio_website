import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/consts/os_brand.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 2 — AgentOS boot sequence.
///
/// Renders inside the phone frame for ~1.7s: the OS glyph fades + scales in, a
/// loader bar fills, the version/tagline appears, then it calls
/// [CurrentState.markBooted] to hand off to the home screen. Plays once.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _glyphScale;
  late final Animation<double> _glyphFade;
  late final Animation<double> _progress;
  late final Animation<double> _captionFade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // Beats are spaced so each stage is readable: glyph settles, name + tagline
    // appear, the loader fills slowly across the middle, then a brief hold at
    // full before handing off to the home screen.
    _glyphFade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.22, curve: Curves.easeOut),
    );
    _glyphScale = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOutBack),
      ),
    );
    _progress = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.22, 0.88, curve: Curves.easeInOut),
    );
    _captionFade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.28, 0.5, curve: Curves.easeOut),
    );

    _c.forward().whenComplete(() {
      if (mounted) context.read<CurrentState>().markBooted();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.read<CurrentState>().accent;

    return DecoratedBox(
      decoration: BoxDecoration(
        // Deep dark base with a soft accent glow blooming from the centre.
        gradient: RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 1.1,
          colors: [
            Color.lerp(const Color(0xFF0B1020), accent, 0.18)!,
            const Color(0xFF06080F),
            const Color(0xFF04050A),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Profile avatar inside a rotating accent ring + glow.
              Opacity(
                opacity: _glyphFade.value,
                child: Transform.scale(
                  scale: _glyphScale.value,
                  child: SizedBox(
                    width: 116,
                    height: 116,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating gradient ring.
                        Transform.rotate(
                          angle: _c.value * 6.28318,
                          child: Container(
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  accent.withOpacity(0.0),
                                  accent.withOpacity(0.0),
                                  accent,
                                ],
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Dark gap.
                        Container(
                          width: 104,
                          height: 104,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF06080F),
                          ),
                        ),
                        // Initials glyph.
                        Container(
                          width: 92,
                          height: 92,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [accent, accent.withOpacity(0.35)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: accent.withOpacity(0.45),
                                  blurRadius: 30,
                                  spreadRadius: 1),
                            ],
                          ),
                          child: Text(
                            OsBrand.initials,
                            style: GoogleFonts.exo(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 36,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Opacity(
                opacity: _captionFade.value,
                child: Text(
                  developerName,
                  style: GoogleFonts.exo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Opacity(
                opacity: _captionFade.value,
                child: Text(
                  "${OsBrand.osName}  ${OsBrand.osVersion}",
                  style: GoogleFonts.firaCode(
                    color: accent.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Loader bar + live percentage.
              SizedBox(
                width: 180,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          OsBrand.bootTagline,
                          style: GoogleFonts.firaCode(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "${(_progress.value * 100).round()}%",
                          style: GoogleFonts.firaCode(
                            color: accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                              height: 4, color: Colors.white.withOpacity(0.10)),
                          FractionallySizedBox(
                            widthFactor: _progress.value,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accent.withOpacity(0.5), accent],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: accent.withOpacity(0.6),
                                      blurRadius: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }
}
