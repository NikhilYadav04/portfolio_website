import 'package:awesome_portfolio/consts/moods.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'type_scale.dart';

/// Right-hand upper panel: pick the mood, which re-colours the whole world
/// (sky, hills, rain, accents, the phone inside).
///
/// Flat swatches, each named, with a ring on the current one. The old 3D
/// press-buttons were a separate visual style and gave no hint what each
/// colour did.
class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key});

  static String _rainLabel(RainIntensity r) => switch (r) {
    RainIntensity.none => "no rain",
    RainIntensity.light => "light rain",
    RainIntensity.heavy => "heavy rain",
  };

  @override
  Widget build(BuildContext context) {
    final Mood current = context.select<CurrentState, Mood>(
      (s) => s.currentMood,
    );
    final MoodSpec spec = moodSpec(current);
    final Color dim = Colors.white.withOpacity(0.62);

    // Sized to its content and centred, so it sits in the middle of a fixed
    // panel and wraps tightly in the settings sheet.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("mood", style: monoStyle(dim, size: 10.5)),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                spec.label,
                key: ValueKey(current),
                style: displayStyle(Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 4),
            Text(_rainLabel(spec.rain), style: monoStyle(dim, size: 10.5)),
            const SizedBox(height: 26),
            for (final row in [moods.sublist(0, 3), moods.sublist(3)]) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final m in row)
                    _Swatch(spec: m, selected: m.mood == current),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatefulWidget {
  final MoodSpec spec;
  final bool selected;
  const _Swatch({required this.spec, required this.selected});

  @override
  State<_Swatch> createState() => _SwatchState();
}

class _SwatchState extends State<_Swatch> {
  bool _focus = false;

  void _pick() => context.read<CurrentState>().setMood(widget.spec.mood);

  @override
  Widget build(BuildContext context) {
    final bool on = widget.selected;
    final Color c = widget.spec.accent;
    return Semantics(
      button: true,
      selected: on,
      label: "${widget.spec.label} mood",
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _pick();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: _pick,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  border: on || _focus
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: on
                      ? [BoxShadow(color: c.withOpacity(0.45), spreadRadius: 4)]
                      : null,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.spec.label.toLowerCase(),
                style: monoStyle(
                  on ? Colors.white : Colors.white.withOpacity(0.62),
                  size: 9.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
