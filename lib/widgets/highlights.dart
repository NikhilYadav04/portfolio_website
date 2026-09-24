import 'dart:async';

import 'package:flutter/material.dart';

import '../consts/data.dart';
import 'type_scale.dart';

/// Right-hand lower panel: rotates through [highlights] — proof points, where
/// the filler quotes used to be.
class Highlights extends StatefulWidget {
  const Highlights({super.key});

  @override
  State<Highlights> createState() => _HighlightsState();
}

class _HighlightsState extends State<Highlights> {
  int _i = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _i = (_i + 1) % highlights.length);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final item = highlights[_i];
    final Color dim = Colors.white.withOpacity(0.62);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("highlights", style: monoStyle(dim, size: 10.5)),
          Expanded(
            // Sequential, not a crossfade: the old item fades out in the first
            // half, the new one fades up in the second. Both curves use
            // Interval(0.5, 1) because the outgoing child runs in reverse.
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: reduce ? 0 : 700),
              switchInCurve: const Interval(0.5, 1, curve: Curves.easeOut),
              switchOutCurve: const Interval(0.5, 1, curve: Curves.easeIn),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, if (current != null) current],
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey(_i),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item[0], style: displayStyle(Colors.white, size: 20)),
                  const SizedBox(height: 6),
                  Text(item[1], style: monoStyle(dim, size: 10.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
