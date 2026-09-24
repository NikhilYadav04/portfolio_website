import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// The one social row, rendered from [socialLinks].
///
/// The desktop business card, the phone's Profile card and the About screen
/// all use this, so they can't drift apart — the three hand-rolled copies it
/// replaced had each ended up pointing at a different set of accounts. Callers
/// choose only the styling; the links and their order come from `data.dart`.
class SocialRow extends StatelessWidget {
  /// Circle diameter.
  final double size;
  final double gap;
  final Color iconColor;
  final Color fill;
  final Color? border;
  final MainAxisAlignment alignment;

  const SocialRow({
    super.key,
    required this.iconColor,
    required this.fill,
    this.size = 34,
    this.gap = 10,
    this.border,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        for (int i = 0; i < socialLinks.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          _SocialButton(
            link: socialLinks[i],
            size: size,
            iconColor: iconColor,
            fill: fill,
            border: border,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final SocialLink link;
  final double size;
  final Color iconColor;
  final Color fill;
  final Color? border;

  const _SocialButton({
    required this.link,
    required this.size,
    required this.iconColor,
    required this.fill,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final double glyph = size * 0.44;
    return Semantics(
      link: true,
      label: link.label,
      child: Tooltip(
        message: link.label,
        waitDuration: const Duration(milliseconds: 400),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                context.read<CurrentState>().launchInBrowser(link.url),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                border: border == null ? null : Border.all(color: border!),
              ),
              child: Center(
                child: link.svgAsset != null
                    ? SvgPicture.asset(
                        link.svgAsset!,
                        width: glyph,
                        height: glyph,
                        colorFilter:
                            ColorFilter.mode(iconColor, BlendMode.srcIn),
                      )
                    : Icon(link.icon, size: glyph + 2, color: iconColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
