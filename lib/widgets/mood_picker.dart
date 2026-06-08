import 'package:awesome_portfolio/consts/moods.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:custom_button_builder/custom_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 1 — the right-side glass panel's content.
///
/// Replaces the original six raw color buttons with a labeled "mood" picker.
/// Each swatch sets a full world state (sky + clouds + rain + accent) and the
/// active mood's name is shown beneath, so the control reads as intentional
/// rather than a palette.
class MoodPicker extends StatelessWidget {
  final double widthRatio;
  const MoodPicker({super.key, required this.widthRatio});

  @override
  Widget build(BuildContext context) {
    final CurrentState state =
        Provider.of<CurrentState>(context, listen: false);
    final double swatch = 46 * widthRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "MOOD",
            style: GoogleFonts.exo(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(moods.length, (index) {
              return Consumer<CurrentState>(builder: (context, s, __) {
                final bool selected = s.selectedMoodIndex == index;
                final spec = moods[index];
                return Container(
                  margin: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Accent ring + glow on the selected mood.
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: spec.accent.withOpacity(0.7),
                              blurRadius: 14,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: CustomButton(
                    pressed:
                        selected ? Pressed.pressed : Pressed.notPressed,
                    animate: true,
                    borderRadius: 100,
                    shadowColor: Colors.blueGrey[50],
                    isThreeD: true,
                    backgroundColor: spec.accent,
                    width: swatch,
                    height: swatch,
                    onPressed: () => state.setMoodByIndex(index),
                  ),
                );
              });
            }),
          ),
          const SizedBox(height: 16),
          // Active mood name — animated swap so it feels responsive.
          Consumer<CurrentState>(builder: (context, s, __) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                s.mood.label,
                key: ValueKey(s.currentMood),
                style: GoogleFonts.exo(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
