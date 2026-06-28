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
            "Building AI Agents\n& Mobile Apps",
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

  static const _roles = [
    ["Summer Research Intern", "NIT Calicut", "Present", "1"],
    ["Software Developer Intern", "Navicon Infraprojects", "Present", "1"],
    ["Technical Contributor", "SNDT University", "2025", "0"],
    ["App Development Intern", "Boomlex Technologies", "2025", "0"],
    ["Open Source Contributor", "GirlScript SoC", "Present", "1"],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.work_outline),
          const SizedBox(height: 18),
          Text("Experience", style: _titleStyle(state.inkAccent)),
          const SizedBox(height: 4),
          Text("${_roles.length} roles · 3 currently active",
              style: GoogleFonts.inter(
                  color: state.textMuted, fontSize: 12.5)),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _roles.length; i++)
                  _role(state, _roles[i], isLast: i == _roles.length - 1),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _ViewButton(
              label: "VIEW TIMELINE",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const ExperienceDetail(), true)),
        ],
      ),
    );
  }

  Widget _role(CurrentState state, List<String> r, {required bool isLast}) {
    final bool present = r[3] == "1";
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail: dot + connector.
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: present ? state.accent : Colors.white,
                  border: Border.all(color: state.accent, width: 1.8),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 1.5,
                      color: state.accent.withOpacity(0.22)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(r[0],
                            style: GoogleFonts.inter(
                                color: state.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5)),
                      ),
                      if (present) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("${r[1]} · ${r[2]}",
                      style: GoogleFonts.inter(
                          color: state.textMuted, fontSize: 11.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  const _ProjectsCard();

  // [name, subtitle, logo (or null), iconKey] — all 7, strongest first.
  static const _projects = [
    ["PillBin", "Offline-first medicine manager", "assets/app/pillbin.webp", "med"],
    ["TrialMatch", "AI clinical trial matching", "assets/app/trial.png", "bio"],
    ["Storyboardiac", "AI screenwriting & storyboards", "assets/app/story.png", "movie"],
    ["ChatConnect", "Real-time chat, voice & video", null, "chat"],
    ["Code DNA", "GitHub profile as an organism", null, "dna"],
    ["SplitEase", "Real-time expense splitting", null, "receipt"],
    ["Attend Ease", "Attendance & leave management", "assets/app/attend.png", "finger"],
  ];

  IconData _iconFor(String key) {
    switch (key) {
      case "med":
        return Icons.medication_outlined;
      case "bio":
        return Icons.biotech_outlined;
      case "movie":
        return Icons.movie_filter_outlined;
      case "chat":
        return Icons.chat_bubble_outline;
      case "dna":
        return Icons.biotech;
      case "receipt":
        return Icons.receipt_long_outlined;
      default:
        return Icons.fingerprint;
    }
  }

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
          const SizedBox(height: 4),
          Text("7 featured builds",
              style: GoogleFonts.inter(
                  color: context.watch<CurrentState>().textMuted,
                  fontSize: 12.5)),
          const SizedBox(height: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final p in _projects)
                  _row(context, accent, p[2], _iconFor(p[3]!), p[0]!, p[1]!),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _ViewButton(
              label: "VIEW GALLERY",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const ProjectsDetail(), true)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Color accent, String? logo, IconData icon,
      String name, String sub) {
    final state = context.watch<CurrentState>();
    return Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: logo != null ? Colors.white : accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: logo != null
                ? Image.asset(
                    logo,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: 108,
                    errorBuilder: (_, __, ___) =>
                        Icon(icon, size: 19, color: state.inkAccent),
                  )
                : Icon(icon, size: 19, color: state.inkAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.inter(
                        color: state.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(sub,
                    style: GoogleFonts.inter(
                        color: state.textMuted, fontSize: 10.5)),
              ],
            ),
          ),
        ],
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final ink = state.inkAccent;
    final soft = state.softAccent;
    const skills = [
      "Flutter",
      "Dart",
      "Python",
      "C++",
      "Node.js",
      "FastAPI",
      "LangGraph",
      "MongoDB",
    ];
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.code),
          const SizedBox(height: 20),
          Text("Skills", style: _titleStyle(ink)),
          const SizedBox(height: 18),
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
          // Competitive-programming proof tiles fill the lower half.
          Row(
            children: [
              Expanded(
                child: _cpTile(state, "CodeChef", "3★ (1616)"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _cpTile(state, "LeetCode", "Knight (1868)"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ViewButton(
              label: "VIEW STACK",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const SkillsDetail(), true)),
        ],
      ),
    );
  }

  Widget _cpTile(CurrentState state, String platform, String rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: state.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(platform,
              style: GoogleFonts.inter(
                  color: state.inkAccent.withOpacity(0.7),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(rank,
              style: GoogleFonts.inter(
                  color: state.inkAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  static const _entries = [
    ["B.Tech, ECE", "IIIT Ranchi · 2023–2027", "8.96 CGPA", "1"],
    ["HSC", "Kamaladevi College · 2020–2022", "80.83%", "0"],
    ["SSC", "St. Mary's High School · 2016–2020", "93.00%", "0"],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.school_outlined),
          const SizedBox(height: 18),
          Text("Education", style: _titleStyle(state.inkAccent)),
          const SizedBox(height: 4),
          Text("Academic journey",
              style: GoogleFonts.inter(
                  color: state.textMuted, fontSize: 12.5)),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _entries.length; i++)
                  _entry(state, _entries[i], isLast: i == _entries.length - 1),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _ViewButton(
              label: "VIEW DEGREES",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const EducationDetail(), true)),
        ],
      ),
    );
  }

  Widget _entry(CurrentState state, List<String> e, {required bool isLast}) {
    final bool current = e[3] == "1";
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current ? state.accent : Colors.white,
                  border: Border.all(color: state.accent, width: 1.8),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 1.5, color: state.accent.withOpacity(0.22)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e[0],
                            style: GoogleFonts.inter(
                                color: state.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: state.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: state.accent.withOpacity(0.3)),
                        ),
                        child: Text(e[2],
                            style: GoogleFonts.inter(
                                color: state.inkAccent,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(e[1],
                      style: GoogleFonts.inter(
                          color: state.textMuted, fontSize: 11.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  static const _links = [
    (Icons.code, "GitHub", "https://github.com/NikhilYadav04"),
    (
      Icons.work_outline,
      "LinkedIn",
      "https://www.linkedin.com/in/nikhil-yadav-1a14062a2"
    ),
    (
      Icons.camera_alt_outlined,
      "Instagram",
      "https://www.instagram.com/yadav_17_05/"
    ),
    (Icons.mail_outline, "Email", "mailto:byadav1723@gmail.com"),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final ink = state.inkAccent;
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardBadge(icon: Icons.mail_outline),
          const SizedBox(height: 20),
          Text("Contact", style: _titleStyle(ink)),
          const SizedBox(height: 8),
          Text(
            "Open to internships, freelance\n& collaborations.",
            style: GoogleFonts.inter(
              color: ink.withOpacity(0.7),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const Spacer(),
          // Tappable social tiles — direct links from the home card.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _links.map((l) {
              return GestureDetector(
                onTap: () =>
                    context.read<CurrentState>().launchInBrowser(l.$3),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: state.accent.withOpacity(0.3)),
                      ),
                      child: Icon(l.$1, color: ink, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(l.$2,
                        style: GoogleFonts.inter(
                            color: ink.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              "byadav1723@gmail.com",
              style: GoogleFonts.inter(
                color: ink.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
