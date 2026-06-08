import 'dart:async';

import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../consts/data.dart';

/// Phase 3 — About rebuilt as a RAG-style assistant chat.
///
/// Scripted Q&A reveals one exchange at a time: the question appears, the
/// assistant "answers" with a typewriter effect, then source chips drop in.
/// It's the bio *and* a live demo of the grounded assistants the dev builds.
class AboutMe extends StatefulWidget {
  const AboutMe({super.key});

  @override
  State<AboutMe> createState() => _AboutMeState();
}

class _AboutMeState extends State<AboutMe> {
  int _shown = 0; // how many exchanges are revealed
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _revealNext();
  }

  void _revealNext() {
    if (_shown >= aboutChat.length) return;
    // Pace exchanges; each answer types itself, then the next begins.
    _timer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _shown++);
      // schedule the following exchange after this one's type-out finishes
      _timer = Timer(const Duration(milliseconds: 2600), _revealNext);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E16),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.2),
                  border: Border.all(color: accent),
                ),
                child: Icon(Icons.smart_toy_outlined, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Text(
                "ask-me  ·  grounded on my data",
                style: GoogleFonts.firaCode(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...List.generate(_shown, (i) {
            return _Exchange(
              qa: aboutChat[i],
              accent: accent,
              // Only the latest answer types out; earlier ones show in full.
              animate: i == _shown - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _Exchange extends StatelessWidget {
  final AboutQA qa;
  final Color accent;
  final bool animate;
  const _Exchange(
      {required this.qa, required this.accent, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User question — right aligned bubble.
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10, left: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Text(
              qa.question,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
        // Assistant answer — left aligned, typewriter.
        Container(
          margin: const EdgeInsets.only(bottom: 8, right: 30),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: animate
              ? _Typewriter(text: qa.answer)
              : Text(
                  qa.answer,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.4),
                ),
        ),
        // Source chips.
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 18),
          child: Wrap(
            spacing: 6,
            children: qa.sources.asMap().entries.map((e) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withOpacity(0.5)),
                ),
                child: Text(
                  "[${e.key + 1}] ${e.value}",
                  style: GoogleFonts.firaCode(
                    color: accent,
                    fontSize: 9.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Reveals [text] character-by-character.
class _Typewriter extends StatefulWidget {
  final String text;
  const _Typewriter({required this.text});

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  int _chars = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 18), (t) {
      if (!mounted) return;
      if (_chars >= widget.text.length) {
        t.cancel();
        return;
      }
      setState(() => _chars++);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _chars),
      style: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.9),
        fontSize: 13,
        height: 1.4,
      ),
    );
  }
}
