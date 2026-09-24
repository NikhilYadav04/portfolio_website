#!/usr/bin/env python3
"""Write assets/data/contributions.json from GitHub's own contribution calendar.

Reads github.com/users/<user>/contributions — the same markup the profile page
renders — rather than a third-party mirror, which served a stale total for days
after private contributions were made public.

Output shape (unchanged, so live_status_card.dart keeps parsing it):

    {"total": {"lastYear": N},
     "contributions": [{"date": "YYYY-MM-DD", "count": N, "level": 0-4}, ...]}

Exits non-zero without touching the file if the fetch or parse fails, so CI
ships the committed snapshot instead of an empty graph.
"""

import json
import re
import sys
import urllib.request

USER = "NikhilYadav04"
OUT = "assets/data/contributions.json"

# <td ... data-date="2025-09-21" id="contribution-day-component-0-0" data-level="0" ...>
DAY = re.compile(
    r'data-date="(\d{4}-\d{2}-\d{2})"\s+id="([^"]+)"\s+data-level="(\d)"'
)
# <tool-tip ... for="contribution-day-component-0-0" ...>12 contributions on ...
TIP = re.compile(r'for="([^"]+)"[^>]*>(?:(\d+)|No)\s+contributions?\s+on')


def main() -> int:
    url = f"https://github.com/users/{USER}/contributions"
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "portfolio-contributions-sync",
            # GitHub caches this endpoint at the edge; the profile setting for
            # private contributions took days to show through without this.
            "Cache-Control": "no-cache",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        html = r.read().decode("utf-8")

    counts = {m.group(1): int(m.group(2) or 0) for m in TIP.finditer(html)}
    # The calendar is a table of weekday rows, so document order runs down the
    # weekdays, not through time. The Dart side reads the last entry as the
    # most recent day, so sort by date here.
    days = sorted(
        (
            {
                "date": date,
                "count": counts.get(day_id, 0),
                "level": int(level),
            }
            for date, day_id, level in DAY.findall(html)
        ),
        key=lambda d: d["date"],
    )

    # A calendar is a year of weeks; anything much shorter means the markup
    # changed and the regexes are picking up fragments.
    if len(days) < 300:
        print(f"only parsed {len(days)} days — markup may have changed",
              file=sys.stderr)
        return 1

    total = sum(d["count"] for d in days)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump({"total": {"lastYear": total}, "contributions": days}, f)
    print(f"{total} contributions across {len(days)} days -> {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
