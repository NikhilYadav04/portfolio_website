import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/miniProjects/playground/agent_run_view.dart';
import 'package:awesome_portfolio/screen/miniProjects/playground/in_app_mock.dart';
import 'package:awesome_portfolio/screen/miniProjects/playground/playground_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Phase 3 — HERO app.
///
/// Three tabs, one per discipline (workflow / RAG / in-app), each replaying a
/// scripted agent loop. This is the portfolio's proof-of-skill: a visitor
/// watches the actual shape of the agents this developer builds.
class AgentPlayground extends StatefulWidget {
  const AgentPlayground({super.key});

  @override
  State<AgentPlayground> createState() => _AgentPlaygroundState();
}

class _AgentPlaygroundState extends State<AgentPlayground> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;
    final demo = playgroundDemos[_tab];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E16),
      body: Column(
        children: [
          // Tab selector.
          Container(
            color: const Color(0xFF05070D),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: List.generate(playgroundDemos.length, (i) {
                final bool selected = i == _tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: selected
                            ? accent.withOpacity(0.18)
                            : Colors.white.withOpacity(0.04),
                        border: Border.all(
                          color: selected ? accent : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _tabLabel(i),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Active demo run.
          Expanded(
            child: AgentRunView(
              key: ValueKey(_tab),
              demo: demo,
              // Only the in-app tab shows the phone-in-phone mock.
              header: _tab == 2
                  ? (activeStep) => InAppMock(
                        activeStep: activeStep,
                        accent: accent,
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _tabLabel(int i) {
    switch (i) {
      case 0:
        return "Workflow";
      case 1:
        return "RAG";
      default:
        return "In-App";
    }
  }
}
