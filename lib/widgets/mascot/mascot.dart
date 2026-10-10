import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/moods.dart';
import '../../providers/current_state.dart';
import '../type_scale.dart';
import 'mascot_bridge.dart';
import 'mascot_director.dart';

/// Strobi, the site mascot, at [size] logical pixels square.
///
/// Two halves:
///  * the face, drawn by the page (an HTML element over Flutter's canvas) and
///    driven by [MascotDirector];
///  * the body acting — float, hop, shiver, squash — done here with a
///    transform, because the renderer can't move the body.
///
/// Flutter's blur and opacity don't reach the HTML element, so place this
/// outside glass panels and fade-ins. Renders nothing off the web, or if
/// `web/mascot/mascot.js` failed to load.
class Mascot extends StatefulWidget {
  final double size;
  const Mascot({super.key, required this.size});

  /// `?mascot=debug` shows what's playing under each Strobi.
  static final bool _debug = Uri.base.queryParameters['mascot'] == 'debug';

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  final MascotDirector _director = MascotDirector.instance;
  Object? _element;

  /// Free-running clock for the float and shiver. 9s is a whole number of
  /// cycles of each (3s float, 4.5s slow float, 12Hz shiver), so the loop
  /// point never jumps.
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );

  late final AnimationController _squash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  /// Pose eases between float / shiver / sink instead of snapping.
  late final AnimationController _sink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    _director.hops.addListener(_onHop);
    _director.squashes.addListener(_onSquash);
    _director.pose.addListener(_onPose);
    _director.attach(_centre);
    _onPose();
  }

  void _onHop() => _hop.forward(from: 0);
  void _onSquash() => _squash.forward(from: 0);
  void _onPose() => _director.pose.value == MascotPose.sink
      ? _sink.forward()
      : _sink.reverse();

  @override
  void dispose() {
    _director.hops.removeListener(_onHop);
    _director.squashes.removeListener(_onSquash);
    _director.pose.removeListener(_onPose);
    _director.detach(_centre);
    _clock.dispose();
    _hop.dispose();
    _squash.dispose();
    _sink.dispose();
    final el = _element;
    if (el != null) mascotUnmount(el);
    super.dispose();
  }

  /// Screen centre, for the director's cursor looks.
  Offset? _centre() {
    if (!mounted) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  /// Hop: rises 22px, stretching on the way up, squashes on landing.
  /// Returns (dy, scaleX, scaleY).
  (double, double, double) _hopAt(double t) {
    if (t <= 0 || t >= 1) return (0, 1, 1);
    if (t < 0.78) {
      final double p = t / 0.78;
      final double lift = math.sin(p * math.pi);
      final double stretch = 0.12 * math.sin(p * math.pi).clamp(0, 1) * (1 - p);
      return (-22 * lift, 1 - stretch * 0.6, 1 + stretch);
    }
    // Landing squash, easing out.
    final double p = (t - 0.78) / 0.22;
    final double s = 0.14 * math.sin(p * math.pi);
    return (0, 1 + s * 0.7, 1 - s);
  }

  /// Squash when clicked: flattens to 80%, then springs back with overshoot.
  (double, double) _squashAt(double t) {
    if (t <= 0 || t >= 1) return (1, 1);
    final double v = t < 0.18
        ? 0.2 * Curves.easeOut.transform(t / 0.18)
        : 0.2 * (1 - Curves.elasticOut.transform((t - 0.18) / 0.82));
    return (1 + v * 0.75, 1 - v);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !mascotSupported) return const SizedBox.shrink();

    final Mood mood = context.select<CurrentState, Mood>((s) => s.currentMood);
    final bool booted = context.select<CurrentState, bool>((s) => s.booted);
    // Idempotent; sends nothing to the page unless the animation changes.
    _director.sync(mood: mood, booted: booted);

    final bool still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    Widget face = SizedBox.square(
      dimension: widget.size,
      child: HtmlElementView.fromTagName(
        tagName: 'div',
        onElementCreated: (el) {
          _element = el;
          // Starts on whatever the director last asked for.
          mascotMount(el);
        },
      ),
    );

    if (!still) {
      face = AnimatedBuilder(
        animation: Listenable.merge([_clock, _hop, _squash, _sink]),
        child: face,
        builder: (context, child) {
          final double secs = _clock.value * 9;
          final double sink = Curves.easeInOut.transform(_sink.value);
          final MascotPose pose = _director.pose.value;

          // Float: ±3px over 3s; slower and deeper "breathing" when sunk.
          final double period = sink > 0.5 ? 4.5 : 3.0;
          final double float =
              math.sin(secs / period * 2 * math.pi) * (3 + sink * 1.5);
          final double shiver = pose == MascotPose.shiver
              ? math.sin(secs * 12 * 2 * math.pi) * 1.6
              : 0;
          final (hopY, hopSx, hopSy) = _hopAt(_hop.value);
          final (sqX, sqY) = _squashAt(_squash.value);

          return Transform(
            // Scale from the feet, so squashes sit on the panel edge.
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..translateByDouble(shiver, float + hopY + sink * 6, 0, 1)
              ..scaleByDouble(hopSx * sqX, hopSy * sqY, 1, 1),
            child: child,
          );
        },
      );
    }

    if (!Mascot._debug) return face;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        face,
        ValueListenableBuilder<String>(
          valueListenable: _director.debug,
          builder: (_, text, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: Colors.black87,
            child: Text(text, style: monoStyle(Colors.white, size: 9)),
          ),
        ),
      ],
    );
  }
}
