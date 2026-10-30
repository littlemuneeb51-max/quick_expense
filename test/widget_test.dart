import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:quick_expense/main.dart';
import 'package:quick_expense/core/theme/theme_notifier.dart';
import 'package:quick_expense/core/providers/transaction_provider.dart';
import 'package:quick_expense/core/database/database_service.dart';
import 'package:quick_expense/models/transaction_model.dart';

void main() {
  late Box<Transaction> testBox;

  setUpAll(() {
    // Initialize standard Hive in a temporary directory for the unit/widget test process
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionAdapter());
    }
  });

  setUp(() async {
    // Mock the SharedPreferences local storage backend
    SharedPreferences.setMockInitialValues({});
    
    // Open a fresh temporary Box for each test
    testBox = await Hive.openBox<Transaction>('transactions_test');
    await testBox.clear();
    
    // Inject the mock box to bypass platform channel calls in tests
    DatabaseService.instance.initForTests(testBox);
  });

  tearDown(() async {
    await testBox.close();
  });

  testWidgets('App loads splash screen and navigates to home screen successfully', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
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

    // 1. Verify that the splash screen shows "Quick Expense" brand name
    expect(find.text('Quick Expense'), findsOneWidget);
    expect(find.text('Offline Personal Finance'), findsOneWidget);

    // 2. Advance clock by 2 seconds to fire navigation timer, and let route transition settle
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 3. Verify that the app successfully transitions to the HomeScreen dashboard
    expect(find.text('Recent Transactions', skipOffstage: false), findsOneWidget);
    expect(find.text('0 items', skipOffstage: false), findsOneWidget);
    expect(find.text('TOTAL BALANCE', skipOffstage: false), findsOneWidget);
  });
}
