#!/usr/bin/env python3
"""Build web/mascot/strobi.avatar.json from the Studio export.

The Studio export (tool/mascot/strobi.studio.json) supplies Strobi's body:
shape, size and eye colour. This script replaces its expressions and
animations with ones made for the site:

  * every mood gets its own face, rhythm and body colour (the mood's accent
    from lib/consts/moods.dart), so a mood change is visible at 100px;
  * every reaction (excited, laughing, drowsy, sleeping, waking) and the
    8 cursor "looks" exist once per mood, because an expression without a
    colour falls back to the base colour and Strobi would flash blue.

Animation keys are "<mood>-<name>", e.g. "storm-excited"; look expressions
are "<mood>-look-<direction>". mascot_director.dart builds the same keys.

Run from the repo root after changing anything here or in the Studio:

    python tool/mascot/build_strobi.py

It validates the result against the renderer's own published schema
(pinned to the version web/mascot/mascot.js loads) before writing.
"""

import json
import sys
import urllib.request

SOURCE = "tool/mascot/strobi.studio.json"
OUT = "web/mascot/strobi.avatar.json"
SCHEMA_URL = ("https://cdn.jsdelivr.net/npm/@bible-strong/avatar-core@0.1.0"
              "/dist/avatarDefinition.schema.json")

# Each mood's accent, kept in step with MoodSpec.accent in lib/consts/moods.dart.
# Lowercase: the schema rejects uppercase hex.
MOODS = {
    "dawn": "#ffc371",
    "midday": "#4da3ff",
    "dusk": "#ff6b9d",
    "storm": "#7aa0c4",
    "night": "#8e7bff",
    "aurora": "#00e0c6",
}

# Units are the Studio's: the body is 240 across. Head angles are degrees:
# x = pitch (+ up), y = yaw, z = roll.


def eye(w, h, x=0, y=0, angle=0):
    return {"width": w, "height": h, "x": x, "y": y, "angle": angle}


def face(left, right=None, spacing=54, head=(0, 0, 0), eyes="none",
         body="none"):
    """`right` defaults to a mirror of `left` (same shape, opposite tilt)."""
    if right is None:
        right = dict(left, angle=-left["angle"], x=-left["x"])
    return {
        "head": dict(zip("xyz", head)),
        "eyes": {"left": left, "right": right, "spacing": spacing},
        "perspective": 1,
        "motion": {"eyes": eyes, "body": body},
    }


def step(expression, hold, transition_ms, transition):
    return {"expression": expression, "holdMs": hold,
            "transitionMs": transition_ms, "transition": transition}


def blink(on=True, delay=1500, lo=2600, hi=5200, dur=180):
    return {"enabled": on, "initialDelayMs": delay, "minIntervalMs": lo,
            "maxIntervalMs": hi, "durationMs": dur}


def anim(steps, mode="loop", blink_cfg=None, label=""):
    return {"playbackMode": mode, "steps": steps,
            "blink": blink_cfg or blink(),
            "metadata": {"label": label, "description": label,
                         "group": "Portfolio"}}


# ---------------------------------------------------------------------------
# Faces. Differences are deliberately large: they have to read at ~100px.
# ---------------------------------------------------------------------------

# The mood's own loop: [(face name, face, hold, transitionMs, transition)].
MOOD_LOOPS = {
    # Waking up slowly: lidded → opening → bright, and back (pingPong).
    "dawn": ("pingPong", blink(lo=3000, hi=6000, dur=260), [
        ("lidded", face(eye(36, 20, y=8), head=(-6, 6, -4), body="slowDrift"),
         1600, 900, "smooth"),
        ("opening", face(eye(32, 42, y=3), head=(2, -8, 3), body="slowDrift"),
         1400, 900, "smooth"),
        ("bright", face(eye(30, 58), head=(6, 10, 0)), 1600, 900, "smooth"),
    ]),
    # Bright, bouncy, glancing around, with happy squints in between.
    "midday": ("loop", blink(), [
        ("round-a", face(eye(42, 64), head=(6, 16, 0), eyes="microSaccades"),
         900, 420, "spring"),
        ("joy", face(eye(46, 22, y=-4), head=(10, 0, 7)), 700, 320, "spring"),
        ("round-b", face(eye(42, 64), head=(4, -16, 0), eyes="microSaccades"),
         900, 420, "spring"),
        ("joy-b", face(eye(46, 22, y=-4), head=(10, 0, -7)), 700, 320,
         "spring"),
    ]),
    # Heavy-lidded and slow.
    "dusk": ("loop", blink(lo=3500, hi=6500, dur=480), [
        ("heavy", face(eye(40, 14, y=9), head=(-10, -6, -6),
                       body="slowDrift"), 2200, 1100, "smooth"),
        ("soft", face(eye(36, 28, y=4), head=(-6, 8, 5), body="slowDrift"),
         1800, 1100, "smooth"),
    ]),
    # Tiny, wide-set, trembling eyes, darting side to side.
    "storm": ("loop", blink(lo=1800, hi=3200, dur=120), [
        ("tiny-a", face(eye(16, 24), spacing=74, head=(8, -18, -4),
                        eyes="shake"), 520, 160, "snappy"),
        ("tiny-b", face(eye(18, 28), spacing=74, head=(6, 18, 4),
                        eyes="shake"), 520, 160, "snappy"),
    ]),
    # Asleep: closed lines, rocking slowly.
    "night": ("loop", blink(on=False), [
        ("asleep-a", face(eye(44, 7, y=10), head=(-12, 0, 9),
                          body="slowDrift"), 3000, 1600, "smooth"),
        ("asleep-b", face(eye(44, 9, y=10), head=(-14, 0, -7),
                          body="slowDrift"), 3000, 1600, "smooth"),
    ]),
    # Curious: one big eye, one small, head tilting, swapping sides.
    "aurora": ("loop", blink(lo=2400, hi=4400), [
        ("odd-a", face(eye(46, 72), right=eye(24, 38), head=(4, 12, 14),
                       eyes="microSaccades"), 1100, 500, "spring"),
        ("odd-b", face(eye(26, 40), right=eye(44, 70), head=(2, -12, -12),
                       eyes="microSaccades"), 1100, 500, "spring"),
    ]),
}

# The face each mood looks at you with, and wakes up into.
AWAKE_EYE = {
    "dawn": eye(30, 58),
    "midday": eye(42, 64),
    "dusk": eye(36, 28, y=4),
    "storm": eye(18, 28),
    "night": eye(36, 18, y=6),  # peeks with sleepy eyes
    "aurora": eye(40, 62),
}

# Shared by every mood (recoloured per mood).
REACTION_FACES = {
    "excited-a": face(eye(50, 80), spacing=58, head=(12, 14, 6),
                      eyes="microSaccades"),
    "excited-b": face(eye(50, 80), spacing=58, head=(12, -14, -6),
                      eyes="microSaccades"),
    # ^ ^ — flat, tilted squints, body shaking with laughter.
    "laugh-a": face(eye(48, 14, x=-2, y=-2, angle=-16), head=(14, 0, 10),
                    body="shake"),
    "laugh-b": face(eye(48, 14, x=-2, y=-2, angle=-16), head=(14, 0, -10),
                    body="shake"),
    "sleepy": face(eye(40, 14, y=8), head=(-8, 0, -5), body="slowDrift"),
    "closed": face(eye(44, 7, y=10), head=(-12, 0, 8), body="slowDrift"),
    "closed-b": face(eye(44, 8, y=10), head=(-14, 0, -7), body="slowDrift"),
}

# Cursor looks: (pitch, yaw, eye x shift, eye y shift). If Strobi looks *away*
# from the cursor, flip YAW_SIGN (the Studio's yaw direction is unverified).
YAW_SIGN = 1
LOOKS = {
    "up-left": (14, -24, -6, -5),
    "up": (16, 0, 0, -6),
    "up-right": (14, 24, 6, -5),
    "left": (0, -28, -7, 0),
    "right": (0, 28, 7, 0),
    "down-left": (-12, -24, -6, 5),
    "down": (-14, 0, 0, 6),
    "down-right": (-12, 24, 6, 5),
}


def coloured(f, colour):
    return dict(f, colors={"body": colour})


def build(studio):
    out = {k: studio[k] for k in ("schema", "schemaVersion", "body")}
    out["name"] = "Strobi"
    out["colors"] = {"body": MOODS["midday"], "eyes": studio["colors"]["eyes"]}

    expressions = {"neutral": studio["expressions"]["neutral"]}
    animations = {}

    for mood, colour in MOODS.items():
        def add(name, f):
            key = f"{mood}-{name}"
            expressions[key] = coloured(f, colour)
            return key

        # The mood's own loop.
        mode, blink_cfg, faces = MOOD_LOOPS[mood]
        steps = [step(add(n, f), hold, t_ms, t)
                 for n, f, hold, t_ms, t in faces]
        animations[f"{mood}-mood"] = anim(steps, mode, blink_cfg,
                                          f"{mood} mood")

        for name, f in REACTION_FACES.items():
            add(name, f)

        awake = AWAKE_EYE[mood]
        add("awake", face(awake, head=(4, 0, 0)))
        for direction, (pitch, yaw, ex, ey) in LOOKS.items():
            add(f"look-{direction}",
                face(eye(awake["width"], awake["height"], ex, awake["y"] + ey),
                     right=eye(awake["width"], awake["height"], ex,
                               awake["y"] + ey),
                     head=(pitch, yaw * YAW_SIGN, 0)))

        k = lambda n: f"{mood}-{n}"  # noqa: E731
        animations[k("excited")] = anim([
            step(k("excited-a"), 450, 260, "spring"),
            step(k("excited-b"), 450, 260, "spring"),
        ], label=f"{mood} excited")
        animations[k("laughing")] = anim([
            step(k("laugh-a"), 280, 140, "snappy"),
            step(k("laugh-b"), 280, 140, "snappy"),
        ], blink_cfg=blink(on=False), label=f"{mood} laughing")
        animations[k("drowsy")] = anim([
            step(k("sleepy"), 2200, 1000, "smooth"),
            step(k("closed"), 1600, 1000, "smooth"),
        ], blink_cfg=blink(lo=3000, hi=5000, dur=520), label=f"{mood} drowsy")
        animations[k("sleeping")] = anim([
            step(k("closed"), 3200, 1600, "smooth"),
            step(k("closed-b"), 3200, 1600, "smooth"),
        ], blink_cfg=blink(on=False), label=f"{mood} sleeping")
        # Eyes shut, then open into the face it looks at you with. "once":
        # the director moves on after it.
        animations[k("waking")] = anim([
            step(k("closed"), 250, 0, "smooth"),
            step(k("awake"), 700, 700, "spring"),
        ], mode="once", blink_cfg=blink(on=False), label=f"{mood} waking")

    out["expressions"] = expressions
    out["expressionOrder"] = list(expressions)
    out["animations"] = animations
    out["animationOrder"] = list(animations)
    return out


def validate(definition):
    try:
        import jsonschema
    except ImportError:
        print("jsonschema not installed; skipping validation "
              "(pip install jsonschema)", file=sys.stderr)
        return True
    with urllib.request.urlopen(SCHEMA_URL, timeout=30) as r:
        schema = json.load(r)
    errors = sorted(jsonschema.Draft202012Validator(schema)
                    .iter_errors(definition), key=lambda e: list(e.path))
    for e in errors[:10]:
        print(f"  {'/'.join(map(str, e.path))}: {e.message}", file=sys.stderr)
    return not errors


def main():
    with open(SOURCE, encoding="utf-8") as f:
        definition = build(json.load(f))
    if not validate(definition):
        print("invalid definition; not written", file=sys.stderr)
        return 1
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(definition, f, separators=(",", ":"))
    print(f"{len(definition['expressions'])} expressions, "
          f"{len(definition['animations'])} animations -> {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
