import 'package:flutter/material.dart';

// ── Paleta de colores extraída del logotipo del Humedal La Arenilla ─────────
// Azul marino oscuro #152060  → Silueta de las aves / Texto "HUMEDAL COSTERO"
// Azul cian intenso  #00A8E0  → Ondas de agua / Texto "LA POZA"
// Azul intermedio    #4DB8E6  → Áreas intermedias de las olas
// ───────────────────────────────────────────────────────────────────────────

/// Clase que contiene la definición de colores de la aplicación,
/// extraídos directamente de la identidad visual (logotipo) del humedal.
class AppColors {
  static const Color navy      = Color(0xFF152060); // Azul marino profundo del logo
  static const Color navyMid   = Color(0xFF1E3585); // Azul marino ligeramente más claro
  static const Color navyDark  = Color(0xFF0D1545); // El más oscuro: para encabezados y pies de página
  static const Color cyan      = Color(0xFF00A8E0); // Azul cian vivo del logo
  static const Color cyanDark  = Color(0xFF0080B0); // Cian más oscuro
  static const Color cyanLight = Color(0xFF4DB8E6); // Azul medio-claro del logo
  static const Color skyLight  = Color(0xFFC8EAF8); // Color cielo claro para fondos
  static const Color skyPale   = Color(0xFFE4F4FC); // Color cielo pálido
  static const Color white     = Color(0xFFFFFFFF); // Blanco puro
  static const Color textNavy  = Color(0xFF152060); // Color principal para textos (Azul marino)
  static const Color textGray  = Color(0xFF3D5A80); // Color grisáceo para textos secundarios
  static const Color textMuted = Color(0xFF6A8AAA); // Color atenuado para textos deshabilitados
}

/// Clase principal de temas (Theme) de la aplicación.
/// Define la configuración general de colores y tipografía para toda la interfaz.
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      // Activar componentes de Material 3
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary:   AppColors.navy,
        secondary: AppColors.cyan,
        surface:   AppColors.skyPale,
      ),
      // Tipografía principal del proyecto
      fontFamily: 'Roboto',
      // Color de fondo por defecto para todas las pantallas
      scaffoldBackgroundColor: AppColors.skyLight,
    );
  }
}
