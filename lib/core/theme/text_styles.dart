import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  // ── DARK (CyberCortex) ──────────────────────────────────────────────────────
  static final TextStyle darkDisplayLarge = GoogleFonts.spaceGrotesk(
    color: CyberCortexColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold,
  );
  static final TextStyle darkDisplayMedium = GoogleFonts.spaceGrotesk(
    color: CyberCortexColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold,
  );
  static final TextStyle darkHeadlineLarge = GoogleFonts.spaceGrotesk(
    color: CyberCortexColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600,
  );
  static final TextStyle darkHeadlineMedium = GoogleFonts.spaceGrotesk(
    color: CyberCortexColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
  );
  static final TextStyle darkBodyLarge = GoogleFonts.manrope(
    color: CyberCortexColors.textPrimary, fontSize: 16,
  );
  static final TextStyle darkBodyMedium = GoogleFonts.manrope(
    color: CyberCortexColors.textPrimary, fontSize: 14,
  );
  static final TextStyle darkBodySmall = GoogleFonts.manrope(
    color: CyberCortexColors.textSecondary, fontSize: 12,
  );
  static final TextStyle darkLabelLarge = GoogleFonts.inter(
    color: CyberCortexColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500,
  );
  static final TextStyle darkLabelMedium = GoogleFonts.inter(
    color: CyberCortexColors.textSecondary, fontSize: 12,
  );
  static final TextStyle darkLabelSmall = GoogleFonts.inter(
    color: CyberCortexColors.textSecondary, fontSize: 10,
  );

  // ── LIGHT (Lumina) ──────────────────────────────────────────────────────────
  static final TextStyle lightDisplayLarge = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold,
  );
  static final TextStyle lightDisplayMedium = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold,
  );
  static final TextStyle lightHeadlineLarge = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600,
  );
  static final TextStyle lightHeadlineMedium = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
  );
  static final TextStyle lightBodyLarge = GoogleFonts.inter(
    color: LuminaColors.textPrimary, fontSize: 16,
  );
  static final TextStyle lightBodyMedium = GoogleFonts.inter(
    color: LuminaColors.textPrimary, fontSize: 14,
  );
  static final TextStyle lightBodySmall = GoogleFonts.inter(
    color: LuminaColors.textSecondary, fontSize: 12,
  );
  static final TextStyle lightLabelLarge = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500,
  );
  static final TextStyle lightLabelMedium = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textSecondary, fontSize: 12,
  );
  static final TextStyle lightLabelSmall = GoogleFonts.spaceGrotesk(
    color: LuminaColors.textSecondary, fontSize: 10,
  );
}
