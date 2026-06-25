import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Phase 1 — reactive world.
///
/// Translates its [child] opposite to the cursor by [depth] logical pixels at
/// full deflection. Bigger [depth] = the layer feels closer to the viewer
/// (clouds small, phone medium, panels larger). Animated so the drift eases
/// instead of snapping frame-to-frame.
class ParallaxLayer extends StatelessWidget {
  final Widget child;
  final double depth;

  /// When true the layer moves *with* the cursor instead of against it — used
  /// sparingly for foreground accents.
  final bool invert;

  const ParallaxLayer({
    super.key,
    required this.child,
    this.depth = 12,
    this.invert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<CurrentState, Offset>(
      selector: (_, s) => s.pointer,
      builder: (context, pointer, child) {
        final double sign = invert ? 1 : -1;
        final Offset shift = Offset(
          sign * pointer.dx * depth,
          sign * pointer.dy * depth,
        );
        // The pointer is already low-pass smoothed in CurrentState, so keep
        // this follow short — a long duration here would double-lag and feel
        // mushy.
        return AnimatedSlide(
          offset: Offset(shift.dx / 100, shift.dy / 100),
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Tilts the phone (or any [child]) in 3D toward the cursor. The original
/// template had a fixed `rotateY(-0.06)`; this makes that tilt live.
class CursorTilt extends StatelessWidget {
  final Widget child;

  /// Max tilt in radians at full cursor deflection. Kept very small + clamped
  /// so it reads as a barely-there "alive" lean rather than a swing.
  final double maxTilt;
  final Alignment alignment;

  const CursorTilt({
    super.key,
    required this.child,
    this.maxTilt = 0.018,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<CurrentState, Offset>(
      selector: (_, s) => s.pointer,
      builder: (context, pointer, child) {
        final double rotY = (pointer.dx * maxTilt).clamp(-maxTilt, maxTilt);
        final double rotX = (-pointer.dy * maxTilt).clamp(-maxTilt, maxTilt);
        return TweenAnimationBuilder<Offset>(
          tween: Tween(end: Offset(rotX, rotY)),
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform(
              alignment: alignment,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(value.dx)
                ..rotateY(value.dy),
              child: child,
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
