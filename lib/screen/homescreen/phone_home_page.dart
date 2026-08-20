import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../consts/data.dart';
import '../../providers/current_state.dart';
import '../../widgets/type_scale.dart';
import '../details/about_detail.dart';
import '../details/achievements_detail.dart';
import '../details/education_detail.dart';
import '../details/experience_detail.dart';
import '../details/projects_detail.dart';
import '../details/skills_detail.dart';

/// The phone home screen — a 6-page section carousel.
///
/// Every card shares one masthead grammar: a monospaced eyebrow carrying real
/// counts, a display-face title, a hairline rule, the content, and a quiet
/// footer bar. The eyebrow/date/readout voice is Fira Code — the same face the
/// glass panels outside the phone speak in — so the inside reads as part of the
/// same instrument rather than a card template that happens to sit in a frame.
///
/// Every colour is derived from the active [CurrentState] mood, so the inside
/// breathes with the world outside the phone.
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
    Icons.emoji_events_outlined,
  ];

  static const _pages = [
    _ProfileCard(),
    _ExperienceCard(),
    _ProjectsCard(),
    _SkillsCard(),
    _EducationCard(),
    _AchievementsCard(),
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

  /// Depth falloff: the card you're on sits forward, its neighbours drop back a
  /// little in scale and opacity. Driven by the scroll offset itself, so the
  /// settle is continuous with the swipe instead of a separate animation.
  Widget _depth(int index, Widget child, bool reduceMotion) {
    if (reduceMotion) return child;
    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, ch) {
        final double current =
            (_controller.hasClients && _controller.position.haveDimensions)
                ? (_controller.page ?? _page.toDouble())
                : _page.toDouble();
        final double t = (current - index).abs().clamp(0.0, 1.0);
        return Transform.scale(
          scale: 1 - 0.06 * t,
          child: Opacity(
            opacity: 1 - 0.42 * t,
            child: _Depth(t: t, child: ch!),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

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
            _TopBar(accent: state.accent),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) =>
                    _depth(i, _pages[i], reduceMotion),
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

/// How far the enclosing card is from the centre of the carousel: 0 when it is
/// the focused page, 1 once it is a full page away. Card blocks read this to
/// settle at slightly different rates as you swipe.
class _Depth extends InheritedWidget {
  final double t;
  const _Depth({required this.t, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Depth>()?.t ?? 0;

  @override
  bool updateShouldNotify(_Depth oldWidget) => oldWidget.t != t;
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
              border:
                  Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
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
// Card shell + the shared masthead grammar
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
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: child,
        ),
      ),
    );
  }
}

/// The four-part grammar every section card is built from: masthead, hairline,
/// content, footer bar. Content is top-aligned and the footer is pinned, so
/// the rhythm holds identically on a short phone and a tall one.
class _CardScaffold extends StatelessWidget {
  final String eyebrow;
  final bool pulse;
  final String title;
  final Widget body;
  final String footerLabel;
  final VoidCallback onFooterTap;
  final Alignment bodyAlign;

  const _CardScaffold({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.footerLabel,
    required this.onFooterTap,
    this.pulse = false,
    this.bodyAlign = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final double t = _Depth.of(context);

    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: Offset(0, t * 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (pulse) ...[
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        eyebrow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: monoStyle(state.inkAccent.withOpacity(0.68)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(title, style: displayStyle(state.inkAccent)),
                const SizedBox(height: 12),
                Container(height: 1, color: state.hairline),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, t * 16),
              child: Align(alignment: bodyAlign, child: body),
            ),
          ),
          Transform.translate(
            offset: Offset(0, t * 24),
            child: _FooterBar(label: footerLabel, onTap: onFooterTap),
          ),
        ],
      ),
    );
  }
}

/// Quiet replacement for the old full-width white pill: a hairline, a lowercase
/// mono label, and the accent circled arrow. Still a full-width tap target.
class _FooterBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterBar({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Semantics(
      button: true,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 11, bottom: 2),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: state.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: monoStyle(state.inkAccent,
                        size: 10, weight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.accent,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-letter monogram tile. Replaces the loosely-picked Material icons on the
/// projects list — one consistent column instead of seven different marks.
class _MonoTile extends StatelessWidget {
  final String initials;
  const _MonoTile(this.initials);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: state.chipFill,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        initials,
        style: monoStyle(state.inkAccent, size: 12, weight: FontWeight.w600),
      ),
    );
  }
}

/// Rounded icon tile, same footprint as [_MonoTile] so the left-hand column
/// lines up whether a row is marked by initials or by an icon.
class _IconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool prominent;
  const _IconTile(this.icon, {this.size = 36, this.prominent = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: prominent ? state.accent.withOpacity(0.22) : state.chipFill,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: size * 0.48, color: state.inkAccent),
    );
  }
}

/// One entry on a timeline rail: dot, connector, title, subtitle, and a
/// right-aligned mono marker (a year, "now", or a score).
class _RailRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String marker;
  final bool filled;
  final bool isLast;
  final bool markerIsLive;
  final bool markerBoxed;
  final double gap;

  const _RailRow({
    required this.title,
    required this.subtitle,
    required this.marker,
    required this.filled,
    required this.isLast,
    this.markerIsLive = false,
    this.markerBoxed = false,
    this.gap = 50,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
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
                  color: filled ? state.accent : Colors.white,
                  border: Border.all(color: state.accent, width: 1.8),
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 1.5, color: state.railLine)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: rowTitleStyle(state.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _marker(state),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: rowSubStyle(state.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marker(CurrentState state) {
    final style = monoStyle(
      markerIsLive ? state.accent : state.textMuted,
      size: 9.5,
      weight: markerIsLive ? FontWeight.w500 : FontWeight.w400,
    );
    if (!markerBoxed) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(marker, style: style),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: state.accent.withOpacity(0.35)),
      ),
      child: Text(
        marker,
        style: monoStyle(state.inkAccent, size: 9.5, weight: FontWeight.w500),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pages
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  static const _stats = [
    ["7", "projects"],
    ["5", "roles"],
    ["1868", "leetcode"],
  ];

  static const _socials = [
    ["assets/icons/github.svg", github],
    ["assets/icons/linkedin.svg", linkedIn],
    ["assets/icons/twitter.svg", twitter],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final double t = _Depth.of(context);

    return _SectionShell(
      child: Column(
        children: [
          Expanded(
            child: Transform.translate(
              offset: Offset(0, t * 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: state.accent.withOpacity(0.4),
                            blurRadius: 22),
                      ],
                    ),
                    child: ClipOval(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.asset(
                        "assets/app/profile.jpeg",
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        // Decode at ~3x display size: downsampling the soft
                        // source averages out its grain while keeping enough
                        // detail to stay sharp on high-DPI screens.
                        cacheWidth: 360,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text("Nikhil Yadav",
                      style: displayStyle(state.inkAccent, size: 28)),
                  const SizedBox(height: 6),
                  Text(
                    "Building AI agents & mobile apps",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: state.textMuted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  // Proof strip — the numbers do the talking the empty space
                  // used to. Mono so they read as a readout, not as copy.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _stats.length; i++) ...[
                        if (i > 0)
                          Container(
                            width: 1,
                            height: 26,
                            color: state.hairline,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        _stat(state, _stats[i][0], _stats[i][1]),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final s in _socials)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _social(context, state, s[0], s[1]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, t * 24),
            child: _FooterBar(
              label: "view profile",
              onTap: () => context
                  .read<CurrentState>()
                  .changePhoneScreen(const AboutDetail(), true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(CurrentState state, String value, String label) {
    return Column(
      children: [
        Text(value,
            style: monoStyle(state.inkAccent, size: 15, weight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(label, style: monoStyle(state.textMuted, size: 8.5)),
      ],
    );
  }

  Widget _social(
      BuildContext context, CurrentState state, String asset, String link) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.read<CurrentState>().launchInBrowser(link),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.chipFill,
          ),
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: 14,
              height: 14,
              colorFilter:
                  ColorFilter.mode(state.inkAccent, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard();

  // [role, company, marker, currently-active]
  static const _roles = [
    ["Summer Research Intern", "NIT Calicut", "now", "1"],
    ["Software Developer Intern", "Navicon Infraprojects", "now", "1"],
    ["Technical Contributor", "SNDT University", "2025", "0"],
    ["App Development Intern", "Boomlex Technologies", "2025", "0"],
    ["Open Source Contributor", "GirlScript SoC", "now", "1"],
  ];

  @override
  Widget build(BuildContext context) {
    return _CardScaffold(
      eyebrow: "${_roles.length} roles · 3 active",
      pulse: true,
      title: "Experience",
      footerLabel: "view timeline",
      onFooterTap: () => context
          .read<CurrentState>()
          .changePhoneScreen(const ExperienceDetail(), true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _roles.length; i++)
            _RailRow(
              title: _roles[i][0],
              subtitle: _roles[i][1],
              marker: _roles[i][2],
              markerIsLive: _roles[i][3] == "1",
              filled: _roles[i][3] == "1",
              isLast: i == _roles.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ProjectsCard extends StatelessWidget {
  const _ProjectsCard();

  // [monogram, name, subtitle] — the six strongest builds; the seventh lives
  // in the gallery, which the footer says out loud.
  static const _projects = [
    ["PB", "PillBin", "Offline-first medicine manager"],
    ["TM", "TrialMatch", "AI clinical trial matching"],
    ["SB", "Storyboardiac", "AI screenwriting & storyboards"],
    ["CC", "ChatConnect", "Real-time chat, voice & video"],
    ["CD", "Code DNA", "GitHub profile as an organism"],
    ["SE", "SplitEase", "Real-time expense splitting"],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return _CardScaffold(
      eyebrow: "7 builds · 6 shown",
      title: "Projects",
      footerLabel: "view gallery · +1 more",
      onFooterTap: () => context
          .read<CurrentState>()
          .changePhoneScreen(const ProjectsDetail(), true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _projects.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == _projects.length - 1 ? 0 : 32),
              child: Row(
                children: [
                  _MonoTile(_projects[i][0]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_projects[i][1],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rowTitleStyle(state.textPrimary)),
                        const SizedBox(height: 1),
                        Text(_projects[i][2],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rowSubStyle(state.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard();

  // Grouped by what they're actually used for, rather than dumped as one cloud.
  static const _groups = [
    ["mobile", "Flutter,Dart"],
    ["backend", "Node.js,FastAPI,MongoDB"],
    ["ai & systems", "Python,LangGraph,C++"],
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return _CardScaffold(
      eyebrow: "stack · 8 primary",
      title: "Skills",
      footerLabel: "view stack",
      onFooterTap: () => context
          .read<CurrentState>()
          .changePhoneScreen(const SkillsDetail(), true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final g in _groups) ...[
            Text(g[0], style: monoStyle(state.textMuted, size: 9)),
            const SizedBox(height: 7),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final s in g[1].split(","))
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.chipFill,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.inter(
                        color: state.inkAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 6),
          // Competitive-programming ratings read as instrument readouts: the
          // number is the point, the platform is the caption.
          Row(
            children: [
              Expanded(child: _readout(state, "1868", "leetcode · knight")),
              const SizedBox(width: 10),
              Expanded(child: _readout(state, "1616", "codechef · 3★")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readout(CurrentState state, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: state.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: monoStyle(state.inkAccent, size: 17, weight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(label, style: monoStyle(state.textMuted, size: 8.5)),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  // [qualification, institution · years, score, current]
  static const _entries = [
    ["B.Tech, ECE", "IIIT Ranchi · 2023–2027", "9.07", "1"],
    ["HSC", "Kamaladevi College · 2020–2022", "80.83%", "0"],
    ["SSC", "St. Mary's High School · 2016–2020", "93.00%", "0"],
  ];

  @override
  Widget build(BuildContext context) {
    return _CardScaffold(
      eyebrow: "iiit ranchi · 9.07 cgpa",
      title: "Education",
      bodyAlign: Alignment.centerLeft,
      footerLabel: "view degrees",
      onFooterTap: () => context
          .read<CurrentState>()
          .changePhoneScreen(const EducationDetail(), true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _entries.length; i++)
            _RailRow(
              title: _entries[i][0],
              subtitle: _entries[i][1],
              marker: _entries[i][2],
              markerBoxed: true,
              gap: 64,
              filled: _entries[i][3] == "1",
              isLast: i == _entries.length - 1,
            ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard();

  // [category, title, detail, icon] — the win is promoted out of this list into
  // the hero above it, so the card has a top line instead of five equal rows.
  static const _items = [
    ["ui/ux", "Best UI/UX — Cinecode 2026", "Storyboardiac", "brush"],
    ["finalist", "Smart India Hackathon", "Top 0.5% of 2500+ teams", "medal"],
    ["merit", "Certificate of Merit — CIIA", "Mumbai · Top 50", "merit"],
    ["cert", "Postman API Student Expert", "Postman", "verified"],
  ];

  static IconData _iconFor(String key) {
    switch (key) {
      case "brush":
        return Icons.brush_outlined;
      case "medal":
        return Icons.workspace_premium_outlined;
      case "merit":
        return Icons.military_tech_outlined;
      case "verified":
        return Icons.verified_outlined;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return _CardScaffold(
      eyebrow: "5 awards · 2 first place",
      title: "Achievements",
      footerLabel: "view all",
      onFooterTap: () => context
          .read<CurrentState>()
          .changePhoneScreen(const AchievementsDetail(), true),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The win, given its own line and its own mark.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconTile(Icons.emoji_events, size: 40, prominent: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("1st Prize — YPIPA Hackathon",
                        style: displayStyle(state.inkAccent, size: 16.5)),
                    const SizedBox(height: 3),
                    Text("pillbin · 20+ teams",
                        style: monoStyle(state.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: state.hairline),
          const SizedBox(height: 18),
          for (int ai = 0; ai < _items.length; ai++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: ai == _items.length - 1 ? 0 : 46),
              child: Row(
                children: [
                  _IconTile(_iconFor(_items[ai][3])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_items[ai][1],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rowTitleStyle(state.textPrimary)),
                        const SizedBox(height: 1),
                        Text(_items[ai][2],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rowSubStyle(state.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
