import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's three type roles, shared by the phone home carousel and the detail
/// screens so the two can't drift apart.
///
/// * **Sora** — titles only, used with restraint.
/// * **Inter** — names and prose.
/// * **Fira Code** — eyebrows, dates, scores, labels: anything that reads as
///   instrument data rather than copy. It is the same face the glass panels
///   outside the phone speak in, which is what ties the whole world together.

/// Card and page titles.
TextStyle displayStyle(Color ink, {double size = 25}) => GoogleFonts.sora(
      color: ink,
      fontWeight: FontWeight.w700,
      fontSize: size,
      letterSpacing: -0.5,
    );

/// Eyebrows, dates, scores, footer labels, section labels.
TextStyle monoStyle(Color color,
        {double size = 9.5, FontWeight weight = FontWeight.w400}) =>
    GoogleFonts.firaCode(
      color: color,
      fontSize: size,
      letterSpacing: 0.4,
      fontWeight: weight,
    );

/// The bold line of a list row.
TextStyle rowTitleStyle(Color color, {double size = 13.5}) => GoogleFonts.inter(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w700,
    );

/// The muted second line of a list row.
TextStyle rowSubStyle(Color color, {double size = 11}) =>
    GoogleFonts.inter(color: color, fontSize: size);

/// Running prose inside a detail card.
TextStyle bodyStyle(Color color) => GoogleFonts.inter(
      color: color,
      fontSize: 13,
      height: 1.55,
    );
