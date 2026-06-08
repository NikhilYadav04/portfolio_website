import 'package:awesome_portfolio/screen/boot/boot_screen.dart';
import 'package:awesome_portfolio/screen/homescreen/phone_home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/current_state.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget childG;
  const ScreenWrapper({super.key, required this.childG});

  @override
  Widget build(BuildContext context) {
    CurrentState instance = Provider.of<CurrentState>(context, listen: false);

    // Phase 2 — until the OS finishes booting, the phone shows the boot
    // sequence instead of any screen content.
    return Consumer<CurrentState>(builder: (context, state, __) {
      if (!state.booted) return const BootScreen();

      return Column(
        children: [
          // The home screen supplies its own top bar (the design's "PORTFOLIO"
          // header); inside an app, that app supplies its own close-header.
          if (!instance.isMainScreen)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              padding: const EdgeInsets.only(top: 30),
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      instance.title ?? "",
                      style: GoogleFonts.inter(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        instance.changePhoneScreen(
                          const PhoneHomeScreen(),
                          true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            // Phase 2 — native-feel open: each screen scales + fades up from
            // the icon when swapped in, and reverses on close.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.88, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(state.isMainScreen
                    ? 'home'
                    : (instance.title ?? 'app')),
                child: childG,
              ),
            ),
          ),
        ],
      );
    });
  }
}
