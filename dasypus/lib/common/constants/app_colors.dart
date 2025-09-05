import 'package:flutter/material.dart';

class AppColors {
  // Cores principais
  static const Color primary = Color(0xFF667eea);
  static const Color secondary = Color(0xFF764ba2);
  static const Color accent = Color(0xFF4CAF50);
  
  // Cores de fundo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Gradientes
  static const List<Color> blueGradient = [
    Color(0xFF00AEEF), 
    Color(0xFF0077B6), 
  ];
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.fromARGB(255, 140, 161, 253), Color(0xFF667eea)],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFF45A049)],
  );

  static var primaryLightOpacity;

  static Color? get azulEscuro => null;

  static Color? get azulMuitoClaro => null;

  static Color? get azulClaro => null;
} 