import 'dart:async';
import 'dart:convert';

import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'social_row.dart';

/// Phase 4 — the left glass panel's content.
///
/// Turns the static brand card into a "live" engineered surface: a status line,
/// a ticking local clock, and a GitHub-style contribution sparkline. Reads as
/// real, changing data rather than decoration.
class LiveStatusCard extends StatefulWidget {
  const LiveStatusCard({super.key});

  @override
  State<LiveStatusCard> createState() => _LiveStatusCardState();
}

class _LiveStatusCardState extends State<LiveStatusCard> {
  late final Timer _clock;
  DateTime _now = _ist();

  /// Real contribution data from `assets/data/contributions.json`, which CI
  /// refreshes on every deploy. Null until it loads, or if the file is missing
  /// or malformed — in which case the grid is hidden rather than faked.
  _Contributions? _contrib;

  /// Nikhil's wall-clock time. `DateTime.now()` alone is the *viewer's* local
  /// time, which the "IST" label would then misstate for anyone outside India.
  static DateTime _ist() =>
      DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = _ist());
    });
    _loadContributions();
  }

  Future<void> _loadContributions() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/contributions.json');
      final c = _Contributions.parse(raw);
      if (mounted && c != null) setState(() => _contrib = c);
    } catch (_) {
      // Missing or malformed: leave the grid hidden.
    }
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  String get _time {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(_now.hour)}:${two(_now.minute)}:${two(_now.second)}";
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = context.watch<CurrentState>().accent;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status line with a live pulse dot.
          Row(
            children: [
              _PulseDot(color: accent),
              const SizedBox(width: 8),
              Text(
                statusLine,
                style: GoogleFonts.firaCode(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            developerName,
            style: GoogleFonts.exo(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            developerTagline,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          // Live clock.
          Row(
            children: [
              Icon(Icons.schedule, size: 13, color: accent),
              const SizedBox(width: 6),
              Text(
                "$_time  ${localTimezoneLabel}",
                style: GoogleFonts.firaCode(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Contribution graph — real data only; absent rather than invented.
          if (_contrib != null) ...[
            const SizedBox(height: 16),
            Text(
              "${_contrib!.total} contributions · last year",
              style: GoogleFonts.firaCode(
                color: Colors.white.withOpacity(0.55),
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            _ContributionGrid(grid: _contrib!.levels, accent: accent),
          ],
          const SizedBox(height: 20),
          // Social links — sit just below the contribution grid.
          SocialRow(
            iconColor: Colors.white,
            fill: Colors.white.withOpacity(0.10),
            border: Colors.white.withOpacity(0.18),
            size: 34,
            gap: 10,
            alignment: MainAxisAlignment.start,
          ),
        ],
      ),
    );
  }
}

/// The last [weeks] weeks of GitHub contributions, laid out like GitHub's own
/// graph: one column per week starting Sunday, newest week on the right.
class _Contributions {
  static const int weeks = 10;

  /// Column-major, `weeks * 7` long. 0–4 is GitHub's level; -1 marks a day in
  /// the current week that hasn't happened yet.
  final List<int> levels;
  final int total;
  const _Contributions(this.levels, this.total);

  static _Contributions? parse(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final entries =
        (json['contributions'] as List).cast<Map<String, dynamic>>();
    if (entries.isEmpty) return null;

    final byDate = {
      for (final e in entries) e['date'] as String: (e['level'] as num).toInt()
    };
    // UTC throughout: stepping local dates by 24h slips a day across a
    // viewer's DST change, which would shift the whole graph.
    DateTime day(String iso) => DateTime.parse('${iso}T00:00:00Z');
    String iso(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final last = day(entries.last['date'] as String);
    final weekStart = last.subtract(Duration(days: last.weekday % 7));
    final start = weekStart.subtract(const Duration(days: 7 * (weeks - 1)));

    final levels = <int>[
      for (int i = 0; i < weeks * 7; i++)
        () {
          final d = start.add(Duration(days: i));
          return d.isAfter(last) ? -1 : (byDate[iso(d)] ?? 0);
        }(),
    ];
    final total = ((json['total'] as Map?)?['lastYear'] as num?)?.toInt() ?? 0;
    return _Contributions(levels, total);
  }
}

class _ContributionGrid extends StatelessWidget {
  final List<int> grid;
  final Color accent;
  const _ContributionGrid({required this.grid, required this.accent});

  @override
  Widget build(BuildContext context) {
    const int rows = 7;
    const int cols = _Contributions.weeks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: List.generate(cols, (c) {
              final level = grid[c * rows + r];
              return Container(
                margin: const EdgeInsets.only(right: 3),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  // -1: a day this week that hasn't happened — not drawn.
                  color: level < 0
                      ? Colors.transparent
                      : level == 0
                          ? Colors.white.withOpacity(0.08)
                          : accent.withOpacity(0.2 + level * 0.2),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3 + _c.value * 0.5),
                blurRadius: 3 + _c.value * 6,
                spreadRadius: _c.value * 1.5,
              ),
            ],
          ),
        );
      },
    );
  }
}
