import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/data.dart';
import '../providers/current_state.dart';
import 'glass_button.dart';
import 'pulse_dot.dart';
import 'type_scale.dart';

/// Left-hand lower panel: the clear next step for a visitor.
class ContactPanel extends StatelessWidget {
  const ContactPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = context.select<CurrentState, Color>((s) => s.accent);
    final Color dim = Colors.white.withOpacity(0.62);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PulseDot(color: accent),
              const SizedBox(width: 8),
              Text(
                "open to work",
                style: monoStyle(Colors.white, size: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            // Lines up under the text, past the dot.
            padding: const EdgeInsets.only(left: 15),
            child: Text(openTo, style: monoStyle(dim, size: 10)),
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: "Résumé",
            icon: Icons.description_outlined,
            primary: true,
            onTap: () => context.read<CurrentState>().openResume(),
          ),
          const SizedBox(height: 10),
          GlassButton(
            label: "Email",
            icon: Icons.mail_outline,
            onTap: () =>
                context.read<CurrentState>().launchInBrowser("mailto:$email"),
          ),
          const Spacer(),
          // Shown in full so it can be read or copied without a mail client.
          Center(child: SelectableText(email, style: monoStyle(dim, size: 10))),
        ],
      ),
    );
  }
}
