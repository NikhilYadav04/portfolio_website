import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/current_state.dart';

/// The one glass surface used by every panel in the scene around the phone.
///
/// Recipe, back to front:
///  * a soft drop shadow drawn only *outside* the panel. A plain `BoxShadow`
///    would also paint beneath the translucent glass and grey it out, which is
///    what the old version did (a solid 25% black layer under the fill).
///  * the backdrop, blurred (σ22) and slightly saturated so the sky and hills
///    behind read as colour, not mush;
///  * a wash of the mood's near-hill colour, which keeps white text readable
///    over the bright Dawn / Dusk / Midday skies;
///  * a thin white fill fading top-left to bottom-right, and a soft highlight
///    in the top-left corner;
///  * a 1px edge that fades from bright to faint, the cue that sells "glass".
class FrostedWidget extends StatelessWidget {
  final void Function()? onPressed;
  final Widget childW;
  final double height;
  final double width;
  final double radius;

  const FrostedWidget({
    super.key,
    this.height = 150,
    this.width = 200,
    this.radius = 24,
    required this.childW,
    this.onPressed,
  });

  // Saturation ×1.35 around Rec. 709 luminance.
  static const double _s = 1.35;
  static const ColorFilter _saturate = ColorFilter.matrix(<double>[
    0.2126 + 0.7874 * _s,
    0.7152 - 0.7152 * _s,
    0.0722 - 0.0722 * _s,
    0,
    0,
    0.2126 - 0.2126 * _s,
    0.7152 + 0.2848 * _s,
    0.0722 - 0.0722 * _s,
    0,
    0,
    0.2126 - 0.2126 * _s,
    0.7152 - 0.7152 * _s,
    0.0722 + 0.9278 * _s,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    final Color wash = context.select<CurrentState, Color>(
      (s) => s.hillTones.last,
    );
    final BorderRadius r = BorderRadius.circular(radius);

    Widget panel = CustomPaint(
      painter: _OutsideShadowPainter(radius),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: _saturate,
            inner: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          ),
          child: CustomPaint(
            foregroundPainter: _GlassEdgePainter(radius),
            // Separate layer: a BoxDecoration with both color and gradient
            // paints only the gradient.
            child: ColoredBox(
              color: wash.withOpacity(0.22),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.16),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.1,
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.white.withOpacity(0),
                    ],
                    stops: const [0, 0.55],
                  ),
                ),
                child: childW,
              ),
            ),
          ),
        ),
      ),
    );

    if (onPressed != null) {
      panel = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onPressed, child: panel),
      );
    }
    return panel;
  }
}

/// Soft drop shadow with the panel's own shape cut out, so none of it sits
/// beneath the translucent glass.
class _OutsideShadowPainter extends CustomPainter {
  final double radius;
  const _OutsideShadowPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final RRect panel = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(panel.outerRect.inflate(120))
        ..addRRect(panel),
    );
    canvas.drawRRect(
      panel.shift(const Offset(0, 24)),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 23),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OutsideShadowPainter old) => old.radius != radius;
}

/// 1px edge, bright at the top-left fading to faint at the bottom-right.
class _GlassEdgePainter extends CustomPainter {
  final double radius;
  const _GlassEdgePainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius - 0.5)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.55),
            Colors.white.withOpacity(0.10),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassEdgePainter old) => old.radius != radius;
}
