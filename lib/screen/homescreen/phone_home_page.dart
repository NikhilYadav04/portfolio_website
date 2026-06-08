import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/current_state.dart';
import '../details/about_detail.dart';
import '../details/contact_detail.dart';
import '../details/education_detail.dart';
import '../details/experience_detail.dart';
import '../details/projects_detail.dart';
import '../details/skills_detail.dart';

/// The phone home screen — a 6-page section carousel.
///
/// Replicates the light, glassy portfolio mockups: a top "PORTFOLIO" bar, a
/// swipeable stack of frosted section cards (neighbours peeking), page dots,
/// and a bottom nav. Every colour is derived from the active [CurrentState]
/// mood (subtle light wash + full-strength accent) so the inside breathes with
/// the world outside the phone.
class PhoneHomeScreen extends StatefulWidget {
  const PhoneHomeScreen({super.key});

  @override
  State<PhoneHomeScreen> createState() => _PhoneHomeScreenState();
}

class _PhoneHomeScreenState extends State<PhoneHomeScreen> {
  late final PageController _controller =
      PageController(viewportFraction: 0.82);
  int _page = 0;

  static const _navIcons = [
    Icons.person_outline,
    Icons.work_outline,
    Icons.grid_view,
    Icons.bolt_outlined,
    Icons.school_outlined,
    Icons.mail_outline,
  ];

  void _goto(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final Color accent = state.accent;

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
            _TopBar(accent: accent),
            const SizedBox(height: 8),
            // Carousel.
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _ProfileCard(),
                  _ExperienceCard(),
                  _ProjectsCard(),
                  _SkillsCard(),
                  _EducationCard(),
                  _ContactCard(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _PageDots(count: 6, active: _page, accent: state.inkAccent),
            const SizedBox(height: 16),
            _BottomNav(
              icons: _navIcons,
              active: _page,
              accent: state.inkAccent,
              onTap: _goto,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chrome
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final Color accent;
  const _TopBar({required this.accent});

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
            ),
            child: ClipOval(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.asset(
                "assets/app/profile.jpeg",
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                cacheWidth: 96,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "PORTFOLIO",
            style: GoogleFonts.inter(
              color: ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Icon(Icons.settings, color: ink.withOpacity(0.7), size: 20),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int active;
  final Color accent;
  const _PageDots(
      {required this.count, required this.active, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool on = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: on ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: on ? accent : accent.withOpacity(0.25),
          ),
        );
      }),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final List<IconData> icons;
  final int active;
  final Color accent;
  final ValueChanged<int> onTap;
  const _BottomNav({
    required this.icons,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) {
          final bool on = i == active;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Icon(
                icons[i],
                size: 22,
                color: on ? accent : accent.withOpacity(0.35),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card shell — the frosted glass section card used by every page.
// ---------------------------------------------------------------------------

class _SectionShell extends StatelessWidget {
  final Widget child;
  const _SectionShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Soft top-lit glass: brighter near-white at the top fading to the
          // mood tint, so the card reads with depth against the background.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.92),
              state.cardFill,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: state.accent.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}

/// Circular icon badge at a card's top-left.
class _CardBadge extends StatelessWidget {
  final IconData icon;
  const _CardBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.6),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
      ),
      child: Icon(icon, color: ink, size: 22),
    );
  }
}

/// White pill "VIEW …" button with accent label + arrow.
class _ViewButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ViewButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: ink,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: ink, size: 16),
          ],
        ),
      ),
    );
  }
}

TextStyle _titleStyle(Color ink) => GoogleFonts.inter(
      color: ink,
      fontWeight: FontWeight.w800,
      fontSize: 26,
    );

// ---------------------------------------------------------------------------
// Pages
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    final accent = context.watch<CurrentState>().accent;
    return _SectionShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.4), blurRadius: 22),
              ],
            ),
            // Let the renderer scale the full-res source itself — manually
            // pre-decoding (cacheWidth) was making CanvasKit's output rougher.
            child: ClipOval(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.asset(
                "assets/app/profile.jpeg",
                width: 148,
                height: 148,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                // Decode at ~3x display size: downsampling the soft source
                // averages out its grain (looks smoother) while keeping enough
                // detail to stay sharp on high-DPI screens.
                cacheWidth: 444,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text("Nikhil Yadav", style: _titleStyle(ink)),
          const SizedBox(height: 8),
          Text(
            "Flutter Developer\n& AI Agent Engineer",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: ink.withOpacity(0.7),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          _ViewButton(
              label: "VIEW PROFILE",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const AboutDetail(), true)),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard();

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.work_outline),
          const SizedBox(height: 20),
          Text("Experience", style: _titleStyle(ink)),
          const SizedBox(height: 22),
          _role(ink, "Lead Developer", "TechFlow • Present", true),
          const SizedBox(height: 18),
          _role(ink, "Senior UI Eng", "Vanguard • 2021-2023", false),
          const Spacer(),
          _ViewButton(
              label: "VIEW TIMELINE",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const ExperienceDetail(), true)),
        ],
      ),
    );
  }

  Widget _role(Color ink, String title, String sub, bool filled) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? ink : Colors.transparent,
            border: Border.all(color: ink, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    color: ink, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 2),
            Text(sub,
                style: GoogleFonts.inter(
                    color: ink.withOpacity(0.6), fontSize: 12.5)),
          ],
        ),
      ],
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  const _ProjectsCard();

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    final accent = context.watch<CurrentState>().accent;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.grid_view),
          const SizedBox(height: 20),
          Text("Projects", style: _titleStyle(ink)),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _tile(accent, 0.9, Icons.insights),
                _tile(accent, 0.6, Icons.phone_iphone),
                _tile(accent, 0.25, Icons.terminal),
                _tile(accent, 0.25, Icons.devices),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ViewButton(
              label: "VIEW GALLERY",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const ProjectsDetail(), true)),
        ],
      ),
    );
  }

  Widget _tile(Color accent, double strength, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.15 + strength * 0.5),
            accent.withOpacity(0.08 + strength * 0.25),
          ],
        ),
      ),
      child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 26),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard();

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    final soft = context.watch<CurrentState>().softAccent;
    const skills = [
      "React",
      "TypeScript",
      "Figma",
      "Tailwind",
      "UX Design",
      "Next.js"
    ];
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.code),
          const SizedBox(height: 20),
          Text("Skills", style: _titleStyle(ink)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map((s) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.6)),
                ),
                child: Text(
                  s,
                  style: GoogleFonts.inter(
                      color: ink, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          _ViewButton(
              label: "VIEW STACK",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const SkillsDetail(), true)),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.school_outlined),
          const SizedBox(height: 20),
          Text("Education", style: _titleStyle(ink)),
          const SizedBox(height: 10),
          Text(
            "Academic Background",
            style: GoogleFonts.inter(
              color: ink.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          _ViewButton(
              label: "VIEW DEGREES",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const EducationDetail(), true)),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    final ink = context.watch<CurrentState>().inkAccent;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.mail_outline),
          const SizedBox(height: 20),
          Text("Contact", style: _titleStyle(ink)),
          const SizedBox(height: 10),
          Text(
            "Get in Touch",
            style: GoogleFonts.inter(
              color: ink.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          _ViewButton(
              label: "SEND MESSAGE",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const ContactDetail(), true)),
        ],
      ),
    );
  }
}
