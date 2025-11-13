/// Thème de l'application
/// 
/// Ce fichier contient la configuration du thème (couleurs, typographie, etc.)
/// pour assurer une cohérence visuelle dans toute l'application.
library;

import 'package:flutter/material.dart';

/// Classe contenant les thèmes de l'application
class AppTheme {
  // Couleurs personnalisées - Noir dominant, Violet ténèbre, Rouge cramoisi
  static const Color backgroundColor = Color(0xFF000000); // Noir pur
  static const Color surfaceColor = Color(0xFF121212); // Noir légèrement grisé
  static const Color cardColor = Color(0xFF1E1E1E); // Gris très foncé
  
  // Violet sombre ténèbre (couleur secondaire)
  static const Color darkPurple = Color(0xFF4A148C); // Violet profond
  static const Color darkPurpleDark = Color(0xFF2C0947); // Violet ultra sombre
  static const Color darkPurpleLight = Color(0xFF6A1B9A); // Violet moyen
  
  // Rouge foncé cramoisi (couleur tertiaire/accent)
  static const Color crimsonRed = Color(0xFF8B0000); // Rouge cramoisi foncé
  static const Color crimsonRedLight = Color(0xFFB71C1C); // Rouge plus clair
  static const Color crimsonRedDark = Color(0xFF5C0000); // Rouge ultra foncé
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanc
  static const Color textSecondary = Color(0xFFB3B3B3); // Gris clair
  
  /// Thème sombre de l'application (principal)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Schéma de couleurs
    colorScheme: const ColorScheme.dark(
      primary: darkPurple,
      primaryContainer: darkPurpleDark,
      secondary: crimsonRed,
      secondaryContainer: crimsonRedDark,
      tertiary: darkPurpleLight,
      surface: surfaceColor,
      error: crimsonRedLight,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimary,
    ),
    
    // Fond général
    scaffoldBackgroundColor: backgroundColor,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      iconTheme: IconThemeData(color: darkPurpleLight),
    ),
    
    // Cards
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 4,
      shadowColor: Color(0x4D4A148C), // darkPurple avec opacité 0.3
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    
    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: darkPurple,
    ),
    
    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPurple,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
        shadowColor: const Color(0x804A148C), // darkPurple avec opacité 0.5
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPurpleLight,
        side: const BorderSide(color: darkPurple, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPurpleLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: crimsonRed,
      foregroundColor: textPrimary,
      elevation: 6,
    ),
    
    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPurple, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0x804A148C), width: 1), // darkPurple opacité 0.5
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkPurpleLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: crimsonRed, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: Color(0x99B3B3B3)), // textSecondary opacité 0.6
    ),
    
    // Icônes
    iconTheme: const IconThemeData(
      color: darkPurpleLight,
      size: 24,
    ),
    
    // Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0x4D4A148C), // darkPurple opacité 0.3
      thickness: 1,
      space: 1,
    ),
    
    // ListTile
    listTileTheme: const ListTileThemeData(
      textColor: textPrimary,
      iconColor: darkPurpleLight,
      selectedTileColor: Color(0xFF2A0845),
      selectedColor: darkPurpleLight,
    ),
    
    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: darkPurpleLight,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Progress Indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: darkPurpleLight,
      circularTrackColor: cardColor,
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardColor,
      contentTextStyle: const TextStyle(color: textPrimary),
      actionTextColor: crimsonRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
  
  /// Thème clair (garde l'ancien pour compatibilité)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
  
  AppTheme._(); // Constructeur privé
}
