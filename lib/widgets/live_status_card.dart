import 'dart:async';
import 'dart:convert';

import 'package:awesome_portfolio/consts/data.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'pulse_dot.dart';
import 'social_row.dart';
import 'type_scale.dart';

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
      final raw = await rootBundle.loadString('assets/data/contributions.json');
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
    final Color accent = context.select<CurrentState, Color>((s) => s.accent);
    final Color dim = Colors.white.withOpacity(0.62);

    return LayoutBuilder(
      builder: (context, box) {
        // Narrow panels (compact breakpoint) get a smaller name and social row
        // so nothing clips.
        final bool compact = box.maxWidth < 240;
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PulseDot(color: accent),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      statusLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: monoStyle(dim, size: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                developerName,
                style: displayStyle(Colors.white, size: compact ? 24 : 27),
              ),
              const SizedBox(height: 4),
              Text(
                developerTagline,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: compact ? 11.5 : 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "$_time  $localTimezoneLabel",
                style: monoStyle(
                  Colors.white,
                  size: 13,
                  weight: FontWeight.w500,
                ),
              ),
              // Contribution graph — real data only; absent rather than invented.
              if (_contrib != null) ...[
                const SizedBox(height: 18),
                Text(
                  // Rolling 12 months to today. "last year" read as 2025.
                  "${_contrib!.totalLabel} in the past 12 months",
                  style: monoStyle(dim, size: 9.5),
                ),
                const SizedBox(height: 7),
                _ContributionGrid(grid: _contrib!.levels, accent: accent),
              ],
              const Spacer(),
              SocialRow(
                iconColor: Colors.white,
                fill: Colors.white.withOpacity(0.10),
                border: Colors.white.withOpacity(0.18),
                size: compact ? 28 : 32,
                gap: compact ? 6 : 8,
                alignment: MainAxisAlignment.start,
              ),
            ],
          ),
        );
      },
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
    final entries = (json['contributions'] as List)
        .cast<Map<String, dynamic>>();
    if (entries.isEmpty) return null;

    final byDate = {
      for (final e in entries) e['date'] as String: (e['level'] as num).toInt(),
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

  /// `1327` reads as a part number at 9.5px; `1,327` reads as a count.
  String get totalLabel => total.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
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
