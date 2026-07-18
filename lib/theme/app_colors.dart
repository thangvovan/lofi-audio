import 'package:flutter/material.dart';

/// Centralized design tokens (colors) for the Lofi Radio app.
/// Follows the "Synthwave Sanctuary" design system specifications.
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primary = Color(0xFFE94560);     // Radiant Neon Red (glowing highlights)
  static const Color secondary = Color(0xFF533483);   // Soft Deep Violet (skies & deep gradients)
  static const Color tertiary = Color(0xFF0F3460);    // Deep Teal (dark support highlights)

  // Dark Space Neutrals
  static const Color background = Color(0xFF0D0D1A);  // Space Charcoal (main backdrop)
  static const Color surface = Color(0xFF1A1A2E);     // Tape Deck Navy (containers, cards)
  static const Color onSurface = Color(0xFFEAEAEA);   // Cloud Gray (high contrast text/icons)

  // Helper/UI State Colors
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2A2A4E);
  static const Color inactiveText = Color(0xFF8D8DAA);
}
