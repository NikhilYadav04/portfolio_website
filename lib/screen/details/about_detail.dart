import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/details/detail_scaffold.dart';
import 'package:awesome_portfolio/widgets/type_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// About detail — avatar, name, role, the bio card, and the same proof strip
/// the phone's Profile card shows. The numbers are deliberately the ones on
/// that card; two screens quoting different counts for the same career reads
/// as a mistake, because it is one.
class AboutDetail extends StatelessWidget {
  const AboutDetail({super.key});

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
    final accent = state.accent;

    return DetailScaffold(
      title: "About",
      eyebrow: "currently building AI agents",
      pulse: true,
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.35), blurRadius: 18)
              ],
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
              style: displayStyle(state.textPrimary, size: 23)),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text("Building AI agents & mobile apps",
              style: rowSubStyle(state.textMuted, size: 12.5)),
        ),
        const SizedBox(height: 18),
        // Proof strip — same three numbers as the Profile card.
        Row(
          children: [
            for (int i = 0; i < _stats.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Readout(value: _stats[i][0], label: _stats[i][1]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel("about"),
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
                style: bodyStyle(state.textPrimary.withOpacity(0.85)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final s in _socials)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _social(context, state, s[0], s[1]),
              ),
          ],
        ),
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.chipFill,
          ),
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(state.inkAccent, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
