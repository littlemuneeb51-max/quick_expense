import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quick_expense/core/theme/app_theme.dart';
import 'package:quick_expense/core/theme/theme_notifier.dart';
import 'package:quick_expense/core/providers/transaction_provider.dart';
import 'package:quick_expense/models/transaction_model.dart';
import 'package:quick_expense/widgets/charts.dart';

/// Interactive Dashboard Screen for Quick Expense.
/// Integrates animated custom charts, category filtering chips, net balance summaries,
/// swipe-to-delete CRUD actions, tap-to-edit records, and a master data reset utility.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeFilter = 'All'; // Filter state: All, Income, Expenses, or Category Name
  bool _showDonutChart = true; // Toggle between Donut Chart (Breakdown) and Bar Chart (Cash Flow)

  // Date Formatter helper
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Returns icon matching the category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Salary':
        return Icons.work_rounded;
      case 'Business':
        return Icons.storefront_rounded;
      case 'Investments':
        return Icons.trending_up_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Rent':
        return Icons.home_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Utilities':
        return Icons.bolt_rounded;
      case 'Entertainment':
        return Icons.local_play_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Filter helper returning matching transactions
  List<Transaction> _getFilteredTransactions(List<Transaction> allTxs) {
    if (_activeFilter == 'All') return allTxs;
    if (_activeFilter == 'Income') return allTxs.where((tx) => tx.isIncome).toList();
    if (_activeFilter == 'Expenses') return allTxs.where((tx) => !tx.isIncome).toList();
    // Otherwise filter by specific Category Name
    return allTxs.where((tx) => tx.category == _activeFilter).toList();
  }

  /// Helper to group category outlays for chart display
  Map<String, double> _groupCategoryData(List<Transaction> txs) {
    final Map<String, double> grouped = {};
    for (var tx in txs) {
      grouped[tx.category] = (grouped[tx.category] ?? 0.0) + tx.amount;
    }
    return grouped;
  }

  /// Reset all data confirmation dialog
  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final financeColors = FinanceColors.of(context);
        return AlertDialog(
          title: const Text('Reset All Transactions?'),
          content: const Text(
            'This will permanently delete all logged transactions. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<TransactionProvider>(context, listen: false).clearAllTransactions();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All transactions have been deleted.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Reset All',
                style: TextStyle(
                  color: financeColors.expense,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final financeColors = FinanceColors.of(context);
    final theme = Theme.of(context);

    final filteredTxs = _getFilteredTransactions(txProvider.transactions);
    final groupedData = _groupCategoryData(filteredTxs);
    final double filteredTotal = groupedData.values.fold(0.0, (sum, val) => sum + val);

    final List<String> filters = [
      'All',
      'Income',
      'Expenses',
      'Food',
      'Salary',
      'Rent',
      'Transport',
      'Shopping',
      'Utilities',
      'Entertainment',
      'Others'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Expense'),
        titleSpacing: 20,
        actions: [
          // Reset/Clear All Action
          if (txProvider.transactions.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_sweep_rounded,
                color: financeColors.expense.withValues(alpha: 0.8),
              ),
              onPressed: () => _showResetConfirmationDialog(context),
              tooltip: 'Reset All Transactions',
            ),
          const SizedBox(width: 4),
          Icon(
            themeNotifier.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Switch(
            value: themeNotifier.isDarkMode,
            onChanged: (_) => themeNotifier.toggleTheme(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Scrollable Dashboard Body
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Net Balance Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeNotifier.isDarkMode
                              ? [const Color(0xFF292930), const Color(0xFF1E1E24)]
                              : [const Color(0xFF212529), const Color(0xFF343A40)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL BALANCE',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${txProvider.totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              // Income summary column
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: financeColors.income.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_upward_rounded,
                                        color: financeColors.income,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'INCOME',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '\$${txProvider.totalIncome.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: financeColors.income,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Expense summary column
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: financeColors.expense.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_downward_rounded,
                                        color: financeColors.expense,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'EXPENSES',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '\$${txProvider.totalExpense.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: financeColors.expense,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Premium Analytics Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Card(
                      elevation: 0,
                      color: themeNotifier.isDarkMode
                          ? const Color(0xFF292930)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Chart Selection Toggle Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Visual Analytics',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Segment Selection button
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      _buildToggleTab('Breakdown', _showDonutChart, () {
                                        setState(() => _showDonutChart = true);
                                      }),
                                      _buildToggleTab('Cash Flow', !_showDonutChart, () {
                                        setState(() => _showDonutChart = false);
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Render Selected Chart Painter
                            _showDonutChart
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CategoryDonutChart(
                                        data: groupedData,
                                        total: filteredTotal,
                                      ),
                                      // Render a Legend if there is data
                                      if (groupedData.isNotEmpty)
                                        SizedBox(
                                          width: 110,
                                          height: 140,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: groupedData.entries.map((entry) {
                                                final percentage = filteredTotal == 0
                                                    ? 0.0
                                                    : (entry.value / filteredTotal) * 100;
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          color: getCategoryColor(
                                                              entry.key, financeColors),
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              entry.key,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                                color: theme.colorScheme.onSurface,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Text(
                                                              '${percentage.toStringAsFixed(0)}%',
                                                              style: TextStyle(
                                                                fontSize: 9,
                                                                color: theme.colorScheme.onSurface
                                                                    .withValues(alpha: 0.5),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : Center(
                                    child: CashFlowBarChart(
                                      income: txProvider.totalIncome,
                                      expense: txProvider.totalExpense,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Horizontal scrolling Filter Chip Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: filters.map((filter) {
                          final isSelected = _activeFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? (themeNotifier.isDarkMode ? Colors.black : Colors.white)
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _activeFilter = filter;
                                });
                              },
                              backgroundColor: Colors.transparent,
                              selectedColor: financeColors.income,
                              checkmarkColor:
                                  themeNotifier.isDarkMode ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Colors.transparent
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Recent Transactions Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${filteredTxs.length} items',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // 3. Transactions List Section (inside ListView)
                  filteredTxs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 54,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No matching transactions',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredTxs.length,
                          itemBuilder: (context, index) {
                            final tx = filteredTxs[index];
                            return Dismissible(
                              key: Key(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24.0),
                                decoration: BoxDecoration(
                                  color: financeColors.expense.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_sweep_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (_) {
                                txProvider.deleteTransaction(tx.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${tx.title}" deleted successfully'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Tooltip(
                                message: 'Tap to edit transaction',
                                child: Card(
                                  elevation: 0,
                                  color: themeNotifier.isDarkMode
                                      ? const Color(0xFF292930)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () => _showAddTransactionBottomSheet(context, transactionToEdit: tx),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: (tx.isIncome
                                                ? financeColors.income
                                                : financeColors.expense)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(tx.category),
                                        color: tx.isIncome
                                            ? financeColors.income
                                            : financeColors.expense,
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      tx.title,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          tx.category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(tx.date),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: tx.isIncome
                                            ? financeColors.income
                                            : financeColors.expense,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 80), // Keyboard/FAB spacing
                ],
              ),
            ),
          ],
        ),
      ),
      // 4. Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionBottomSheet(context),
        elevation: 4,
        backgroundColor: financeColors.income,
        foregroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Segment Tab Builder
  Widget _buildToggleTab(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  // Modal Bottom Sheet entry
  void _showAddTransactionBottomSheet(BuildContext context, {Transaction? transactionToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddTransactionSheet(transactionToEdit: transactionToEdit);
      },
    );
  }
}

/// Custom Bottom Sheet widget handling form entry, prefilled editing state, and submission.
class _AddTransactionSheet extends StatefulWidget {
  final Transaction? transactionToEdit;

  const _AddTransactionSheet({this.transactionToEdit});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  late bool _isIncome;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _incomeCategories = ['Salary', 'Business', 'Investments', 'Others'];
  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Rent',
    'Shopping',
    'Utilities',
    'Entertainment',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transactionToEdit;
    
    // Pre-populate fields if editing an existing transaction
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
        text: tx != null ? tx.amount.toStringAsFixed(2) : '');
    _isIncome = tx?.isIncome ?? false;
    _selectedCategory = tx?.category ?? (_isIncome ? 'Salary' : 'Food');
    _selectedDate = tx?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    // Reuse ID if editing, otherwise generate a new unique timestamp ID
    final id = widget.transactionToEdit?.id ?? DateTime.now().microsecondsSinceEpoch.toString();

    final newTx = Transaction(
      id: id,
      title: title,
      amount: amount,
      isIncome: _isIncome,
      category: _selectedCategory,
      date: _selectedDate,
    );

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financeColors = FinanceColors.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = _isIncome ? _incomeCategories : _expenseCategories;
    final isEditing = widget.transactionToEdit != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isEditing ? 'Edit Transaction' : 'Add New Transaction',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Transaction Type Selector (Segmented look)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncome = false;
                            // reset default category if not matching active list
                            if (!_expenseCategories.contains(_selectedCategory)) {
                              _selectedCategory = 'Food';
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isIncome
                                ? financeColors.expense.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !_isIncome ? financeColors.expense : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Expense',
                              style: TextStyle(
                                color: !_isIncome
                                    ? financeColors.expense
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncome = true;
                            // reset default category if not matching active list
                            if (!_incomeCategories.contains(_selectedCategory)) {
                              _selectedCategory = 'Salary';
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome
                                ? financeColors.income.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isIncome ? financeColors.income : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                color: _isIncome
                                    ? financeColors.income
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Grocery, Office Salary',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount (\$)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amt = double.tryParse(value);
                    if (amt == null || amt <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.folder_open_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Change Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isIncome ? financeColors.income : financeColors.expense,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
