import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/consts/moods.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/providers/theme_provider.dart';
import 'package:awesome_portfolio/widgets/live_status_card.dart';
import 'package:awesome_portfolio/widgets/mood_picker.dart';
import 'package:awesome_portfolio/widgets/rotating_quote.dart';
import 'package:custom_button_builder/custom_button_builder.dart';
import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../widgets/frosted_container.dart';
import '../../widgets/parallax.dart';
import '../../widgets/rain_cloud.dart';
import 'phone_screen_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    CurrentState currentState =
        Provider.of<CurrentState>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    theme.size = MediaQuery.of(context).size;
    theme.widthRatio = theme.size.width / baseWidth;
    theme.heightRatio = theme.size.height / baseHeight;
    bool phone = false;
    if (size.width < 800) {
      phone = true;
    }

    return Scaffold(
      body: MouseRegion(
        onHover: (event) => currentState.updatePointer(event.position, size),
        onExit: (_) => currentState.resetPointer(),
        child: Stack(
        children: [
          // Sky gradient — animated so mood changes cross-fade instead of snap.
          Selector<CurrentState, Gradient>(
            selector: (context, provider) => provider.bgGradient,
            builder: (context, gradient, __) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(gradient: gradient),
              );
            },
          ),
          size.height > 600
              ? Selector<CurrentState, RainIntensity>(
                  selector: (context, p) => p.rain,
                  builder: (context, intensity, __) => Rain(
                    oposite: false,
                    top: 300,
                    intensity: intensity,
                  ),
                )
              : Container(),
          // Clouds drift on the shallowest parallax layer (feel farthest away).
          ParallaxLayer(
            depth: 5,
            child: Selector<CurrentState, String>(
              selector: (context, provider) => provider.selectedCloud,
              builder: (context, cloud, __) {
                return SvgPicture.asset(
                  cloud,
                  height: size.height,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          size.height > 600
              ? Selector<CurrentState, RainIntensity>(
                  selector: (context, p) => p.rain,
                  builder: (context, intensity, __) => Rain(
                    oposite: true,
                    top: 50,
                    intensity: intensity,
                  ),
                )
              : Container(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Left side frosted Containers — deepest layer so the
                  /// panels feel closest to the viewer (Phase 1 parallax).

                  phone
                      ? Container()
                      : ParallaxLayer(
                        depth: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.01)
                                ..rotateY(-0.06),
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: EdgeInsets.only(
                                    top: 0, bottom: 10 * theme.heightRatio),
                                child: FrostedWidget(
                                  // Phase 4 — live status card (status line,
                                  // ticking clock, contribution sparkline).
                                  childW: const LiveStatusCard()
                                      .animate()
                                      .fadeIn(
                                          delay: .8.seconds,
                                          duration: .7.seconds),
                                  height: 395 * theme.heightRatio,
                                  width: 247.5 * theme.widthRatio,
                                ),
                              ),
                            ),
                            Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.009999)
                                ..rotateY(-0.07),
                              alignment: Alignment.topCenter,
                              child: FrostedWidget(
                                onPressed: () {
                                  currentState.launchInBrowser(topMate);
                                },
                                childW: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/icons/topMate.png",
                                          width: 50 *
                                              theme.widthRatio *
                                              theme.heightRatio,
                                          height: 50 *
                                              theme.widthRatio *
                                              theme.heightRatio,
                                        ),
                                        SizedBox(
                                          height: 10 * theme.heightRatio,
                                        ),
                                        Flexible(
                                            child: AutoSizeText(
                                          "Let's connect!",
                                          style: GoogleFonts.exo(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 28 *
                                                theme.widthRatio *
                                                theme.heightRatio,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxFontSize: 28,
                                          minFontSize: 15,
                                        )),
                                      ],
                                    ).animate().fadeIn(
                                        delay: 1.seconds, duration: .7.seconds),
                                  ),
                                ),
                                height: 175.5 * theme.heightRatio,
                                width: 245 * theme.widthRatio,
                              ),
                            ),
                          ],
                        ),
                      ),

                  // main mobile screen — sits on a mid parallax layer and
                  // tilts in 3D toward the cursor (Phase 1).
                  ParallaxLayer(
                    depth: 7,
                    child: CursorTilt(
                      child: SizedBox(
                        height: size.height - 100,
                        child: Consumer<CurrentState>(
                          builder: (context, _, __) {
                            return DeviceFrame(
                              device: currentState.currentDevice,
                              screen: Container(
                                  decoration: BoxDecoration(
                                      gradient: currentState.bgGradient),
                                  child: ScreenWrapper(
                                      childG: currentState.currentScreen)),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  /// Right side frosted containers
                  phone
                      ? Container()
                      : ParallaxLayer(
                        depth: 10,
                        child: Column(
                          children: [
                            Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.01)
                                ..rotateY(0.06),
                              alignment: Alignment.bottomCenter,
                              child: FrostedWidget(
                                height: 395 * theme.heightRatio,
                                width: 247.5 * theme.widthRatio,
                                childW: MoodPicker(
                                  widthRatio: theme.widthRatio,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.00999)
                                ..rotateY(0.06),
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 0, bottom: 10),
                                child: FrostedWidget(
                                  // Phase 4 — rotating quote card.
                                  childW: const RotatingQuote()
                                      .animate()
                                      .fadeIn(
                                          delay: 1.seconds,
                                          duration: .7.seconds),
                                  height: 175.5 * theme.heightRatio,
                                  width: 245 * theme.widthRatio,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
              SizedBox(
                height: 10 * theme.heightRatio,
              ),

              /// bottom button for device selection
              Selector<CurrentState, DeviceInfo>(
                  selector: (context, p1) => p1.currentDevice,
                  builder: (context, _, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...List.generate(devices.length, (index) {
                          return CustomButton(
                            pressed: currentState.currentDevice ==
                                    devices[index].device
                                ? Pressed.pressed
                                : Pressed.notPressed,
                            animate: true,
                            borderRadius: 100,
                            isThreeD: true,
                            backgroundColor: Colors.black,
                            width: 37.5,
                            height: 37.5,
                            onPressed: () {
                              currentState.changeSelectedDevice(
                                devices[index].device,
                              );
                            },
                            child: Center(
                              child: Icon(
                                devices[index].icon,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          );
                        })
                      ],
                    );
                  })
            ],
          ),
        ],
      ),
      ),
    );
  }
}
