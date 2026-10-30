import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quick_expense/core/theme/app_theme.dart';

/// Helper to resolve category specific colors
Color getCategoryColor(String category, FinanceColors financeColors) {
  switch (category) {
    case 'Salary':
      return financeColors.income;
    case 'Business':
      return financeColors.income.withValues(alpha: 0.85);
    case 'Investments':
      return financeColors.income.withValues(alpha: 0.65);
    case 'Food':
      return financeColors.expense;
    case 'Transport':
      return Colors.orangeAccent;
    case 'Rent':
      return Colors.purpleAccent;
    case 'Shopping':
      return Colors.pinkAccent;
    case 'Utilities':
      return Colors.amberAccent;
    case 'Entertainment':
      return Colors.cyanAccent;
    default:
      return Colors.grey;
  }
}

/// An animated Donut (Pie) Chart showing transaction outlays by category.
class CategoryDonutChart extends StatefulWidget {
  final Map<String, double> data;
  final double total;

  const CategoryDonutChart({
    super.key,
    required this.data,
    required this.total,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation when data changes
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financeColors = FinanceColors.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _DonutChartPainter(
            data: widget.data,
            total: widget.total,
            animationValue: _animation.value,
            financeColors: financeColors,
            textColor: theme.colorScheme.onSurface,
            isDark: theme.brightness == Brightness.dark,
          ),
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;
  final double animationValue;
  final FinanceColors financeColors;
  final Color textColor;
  final bool isDark;

  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.animationValue,
    required this.financeColors,
    required this.textColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 24.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Handle empty data scenario
    if (total == 0 || data.isEmpty) {
      paint.color = textColor.withValues(alpha: 0.08);
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);

      // Draw "No Data" text
      _drawCenterText(canvas, center, 'No Data', '\$0.00');
      return;
    }

    double startAngle = -pi / 2;

    data.forEach((category, amount) {
      final sweepAngle = (amount / total) * 2 * pi * animationValue;
      paint.color = getCategoryColor(category, financeColors);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    });

    // Draw total label in the center
    _drawCenterText(
      canvas,
      center,
      'TOTAL',
      '\$${total.toStringAsFixed(2)}',
    );
  }

  void _drawCenterText(Canvas canvas, Offset center, String label, String value) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Style label
    textPainter.text = TextSpan(
      text: '$label\n',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: textColor.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
      children: [
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
            height: 1.4,
          ),
        ),
      ],
    );

    textPainter.layout(minWidth: 0, maxWidth: 120);
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.total != total ||
        oldDelegate.data != data;
  }
}

/// An animated Cash Flow Comparison Bar Chart (Income vs Expense).
class CashFlowBarChart extends StatefulWidget {
  final double income;
  final double expense;

  const CashFlowBarChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  State<CashFlowBarChart> createState() => _CashFlowBarChartState();
}

class _CashFlowBarChartState extends State<CashFlowBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CashFlowBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financeColors = FinanceColors.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(260, 180),
          painter: _BarChartPainter(
            income: widget.income,
            expense: widget.expense,
            animationValue: _animation.value,
            financeColors: financeColors,
            textColor: theme.colorScheme.onSurface,
            isDark: theme.brightness == Brightness.dark,
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final double income;
  final double expense;
  final double animationValue;
  final FinanceColors financeColors;
  final Color textColor;
  final bool isDark;

  _BarChartPainter({
    required this.income,
    required this.expense,
    required this.animationValue,
    required this.financeColors,
    required this.textColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal = max(income, expense);
    final double limit = maxVal == 0 ? 100.0 : maxVal;

    final barWidth = size.width * 0.22;
    final spacing = size.width * 0.15;
    final startX = (size.width - (2 * barWidth + spacing)) / 2;

    // Draw baseline
    final linePaint = Paint()
      ..color = textColor.withValues(alpha: 0.1)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(10, size.height - 30),
      Offset(size.width - 10, size.height - 30),
      linePaint,
    );

    // Helper to draw a single bar
    void drawBar(double val, Color color, double xPos, String label) {
      final barHeight = ((val / limit) * (size.height - 60)) * animationValue;
      final rect = Rect.fromLTWH(
        xPos,
        size.height - 30 - barHeight,
        barWidth,
        max(barHeight, 4.0), // Ensure at least a line is visible if 0
      );

      final barPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw rounded bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        barPaint,
      );

      // Value label on top
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.text = TextSpan(
        text: '\$${val.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: 0.7),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          xPos + (barWidth - textPainter.width) / 2,
          size.height - 30 - barHeight - 16,
        ),
      );

      // Label below baseline
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: 0.5),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          xPos + (barWidth - textPainter.width) / 2,
          size.height - 24,
        ),
      );
    }

    // Draw Income Bar
    drawBar(income, financeColors.income, startX, 'Income');

    // Draw Expense Bar
    drawBar(expense, financeColors.expense, startX + barWidth + spacing, 'Expenses');
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.income != income ||
        oldDelegate.expense != expense;
  }
}
