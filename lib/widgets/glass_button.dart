import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A button for use on the glass panels around the phone.
///
/// * **primary** — near-white fill with dark text: the one action a panel is
///   for. Dark on white keeps full contrast whatever the mood colour is.
/// * **ghost** — translucent with a hairline border, for the secondary action.
///
/// Brightens on hover, and draws a visible ring when reached by keyboard
/// (Tab) — Enter or Space activates it.
class GlassButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final double height;

  const GlassButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.height = 40,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _hover = false;
  bool _focus = false;

  static const Color _ink = Color(0xFF0F1B2D);

  @override
  Widget build(BuildContext context) {
    final bool p = widget.primary;
    final Color fg = p ? _ink : Colors.white;
    final Color bg = p
        ? Colors.white.withOpacity(_hover ? 1.0 : 0.94)
        : Colors.white.withOpacity(_hover ? 0.16 : 0.08);

    return Semantics(
      button: true,
      label: widget.label,
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
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: p
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.28)),
              boxShadow: _focus
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 16, color: fg),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    color: fg,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
