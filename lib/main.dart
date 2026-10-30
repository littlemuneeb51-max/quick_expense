import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_expense/core/database/database_service.dart';
import 'package:quick_expense/core/theme/app_theme.dart';
import 'package:quick_expense/core/theme/theme_notifier.dart';
import 'package:quick_expense/core/providers/transaction_provider.dart';
import 'package:quick_expense/screens/splash_screen.dart';

void main() async {
  // Ensure widget bindings are initialized before calling async platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local offline Hive Database Service
  await DatabaseService.instance.init();

  // Load SharedPreferences for local configuration storage
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
      ],
      child: const QuickExpenseApp(),
    ),
  );
}

class QuickExpenseApp extends StatelessWidget {
  const QuickExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Quick Expense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      home: const SplashScreen(),
    );
  }
}
