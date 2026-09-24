import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../consts/data.dart';
import '../providers/current_state.dart';
import 'frosted_container.dart';
import 'type_scale.dart';

/// "view on · Android · iPhone · iPad" — picks the frame the portfolio is
/// shown in. Replaces three unlabelled black 3D icon buttons, which read as
/// app-store links.
class DeviceSwitch extends StatelessWidget {
  const DeviceSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final DeviceInfo current = context.select<CurrentState, DeviceInfo>(
      (s) => s.currentDevice,
    );
    return FrostedWidget(
      width: 320,
      height: 40,
      radius: 14,
      childW: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
        child: Row(
          children: [
            Text(
              "view on",
              style: monoStyle(Colors.white.withOpacity(0.62), size: 10.5),
            ),
            const Spacer(),
            for (final d in devices)
              _Segment(
                label: d.label,
                selected: d.device == current,
                onTap: () =>
                    context.read<CurrentState>().changeSelectedDevice(d.device),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _focus = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool on = widget.selected;
    return Semantics(
      button: true,
      selected: on,
      label: "View on ${widget.label}",
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        onShowHoverHighlight: (v) => setState(() => _hover = v),
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
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: on
                  ? Colors.white.withOpacity(0.92)
                  : Colors.white.withOpacity(_hover ? 0.10 : 0),
              borderRadius: BorderRadius.circular(10),
              border: _focus
                  ? Border.all(color: Colors.white, width: 1.5)
                  : null,
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                color: on
                    ? const Color(0xFF0F1B2D)
                    : Colors.white.withOpacity(0.82),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
