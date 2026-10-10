import 'package:awesome_portfolio/consts/moods.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/widgets/contact_panel.dart';
import 'package:awesome_portfolio/widgets/device_switch.dart';
import 'package:awesome_portfolio/widgets/highlights.dart';
import 'package:awesome_portfolio/widgets/live_status_card.dart';
import 'package:awesome_portfolio/widgets/mood_picker.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../widgets/frosted_container.dart';
import '../../widgets/mascot/mascot.dart';
import '../../widgets/mascot/mascot_director.dart';
import '../../widgets/mascot/mascot_hint.dart';
import '../../widgets/mood_hills.dart';
import '../../widgets/parallax.dart';
import '../../widgets/rain_cloud.dart';
import 'phone_screen_wrapper.dart';

/// The desktop scene: sky, hills and rain behind; the phone in the middle;
/// two columns of glass panels either side; the device switch below.
///
/// Sizes come from the content and the screen, not from multiplying a 1440px
/// design by width/height ratios — that scaling clipped text at 1024px and
/// left panels mostly empty at 1920px.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  /// Below this the side panels no longer fit beside the phone, and the site
  /// switches to the full-screen app.
  static const double _panelsMinWidth = 900;

  /// Below this the panels switch to their compact width and type.
  static const double _compactBelow = 1280;

  static const double _mascotSize = 104;

  @override
  Widget build(BuildContext context) {
    final CurrentState currentState = Provider.of<CurrentState>(
      context,
      listen: false,
    );
    final Size size = MediaQuery.sizeOf(context);

    // Phone-sized screen: the app itself, full-screen. A phone drawn inside a
    // phone wastes the screen, and the side panels have no room — their
    // content moves to the gear's settings sheet.
    if (size.width < _panelsMinWidth)
      return const _ActivityListener(child: _MobileApp());

    final bool compact = size.width < _compactBelow;
    final double phoneHeight = size.height - 100;

    // Panel geometry follows the phone so the scene stays balanced from a
    // 720px laptop to a 1080px monitor.
    final double panelWidth = compact
        ? 220
        : (size.width * 0.17).clamp(220.0, 300.0);
    final double upperHeight = (phoneHeight * 0.46).clamp(330.0, 430.0);
    // Floor fits the contact panel: status, two buttons and the address.
    final double lowerHeight = (phoneHeight * 0.24).clamp(196.0, 220.0);

    return _ActivityListener(
      child: Scaffold(
        body: MouseRegion(
          onHover: (event) => currentState.updatePointer(event.position, size),
          onExit: (_) => currentState.resetPointer(),
          child: Stack(
            children: [
              // Sky gradient — animated so mood changes cross-fade.
              Selector<CurrentState, Gradient>(
                selector: (context, provider) => provider.bgGradient,
                builder: (context, gradient, __) => AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
              if (size.height > 600)
                Selector<CurrentState, RainIntensity>(
                  selector: (context, p) => p.rain,
                  builder: (context, intensity, __) =>
                      Rain(oposite: false, top: 300, intensity: intensity),
                ),
              // Hills drift on the shallowest parallax layer (feel farthest
              // away) and take their colours from the active mood.
              ParallaxLayer(
                depth: 3,
                child: RepaintBoundary(child: MoodHills(height: size.height)),
              ),
              if (size.height > 600)
                Selector<CurrentState, RainIntensity>(
                  selector: (context, p) => p.rain,
                  builder: (context, intensity, __) =>
                      Rain(oposite: true, top: 50, intensity: intensity),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PanelColumn(
                        side: _Side.left,
                        width: panelWidth,
                        upperHeight: upperHeight,
                        lowerHeight: lowerHeight,
                        upper: const LiveStatusCard(),
                        lower: const ContactPanel(),
                      ),
                      const SizedBox(width: 28),
                      // The phone — mid parallax layer, tilting toward the
                      // cursor.
                      ParallaxLayer(
                        depth: 4,
                        child: CursorTilt(
                          // RepaintBoundary: the tilt moves the phone every
                          // frame; its contents shouldn't repaint with it.
                          child: RepaintBoundary(
                            child: SizedBox(
                              height: phoneHeight,
                              child: Selector<CurrentState, DeviceInfo>(
                                selector: (_, s) => s.currentDevice,
                                builder: (context, device, __) => DeviceFrame(
                                  device: device,
                                  screen: Consumer<CurrentState>(
                                    builder: (context, s, __) => Container(
                                      decoration: BoxDecoration(
                                        gradient: s.bgGradient,
                                      ),
                                      child: ScreenWrapper(
                                        childG: s.currentScreen,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                      _PanelColumn(
                        side: _Side.right,
                        width: panelWidth,
                        upperHeight: upperHeight,
                        lowerHeight: lowerHeight,
                        upper: const MoodPicker(),
                        lower: const Highlights(),
                        // Strobi sits on the mood panel: it acts out the mood.
                        perch: const Mascot(size: _mascotSize),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const DeviceSwitch(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Side { left, right }

/// Two stacked glass panels on one side of the phone, tilted gently toward
/// it. Normal perspective (0.0012) and ~7° of rotation give depth while
/// keeping text straight enough to read — the old 0.01 perspective skewed it.
class _PanelColumn extends StatelessWidget {
  final _Side side;
  final double width;
  final double upperHeight;
  final double lowerHeight;
  final Widget upper;
  final Widget lower;

  /// Sits on the upper panel's top-right edge, half above it: outside the
  /// glass, so the blur and the fade-in (which an HTML element ignores)
  /// don't apply to it.
  final Widget? perch;

  const _PanelColumn({
    required this.side,
    required this.width,
    required this.upperHeight,
    required this.lowerHeight,
    required this.upper,
    required this.lower,
    this.perch,
  });

  @override
  Widget build(BuildContext context) {
    final double angle = side == _Side.left ? -0.12 : 0.12;
    Widget tilt(Widget child) => Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(angle),
      child: child,
    );

    return ParallaxLayer(
      depth: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tilt(
            Stack(
              clipBehavior: Clip.none,
              children: [
                FrostedWidget(
                  width: width,
                  height: upperHeight,
                  childW: RepaintBoundary(
                    // Clears Strobi's lower half, which overlaps the glass.
                    child: perch == null
                        ? upper
                        : Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: upper,
                          ),
                  ).animate().fadeIn(delay: .8.seconds, duration: .7.seconds),
                ),
                if (perch != null)
                  Positioned(
                    top: -HomePage._mascotSize / 2,
                    left: 0,
                    right: 0,
                    child: Center(child: perch!),
                  ),
                if (perch != null)
                  // First-visit hint, to Strobi's right: open sky on that
                  // side, where on the left it would cover the phone.
                  Positioned(
                    top: -HomePage._mascotSize / 2 + 18,
                    left: width / 2 + HomePage._mascotSize / 2 + 6,
                    child: const MascotHint(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          tilt(
            FrostedWidget(
              width: width,
              height: lowerHeight,
              childW: RepaintBoundary(
                child: lower,
              ).animate().fadeIn(delay: 1.seconds, duration: .7.seconds),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reports mouse, tap and scroll anywhere on the page to the mascot, so it can
/// doze when the visitor goes quiet and wake when they're back. Translucent:
/// it only listens, it never takes events from the widgets below.
class _ActivityListener extends StatelessWidget {
  final Widget child;
  const _ActivityListener({required this.child});

  @override
  Widget build(BuildContext context) {
    final director = MascotDirector.instance;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => director.activity(),
      // Hover and drag also steer where Strobi looks.
      onPointerHover: (e) => director.pointer(e.position),
      onPointerMove: (e) => director.pointer(e.position),
      onPointerSignal: (_) => director.activity(),
      child: child,
    );
  }
}

/// Below 900px: the phone's screen at full size, on the mood sky, with no
/// device frame, panels or device switch.
class _MobileApp extends StatelessWidget {
  const _MobileApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CurrentState>(
        builder: (context, s, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(gradient: s.bgGradient),
          child: ScreenWrapper(childG: s.currentScreen),
        ),
      ),
    );
  }
}
