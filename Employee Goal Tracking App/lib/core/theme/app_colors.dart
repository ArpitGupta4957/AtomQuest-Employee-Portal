import 'package:flutter/material.dart';

/// AtomQuest Lumina Design System — Color Tokens
/// Inspired by Atomberg brand identity with soft minimalism approach.
class AppColors {
  AppColors._();

  // ── Brand Primary (Atomberg Yellow) ──
  static const Color primary = Color(0xFF7C5800);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFDB913);
  static const Color onPrimaryContainer = Color(0xFF6B4C00);
  static const Color inversePrimary = Color(0xFFFFBB16);
  static const Color primaryFixed = Color(0xFFFFDEA6);
  static const Color primaryFixedDim = Color(0xFFFFBB16);
  static const Color onPrimaryFixed = Color(0xFF271900);
  static const Color onPrimaryFixedVariant = Color(0xFF5E4200);

  // ── Secondary ──
  static const Color secondary = Color(0xFF555F6F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD6E0F3);
  static const Color onSecondaryContainer = Color(0xFF596373);
  static const Color secondaryFixed = Color(0xFFD9E3F6);
  static const Color secondaryFixedDim = Color(0xFFBDC7D9);
  static const Color onSecondaryFixed = Color(0xFF121C2A);
  static const Color onSecondaryFixedVariant = Color(0xFF3D4756);

  // ── Tertiary ──
  static const Color tertiary = Color(0xFF5C5F62);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFC3C5C9);
  static const Color onTertiaryContainer = Color(0xFF4F5255);
  static const Color tertiaryFixed = Color(0xFFE0E2E6);
  static const Color tertiaryFixedDim = Color(0xFFC4C7CA);
  static const Color onTertiaryFixed = Color(0xFF191C1F);
  static const Color onTertiaryFixedVariant = Color(0xFF44474A);

  // ── Surface System ──
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceDim = Color(0xFFD9DADB);
  static const Color surfaceBright = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF504533);
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F2);
  static const Color surfaceTint = Color(0xFF7C5800);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE1E3E4);

  // ── Outline ──
  static const Color outline = Color(0xFF837560);
  static const Color outlineVariant = Color(0xFFD5C4AC);

  // ── Background ──
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);

  // ── Error ──
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color errorDeep = Color(0xFFDC2626);

  // ── Semantic Colors ──
  static const Color successMuted = Color(0xFFD1FAE5);
  static const Color successDeep = Color(0xFF059669);
  static const Color warningMuted = Color(0xFFFFEDD5);
  static const Color warningDeep = Color(0xFFD97706);

  // ── Text ──
  static const Color textCharcoal = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  // ── Status Colors ──
  static const Color statusDraft = Color(0xFF9CA3AF);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF059669);
  static const Color statusOverdue = Color(0xFFDC2626);
  static const Color statusOnTrack = Color(0xFF10B981);
  static const Color statusAtRisk = Color(0xFFF59E0B);

  // ── Chart Colors ──
  static const List<Color> chartPalette = [
    Color(0xFFFDB913),
    Color(0xFF7C5800),
    Color(0xFF555F6F),
    Color(0xFF059669),
    Color(0xFFDC2626),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
  ];
}
