import 'dart:async';

import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/miniProjects/playground/playground_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 3 — plays a single [AgentDemo] as a stepped agent loop: the task chip
/// at top, then step nodes that reveal + activate one at a time, then a Replay.
/// The active mood accent themes the running node so it ties into the world.
class AgentRunView extends StatefulWidget {
  final AgentDemo demo;

  /// Optional extra panel rendered above the steps (the in-app phone mock).
  final Widget Function(int activeStep)? header;
  const AgentRunView({super.key, required this.demo, this.header});

  @override
  State<AgentRunView> createState() => _AgentRunViewState();
}

class _AgentRunViewState extends State<AgentRunView> {
  /// How many steps have been revealed. -1 before the run starts.
  int _revealed = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant AgentRunView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switching tabs restarts the run for the new demo.
    if (oldWidget.demo != widget.demo) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    setState(() => _revealed = -1);
    // Small lead-in, then reveal each step on a cadence.
    _timer = Timer.periodic(const Duration(milliseconds: 850), (t) {
      if (!mounted) return;
      if (_revealed >= widget.demo.steps.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _revealed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _done => _revealed >= widget.demo.steps.length - 1;

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;
    final steps = widget.demo.steps;

    return Container(
      color: const Color(0xFF0B0E16),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text(
            widget.demo.subtitle.toUpperCase(),
            style: GoogleFonts.firaCode(
              color: accent,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // The task / prompt chip that kicks off the run.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt, color: accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.demo.prompt,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.header != null) ...[
            const SizedBox(height: 16),
            widget.header!(_revealed),
          ],
          const SizedBox(height: 18),
          // Step nodes.
          ...List.generate(steps.length, (i) {
            final bool visible = i <= _revealed;
            final bool isActive = i == _revealed && !_done;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: visible ? 1 : 0.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: visible ? Offset.zero : const Offset(0, 0.2),
                child: _StepNode(
                  step: steps[i],
                  accent: accent,
                  isActive: isActive,
                  isLast: i == steps.length - 1,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // Replay control once the run finishes.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _done ? 1 : 0,
            child: Center(
              child: TextButton.icon(
                onPressed: _done ? _start : null,
                icon: Icon(Icons.replay, color: accent, size: 18),
                label: Text(
                  "Replay",
                  style: GoogleFonts.firaCode(color: accent, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final AgentStep step;
  final Color accent;
  final bool isActive;
  final bool isLast;
  const _StepNode({
    required this.step,
    required this.accent,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rail: node dot + connector line.
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(isActive ? 0.25 : 0.12),
                  border: Border.all(
                    color: isActive ? accent : accent.withOpacity(0.4),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 12)]
                      : null,
                ),
                child: Icon(stepIcon(step.kind), size: 15, color: accent),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: accent.withOpacity(0.18),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        stepKindLabel(step.kind),
                        style: GoogleFonts.firaCode(
                          color: accent,
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        _RunningDots(accent: accent),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (step.detail != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.detail!,
                      style: GoogleFonts.firaCode(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The little "…" that pulses while a step is running.
class _RunningDots extends StatefulWidget {
  final Color accent;
  const _RunningDots({required this.accent});

  @override
  State<_RunningDots> createState() => _RunningDotsState();
}

class _RunningDotsState extends State<_RunningDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final int active = (_c.value * 3).floor() % 3;
        return Row(
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accent.withOpacity(i == active ? 1 : 0.3),
              ),
            );
          }),
        );
      },
    );
  }
}
