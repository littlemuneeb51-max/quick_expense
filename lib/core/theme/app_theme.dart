import 'package:flutter/material.dart';

/// Custom theme extension to add finance-specific semantic colors
/// (Income and Expense) that adapt properly to light/dark themes.
class FinanceColors extends ThemeExtension<FinanceColors> {
  final Color income;
  final Color expense;

  const FinanceColors({
    required this.income,
    required this.expense,
  });

  @override
  FinanceColors copyWith({Color? income, Color? expense}) {
    return FinanceColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  FinanceColors lerp(ThemeExtension<FinanceColors>? other, double t) {
    if (other is! FinanceColors) {
      return this;
    }
    return FinanceColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
    );
  }

  /// Helper to get colors easily from BuildContext
  static FinanceColors of(BuildContext context) {
    final colors = Theme.of(context).extension<FinanceColors>();
    assert(colors != null, 'FinanceColors extension not found in theme.');
    return colors!;
  }
}

/// AppTheme configuration for Quick Expense.
/// Implements Light (default) and Dark modes with clean minimalist design.
class AppTheme {
  AppTheme._();

  // Color Constants - Light Mode
  static const Color _lightBackground = Color(0xFFF8F9FA);
  static const Color _lightTextPrimary = Color(0xFF212529);
  static const Color _lightIncome = Color(0xFF2ECC71); // Emerald Green
  static const Color _lightExpense = Color(0xFFE74C3C); // Crimson Red
  static const Color _lightSurface = Colors.white;

  // Color Constants - Dark Mode
  static const Color _darkBackground = Color(0xFF1E1E24); // Deep Charcoal Grey
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkIncome = Color(0xFF00E676); // Neon Green
  static const Color _darkExpense = Color(0xFFFF1744); // Neon Red
  static const Color _darkSurface = Color(0xFF292930); // Slightly lighter depth

  /// Light Theme Configuration (Default)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _lightIncome,
        secondary: _lightExpense,
        surface: _lightSurface,
        onSurface: _lightTextPrimary,
        error: _lightExpense,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBackground,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightIncome;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return _lightIncome.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        FinanceColors(
          income: _lightIncome,
          expense: _lightExpense,
        ),
      ],
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _darkIncome,
        secondary: _darkExpense,
        surface: _darkSurface,
        onSurface: _darkTextPrimary,
        error: _darkExpense,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkIncome;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkIncome.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        FinanceColors(
          income: _darkIncome,
          expense: _darkExpense,
        ),
      ],
    );
  }
}
