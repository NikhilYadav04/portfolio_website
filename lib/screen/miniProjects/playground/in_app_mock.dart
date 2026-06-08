import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Phase 3 — the mini "phone inside the phone" for the In-App Agent tab.
///
/// A tiny fake booking screen. As the agent run advances, the matching control
/// highlights — slot at step 1, notes at step 2, confirm at step 3 — so the
/// visitor literally watches the agent drive a Flutter UI.
class InAppMock extends StatelessWidget {
  /// Index of the active agent step (from the run view).
  final int activeStep;
  final Color accent;
  const InAppMock({super.key, required this.activeStep, required this.accent});

  bool get _slotActive => activeStep >= 1;
  bool get _notesActive => activeStep >= 2;
  bool get _confirmActive => activeStep >= 3;
  bool get _booked => activeStep >= 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Appointments",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _slot("8:00", false),
              _slot("9:00", _slotActive),
              _slot("10:00", false),
            ],
          ),
          const SizedBox(height: 10),
          // Notes field.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _notesActive ? accent : Colors.black12,
                width: _notesActive ? 1.5 : 1,
              ),
            ),
            child: Text(
              _notesActive ? "Follow-up visit" : "Add notes…",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _notesActive ? Colors.black87 : Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Confirm button.
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _booked
                  ? Colors.green
                  : (_confirmActive ? accent : Colors.black12),
              boxShadow: _confirmActive && !_booked
                  ? [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 10)]
                  : null,
            ),
            child: Center(
              child: Text(
                _booked ? "Booked ✓" : "Confirm",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: (_confirmActive || _booked)
                      ? Colors.white
                      : Colors.black45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(String label, bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: active ? accent.withOpacity(0.15) : Colors.black.withOpacity(0.04),
          border: Border.all(
            color: active ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? Colors.black87 : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
