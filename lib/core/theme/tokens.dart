import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SPACING SCALE
// Single source of truth — no magic numbers in screens.
// xs=4  s=8  m=12  l=16  xl=20  xxl=24  xxxl=32  xxxxl=40
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppSpace {
  static const double xs = 4;
  static const double xxs = 6;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;

  /// Standard screen-edge padding (used for full-bleed pages).
  static const EdgeInsets screen = EdgeInsets.all(l);

  /// Scrolling list padding: tighter top, breathing room at bottom.
  static const EdgeInsets list = EdgeInsets.fromLTRB(l, m, l, xxl);

  /// Inside cards.
  static const EdgeInsets card = EdgeInsets.all(l);

  /// Gap between stacked cards.
  static const double cardGap = m;

  /// Gap between major content sections.
  static const double sectionGap = xxl;

  /// Gap between a SectionHeader and the first item below it.
  static const double sectionHeaderGap = xs;

  /// Standard search+chips row padding (used in services & member search).
  static const EdgeInsets filterRow = EdgeInsets.fromLTRB(l, m, l, s / 2);

  /// Floating bottom-nav outer margin.
  static const EdgeInsets navBar = EdgeInsets.fromLTRB(l, xs, l, m);

  /// Mini player card margin (sits above the bottom nav).
  static const EdgeInsets miniPlayer = EdgeInsets.fromLTRB(m, xxs, m, cardGap);
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY SYSTEM
// Sora for display/heading/title; Inter for body and below.
// Every TextStyle in the app derives from these tokens — no naked TextStyle.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppText {
  // ── Display tier (heroes, marketing) ──
  /// 24px / w800 — main hero title (splash wordmark, large plan price).
  static TextStyle get display => GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.white,
  );

  /// 20px / w800 — sub-hero title (plan name on register/book screens).
  static TextStyle get displaySm => GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.white,
  );

  // ── Heading tier (section identity, stat values) ──
  /// 16px / w700 — section headings, large stat numbers.
  static TextStyle get head => GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  // ── Title tier (card titles, list item titles) ──
  /// 14px / w700 — card and list item titles.
  static TextStyle get title => GoogleFonts.sora(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  // ── Body tier (content, descriptions) ──
  /// 13px / regular — body content, form help text.
  static TextStyle get body =>
      GoogleFonts.inter(fontSize: 13, color: AppColors.white, height: 1.45);

  // ── Small / Metadata tier ──
  /// 12px / regular — subtitles, metadata, secondary info.
  static TextStyle get small =>
      GoogleFonts.inter(fontSize: 12, color: AppColors.grey);

  /// 11px / regular — captions, dates, timestamps.
  static TextStyle get tiny =>
      GoogleFonts.inter(fontSize: 11, color: AppColors.faint);

  // ── Label / Eyebrow tier (uppercase labels) ──
  /// 10px / w700 / uppercase spacing — category eyebrows.
  static TextStyle get eyebrow => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.faint,
  );

  // ── Specialised ──
  /// 16px / w800 / yellow — price display (plan cards, booking).
  static TextStyle get price => GoogleFonts.sora(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.yellow,
  );

  /// 11px / w700 — compact badge-like label (e.g. FREE, POPULAR).
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  /// 12px / w700 — filter chip label (color set by selected state).
  static TextStyle get chip => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.grey,
  );

  /// 10px / w600 — bottom-nav labels (color set by selected state).
  static TextStyle get navLabel => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.faint,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENTS
// Centralised so a brand colour change updates the entire app.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppGradients {
  /// Yellow-dark warm gradient — used on featured/hero cards across the app.
  static const LinearGradient yellowCard = LinearGradient(
    colors: [Color(0xFF2A2304), Color(0xFF1A1A20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold gradient — app logo icon, initial avatar.
  static const LinearGradient logo = LinearGradient(
    colors: [Color(0xFFFFD54D), Color(0xFFFFC400), Color(0xFFE0A800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Two-stop avatar gradient (no middle stop needed).
  static const LinearGradient avatar = LinearGradient(
    colors: [Color(0xFFFFD54D), Color(0xFFE0A800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Radial glow for splash screen background.
  static const RadialGradient splashBg = RadialGradient(
    center: Alignment(0, -0.4),
    radius: 1.1,
    colors: [Color(0x33262600), AppColors.black],
  );

  /// Subtle radial warm glow for the login background.
  static const RadialGradient loginBg = RadialGradient(
    center: Alignment(0.6, -0.6),
    radius: 1.2,
    colors: [Color(0x40382600), AppColors.black],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SIZES
// Centralised interactive-element sizes so every screen matches.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppSizes {
  /// Full-width primary CTA button height.
  static const double btnPrimary = 56;

  /// Paired secondary button height (e.g. Deny / Approve row).
  static const double btnSecondary = 48;

  /// Height of horizontal filter chip rows.
  static const double chipRowHeight = 40;

  /// Persistent mini music player bar height (approx).
  static const double miniPlayerHeight = 64;

  // ── Media controls (mini player, full sheet, track rows) ──
  static const double mediaSkip = 40;
  static const double mediaMain = 38;
  static const double mediaMini = 30;
  static const double mediaTile = 36;

  // ── One-off artwork / brand geometry (named, single-use) ──
  /// Empty-state illustration tile.
  static const double artEmpty = 72;

  /// Full-player artwork.
  static const double playerArt = 240;

  /// Collection header artwork (playlist/album detail).
  static const double collectionArt = 84;

  /// Owner app-bar brand mark box.
  static const double brandMark = 30;

  /// Join-screen hero QR tile.
  static const double heroTile = 88;

  // ── Repeated component geometry (named, not magic) ──
  /// Google "G" badge on the sign-in button.
  static const double googleMark = 26;

  /// Join-flow step node circle.
  static const double stepDot = 26;

  /// Status dot inside StatusChip.
  static const double dot = 6;

  /// Music track artwork (list tiles).
  static const double trackArt = 56;

  /// Mini-player artwork thumb.
  static const double miniArt = 40;
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED CARD DECORATION
// Use instead of ad-hoc BoxDecorations.
// ─────────────────────────────────────────────────────────────────────────────
BoxDecoration appCardDeco({Color? border, List<Color>? gradient}) =>
    BoxDecoration(
      color: gradient == null ? AppColors.card : null,
      gradient: gradient != null
          ? LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderRadius: BorderRadius.circular(AppRadius.l),
      border: Border.all(color: border ?? AppColors.line),
    );

/// Yellow-card hero box decoration (profile, register, book, music header).
/// Same corner radius as regular cards — one roundness everywhere.
BoxDecoration get heroCardDeco => BoxDecoration(
  gradient: AppGradients.yellowCard,
  borderRadius: BorderRadius.circular(AppRadius.l),
  border: Border.all(color: AppColors.yellow.withValues(alpha: 0.4)),
);

// ─────────────────────────────────────────────────────────────────────────────
// ICON SIZES
// Standard icon sizes: list 22 · tile 44 · hero 52+.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppIcon {
  static const double list = 22;
  static const double tile = 44;
  static const double btn = 20;
  static const double hero = 56;

  /// Small inline icons (ticket stubs, compact buttons).
  static const double sm = 18;

  /// Inline meta icons (phone rows, links).
  static const double xs = 14;

  /// Large hero tiles (music header, section art).
  static const double lg = 48;

  /// Bottom-nav glyphs (optical size for glow treatment).
  static const double nav = 25;
}
