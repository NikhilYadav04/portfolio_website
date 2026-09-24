import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/data.dart';
import '../providers/current_state.dart';
import 'glass_button.dart';
import 'mood_picker.dart';
import 'social_row.dart';
import 'type_scale.dart';

/// Opens the settings sheet from the phone's gear icon.
///
/// On a phone-sized screen the side panels aren't shown, so this is where the
/// mood picker, résumé, email and socials live. On desktop it offers the same
/// things, so the gear never does nothing.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    constraints: const BoxConstraints(maxWidth: 440),
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    // The near hill colour, mostly opaque: same family as the desktop glass
    // wash, but dense enough that the white text never fights the phone
    // content behind it.
    final Color tint = context.select<CurrentState, Color>(
      (s) => s.hillTones.last,
    );
    final Color dim = Colors.white.withOpacity(0.62);
    const radius = BorderRadius.vertical(top: Radius.circular(24));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            color: tint.withOpacity(0.86),
            borderRadius: radius,
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.28)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const MoodPicker(),
                  Container(height: 1, color: Colors.white.withOpacity(0.14)),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "open to work · $openTo",
                      style: monoStyle(Colors.white, size: 10.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: "Résumé",
                          icon: Icons.description_outlined,
                          primary: true,
                          height: 44,
                          onTap: () =>
                              context.read<CurrentState>().openResume(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassButton(
                          label: "Email",
                          icon: Icons.mail_outline,
                          height: 44,
                          onTap: () => context
                              .read<CurrentState>()
                              .launchInBrowser("mailto:$email"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SocialRow(
                    iconColor: Colors.white,
                    fill: Colors.white.withOpacity(0.10),
                    border: Colors.white.withOpacity(0.22),
                    size: 44,
                    gap: 10,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SelectableText(
                      email,
                      style: monoStyle(dim, size: 10.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
