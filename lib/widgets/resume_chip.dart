import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/current_state.dart';
import 'type_scale.dart';

/// `résumé ↓` — a pill that opens the résumé PDF, for use inside the phone
/// (Profile card, About screen). Colours come from the caller so it matches
/// the surface it sits on.
class ResumeChip extends StatefulWidget {
  final Color ink;
  final Color fill;
  const ResumeChip({super.key, required this.ink, required this.fill});

  @override
  State<ResumeChip> createState() => _ResumeChipState();
}

class _ResumeChipState extends State<ResumeChip> {
  bool _hover = false;
  bool _focus = false;

  void _open() => context.read<CurrentState>().openResume();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: "Open résumé",
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hover = v),
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _open();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _hover ? widget.ink.withOpacity(0.14) : widget.fill,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: widget.ink.withOpacity(_focus ? 0.9 : 0.25),
                width: _focus ? 1.5 : 1,
              ),
            ),
            child: Text(
              "résumé ↓",
              style: monoStyle(widget.ink, size: 11, weight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
