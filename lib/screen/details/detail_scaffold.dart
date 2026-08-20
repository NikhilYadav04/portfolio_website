import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/homescreen/phone_home_page.dart';
import 'package:awesome_portfolio/widgets/type_scale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shared shell for the light, mood-adaptive detail screens.
///
/// A detail page opens with the masthead of the card that led you here — the
/// same mono eyebrow, the same Sora title, the same hairline. Tapping
/// "view timeline" on a card that reads `5 roles · 3 active / Experience`
/// lands on a page that opens exactly that way, so the card becomes the page
/// rather than handing off to a screen with its own separate vocabulary.
///
/// The top bar carries only the back arrow and a lowercase breadcrumb; the real
/// title lives in the scroll content, which is also why no screen needs to
/// render its own heading on top of this one.
class DetailScaffold extends StatelessWidget {
  final String title;

  /// Mono line above the title — the same counts the home card showed.
  final String? eyebrow;

  /// Live dot ahead of the eyebrow, for sections with something ongoing.
  final bool pulse;

  final List<Widget> children;

  const DetailScaffold({
    super.key,
    required this.title,
    required this.children,
    this.eyebrow,
    this.pulse = false,
  });

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
            // Top bar: back arrow + lowercase breadcrumb. Deliberately quiet —
            // the page's own masthead does the announcing.
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context
                          .read<CurrentState>()
                          .changePhoneScreen(const PhoneHomeScreen(), true),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back,
                            color: state.inkAccent, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    title.toLowerCase(),
                    style: monoStyle(state.inkAccent.withOpacity(0.55),
                        size: 10),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  _Masthead(
                      title: title, eyebrow: eyebrow, pulse: pulse),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final bool pulse;
  const _Masthead({required this.title, this.eyebrow, this.pulse = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
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
                  eyebrow!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: monoStyle(state.inkAccent.withOpacity(0.68)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
        Text(title, style: displayStyle(state.inkAccent, size: 27)),
        const SizedBox(height: 12),
        Container(height: 1, color: state.hairline),
        const SizedBox(height: 18),
      ],
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

/// Lowercase mono heading for a block inside a [GlassCard]. Replaces the bold
/// Inter sub-headings so a card's internal structure is labelled in the same
/// voice as the page masthead above it.
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Text(label, style: monoStyle(state.inkAccent.withOpacity(0.62)));
  }
}

/// A hairline divider inside a card.
class CardRule extends StatelessWidget {
  const CardRule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: context.watch<CurrentState>().hairline,
    );
  }
}

/// Big mono number over a lowercase caption — the readout used for stats and
/// ratings, matching the tiles on the phone's Skills and Profile cards.
class Readout extends StatelessWidget {
  final String value;
  final String label;

  /// When false the value/label pair is rendered bare, for callers that supply
  /// their own container.
  final bool boxed;

  const Readout({
    super.key,
    required this.value,
    required this.label,
    this.boxed = true,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: monoStyle(state.inkAccent,
                size: 18, weight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(label, style: monoStyle(state.textMuted, size: 9)),
      ],
    );
    if (!boxed) return content;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: state.hairline),
      ),
      child: content,
    );
  }
}

/// Small rounded fact / tech chip. Same fill as the chips on the phone's Skills
/// card so a technology looks identical wherever it appears.
class SoftChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  const SoftChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: state.chipFill,
        borderRadius: BorderRadius.circular(18),
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
            style: rowSubStyle(state.inkAccent, size: 11.5)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Right-aligned mono marker — a year, "now", or a score — matching the marker
/// column on the phone's timeline cards.
class MonoMarker extends StatelessWidget {
  final String label;
  final bool live;
  final bool boxed;
  const MonoMarker(this.label,
      {super.key, this.live = false, this.boxed = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    if (!boxed) {
      return Text(
        label,
        style: monoStyle(live ? state.accent : state.textMuted,
            size: 10, weight: live ? FontWeight.w500 : FontWeight.w400),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: state.accent.withOpacity(0.35)),
      ),
      child: Text(label,
          style:
              monoStyle(state.inkAccent, size: 10, weight: FontWeight.w500)),
    );
  }
}

/// Two-letter monogram tile, matching the projects column on the phone card.
class MonogramTile extends StatelessWidget {
  final String initials;
  final double size;
  const MonogramTile(this.initials, {super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CurrentState>();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: state.chipFill,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        initials,
        style: monoStyle(state.inkAccent,
            size: size * 0.3, weight: FontWeight.w600),
      ),
    );
  }
}
