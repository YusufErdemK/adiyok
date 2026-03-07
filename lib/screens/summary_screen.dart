import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/tree_provider.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';

const _chartColors = [
  Color(0xFF2D6A4F),
  Color(0xFF52B788),
  Color(0xFF74C69D),
  Color(0xFFB7E4C7),
  Color(0xFF1B4332),
  Color(0xFF40916C),
  Color(0xFF95D5B2),
  Color(0xFFD8F3DC),
];

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Özet state
  String _analysisResult = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _hasAnalyzed = false;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── AI ANALİZ ────────────────────────────────────────────────────────────
  Future<void> _analyzeWithAI() async {
    final txProvider = context.read<TransactionProvider>();
    final treeProvider = context.read<TreeProvider>();
    final settings = context.read<SettingsProvider>();
    final groqApiKey = settings.groqApiKey;

    setState(() {
      _isLoading = true;
      _analysisResult = '';
      _errorMessage = '';
    });

    final transactions = txProvider.transactions;

    final categoryTotals = <String, double>{};
    for (final t in transactions) {
      final key = '${t.displayEmoji} ${t.displayCategory}';
      categoryTotals[key] = (categoryTotals[key] ?? 0) + t.amount * t.quantity;
    }

    final categorySummary = categoryTotals.entries
        .map((e) => '- ${e.key}: ${e.value.toStringAsFixed(2)} TL')
        .join('\n');

    final recentTx = transactions
        .take(5)
        .map((t) {
          final type = t.isIncome ? 'Gelir' : 'Gider';
          return '- ${t.title}: ${(t.amount * t.quantity).toStringAsFixed(2)} TL ($type, ${t.displayCategory})';
        })
        .join('\n');

    final prompt =
        '''
Sen bir kişisel finans danışmanısın. Aşağıdaki verileri Türkçe analiz et.

ÖZET:
- Toplam Gelir: ${txProvider.totalIncome.toStringAsFixed(2)} TL
- Toplam Gider: ${txProvider.totalExpense.toStringAsFixed(2)} TL
- Net Bakiye: ${txProvider.netIncome.toStringAsFixed(2)} TL
- İşlem Sayısı: ${transactions.length}
- Ağaç Düğüm Sayısı: ${treeProvider.getTotalNodeCount()}

KATEGORİ DAĞILIMI:
$categorySummary

SON İŞLEMLER:
$recentTx

Lütfen şunları yap:
1. 💡 Genel finansal durumu değerlendir
2. ⚠️ Dikkat çeken harcama/gelir kalemini yorumla
3. 💰 2-3 somut tasarruf önerisi sun
4. 🌳 Ağaç yapısı kullanımı hakkında yorum yap
5. ✅ Motive edici bir kapanış yap
6. Yanlış yorum yapmamaya özen göster.

Başlıklar ve emoji kullanarak düzenli yaz.''';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $groqApiKey',
            },
            body: jsonEncode({
              'model': 'llama-3.3-70b-versatile',
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 1024,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['choices'][0]['message']['content'] as String;
        setState(() {
          _analysisResult = text;
          _hasAnalyzed = true;
          _isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              'Hata ${response.statusCode}: ${errorData['error']?['message'] ?? response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  // ─── VERİ HAZIRLAMA ───────────────────────────────────────────────────────

  Map<String, Map<String, double>> _getMonthlyData(
    List<Transaction> transactions,
  ) {
    final result = <String, Map<String, double>>{};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM yy', 'tr_TR').format(month);
      result[key] = {'gelir': 0, 'gider': 0};
    }
    for (final t in transactions) {
      final key = DateFormat('MMM yy', 'tr_TR').format(t.date);
      if (result.containsKey(key)) {
        final field = t.isIncome ? 'gelir' : 'gider';
        result[key]![field] =
            (result[key]![field] ?? 0) + t.amount * t.quantity;
      }
    }
    return result;
  }

  Map<String, double> _getWeeklyExpenses(List<Transaction> transactions) {
    final result = <String, double>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = DateFormat('E', 'tr_TR').format(day);
      result[key] = 0;
    }
    for (final t in transactions.where((t) => t.isExpense)) {
      final dayDiff = now.difference(t.date).inDays;
      if (dayDiff <= 6) {
        final key = DateFormat('E', 'tr_TR').format(t.date);
        result[key] = (result[key] ?? 0) + t.amount * t.quantity;
      }
    }
    return result;
  }

  Map<String, double> _getCategoryExpenses(List<Transaction> transactions) {
    final result = <String, double>{};
    for (final t in transactions.where((t) => t.isExpense)) {
      final key = t.displayCategory;
      result[key] = (result[key] ?? 0) + t.amount * t.quantity;
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  List<double> _getNetTrend(List<Transaction> transactions) {
    final monthly = _getMonthlyData(transactions);
    double cumulative = 0;
    return monthly.values.map((m) {
      cumulative += (m['gelir'] ?? 0) - (m['gider'] ?? 0);
      return cumulative;
    }).toList();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özet'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Grafikler'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Takvim'),
            Tab(icon: Icon(Icons.store_outlined), text: 'İşletmeler'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartsTab(txProvider),
                const _CalendarTab(),
                const _BusinessTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab(TransactionProvider txProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final transactions = txProvider.transactions;
    final hasData = transactions.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Gelir',
                  value: txProvider.totalIncome.toStringAsFixed(2),
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: 'Gider',
                  value: txProvider.totalExpense.toStringAsFixed(2),
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StatCard(
            label: 'Net Bakiye',
            value: txProvider.netIncome.toStringAsFixed(2),
            icon: txProvider.netIncome >= 0
                ? Icons.account_balance_wallet
                : Icons.warning_amber_rounded,
            color: txProvider.netIncome >= 0
                ? colorScheme.primary
                : Colors.orange,
            large: true,
          ),
          const SizedBox(height: 24),
          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Grafikleri görmek için işlem ekleyin.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            _ChartCard(
              title: '📈 Aylık Gelir & Gider',
              height: 220,
              child: _buildLineChart(transactions, colorScheme),
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: '📊 Haftalık Harcama',
              height: 200,
              child: _buildBarChart(transactions, colorScheme),
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: '🥧 Kategori Dağılımı (Gider)',
              height: 260,
              child: _buildPieChart(transactions, colorScheme),
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: '💰 Net Bakiye Trendi',
              height: 200,
              child: _buildTrendChart(transactions, colorScheme),
            ),
            const SizedBox(height: 24),
          ],
          FilledButton.icon(
            onPressed: (_isLoading || !hasData) ? null : _analyzeWithAI,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _isLoading
                  ? 'Analiz ediliyor...'
                  : _hasAnalyzed
                  ? 'Yeniden Analiz Et'
                  : 'AI ile Analiz Et',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_errorMessage.isNotEmpty)
            Card(
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasAnalyzed && _analysisResult.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Analizi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    MarkdownBody(
                      data: _analysisResult,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 14, height: 1.65),
                        strong: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        listBullet: const TextStyle(fontSize: 14, height: 1.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── GRAFİK BUILDER'LAR ───────────────────────────────────────────────────

  Widget _buildLineChart(
    List<Transaction> transactions,
    ColorScheme colorScheme,
  ) {
    final monthly = _getMonthlyData(transactions);
    final labels = monthly.keys.toList();
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int i = 0; i < labels.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), monthly[labels[i]]!['gelir']!));
      expenseSpots.add(FlSpot(i.toDouble(), monthly[labels[i]]!['gider']!));
    }

    final maxY = [
      ...incomeSpots,
      ...expenseSpots,
    ].map((s) => s.y).fold(0.0, max);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 100 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withValues(alpha: 0.08),
            ),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(0)} ₺',
                    TextStyle(
                      color: s.bar.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(
    List<Transaction> transactions,
    ColorScheme colorScheme,
  ) {
    final weekly = _getWeeklyExpenses(transactions);
    final labels = weekly.keys.toList();
    final values = weekly.values.toList();
    final maxY = values.fold(0.0, max);

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 100 : maxY * 1.25,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          labels.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: colorScheme.primary,
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY == 0 ? 100 : maxY * 1.25,
                  color: colorScheme.primary.withValues(alpha: 0.06),
                ),
              ),
            ],
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              '${rod.toY.toStringAsFixed(0)} ₺',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
    List<Transaction> transactions,
    ColorScheme colorScheme,
  ) {
    final categoryData = _getCategoryExpenses(transactions);
    if (categoryData.isEmpty) return const Center(child: Text('Gider yok'));

    final entries = categoryData.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedPieIndex = -1;
                    } else {
                      _touchedPieIndex =
                          response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: List.generate(entries.length, (i) {
                final isTouched = i == _touchedPieIndex;
                final pct = (entries[i].value / total * 100);
                return PieChartSectionData(
                  color: _chartColors[i % _chartColors.length],
                  value: entries[i].value,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: isTouched ? 62 : 52,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(
            entries.length,
            (i) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _chartColors[i % _chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(entries[i].key, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(
    List<Transaction> transactions,
    ColorScheme colorScheme,
  ) {
    final trend = _getNetTrend(transactions);
    final monthly = _getMonthlyData(transactions);
    final labels = monthly.keys.toList();
    final spots = List.generate(
      trend.length,
      (i) => FlSpot(i.toDouble(), trend[i]),
    );
    final minY = trend.fold(0.0, min);
    final maxY = trend.fold(0.0, max);
    final padding = (maxY - minY).abs() < 10 ? 50.0 : (maxY - minY) * 0.2;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: spot.y >= 0 ? Colors.green : Colors.red,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.grey.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(0)} ₺',
                    TextStyle(
                      color: s.y >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─── TAKVİM SEKMESİ ───────────────────────────────────────────────────────────

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _showDaySheet(
    BuildContext context,
    DateTime day,
    List<Transaction> txList,
  ) {
    final dayTx =
        txList
            .where(
              (t) =>
                  t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    DateFormat('d MMMM yyyy', 'tr_TR').format(day),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (dayTx.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayTx.length} işlem',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (dayTx.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Bu gün işlem yok',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: dayTx.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey[100]),
                    itemBuilder: (context, i) => _TxRow(transaction: dayTx[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final transactions = txProvider.transactions;
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();

    final activeDays = transactions
        .where(
          (t) =>
              t.date.year == _focusedMonth.year &&
              t.date.month == _focusedMonth.month,
        )
        .map((t) => t.date.day)
        .toSet();

    // Ay özeti
    final monthTx = transactions.where(
      (t) =>
          t.date.year == _focusedMonth.year &&
          t.date.month == _focusedMonth.month,
    );
    final monthIncome = monthTx
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount * t.quantity);
    final monthExpense = monthTx
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount * t.quantity);

    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final startOffset = (firstDay.weekday - 1) % 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ay navigasyonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  );
                }),
              ),
              Text(
                DateFormat('MMMM yyyy', 'tr_TR').format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Gün başlıkları
          Row(
            children: ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),

          // ── Takvim grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              for (int i = 0; i < startOffset; i++) const SizedBox(),
              for (int day = 1; day <= daysInMonth; day++)
                Builder(
                  builder: (context) {
                    final date = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month,
                      day,
                    );
                    final isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    final hasActivity = activeDays.contains(day);

                    return GestureDetector(
                      onTap: () => _showDaySheet(context, date, transactions),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isToday
                              ? colorScheme.primary
                              : hasActivity
                              ? colorScheme.primary.withValues(alpha: 0.08)
                              : null,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isToday ? Colors.white : null,
                              ),
                            ),
                            if (hasActivity && !isToday)
                              Positioned(
                                bottom: 5,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),

          // ── Ay özeti
          Row(
            children: [
              Expanded(
                child: _MonthStat(
                  label: 'Gelir',
                  value: monthIncome,
                  color: const Color(0xFF34C759),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MonthStat(
                  label: 'Gider',
                  value: monthExpense,
                  color: const Color(0xFFFF3B30),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MonthStat(
                  label: 'Net',
                  value: monthIncome - monthExpense,
                  color: monthIncome >= monthExpense
                      ? const Color(0xFF34C759)
                      : const Color(0xFFFF3B30),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── O ayın işlem listesi (tarih gruplu)
          if (activeDays.isNotEmpty) ...[
            Text(
              'Bu Aydaki İşlemler',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            ...(() {
              final grouped = <int, List<Transaction>>{};
              for (final t in transactions.where(
                (t) =>
                    t.date.year == _focusedMonth.year &&
                    t.date.month == _focusedMonth.month,
              )) {
                grouped.putIfAbsent(t.date.day, () => []).add(t);
              }
              final sortedDays = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return sortedDays.map((day) {
                final dayTx = grouped[day]!
                  ..sort((a, b) => b.date.compareTo(a.date));
                final date = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  day,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        DateFormat('d MMMM, EEEE', 'tr_TR').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      child: Column(
                        children: [
                          for (int i = 0; i < dayTx.length; i++) ...[
                            _TxRow(transaction: dayTx[i]),
                            if (i < dayTx.length - 1)
                              Divider(
                                height: 1,
                                color: Colors.grey[200],
                                indent: 52,
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList();
            })(),
          ],
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MonthStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(0)} ₺',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final Transaction transaction;
  const _TxRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
    final total = transaction.amount * transaction.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Text(transaction.displayEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  transaction.displayCategory,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '−'}${total.toStringAsFixed(2)} ₺',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── YARDIMCI WİDGETLAR ────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;

  const _ChartCard({
    required this.title,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 14),
            SizedBox(height: height, child: child),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool large;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$value ₺',
                    style: TextStyle(
                      fontSize: large ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── İŞLETMELER SEKMESİ ──────────────────────────────────────────────────────

class _BusinessTab extends StatelessWidget {
  const _BusinessTab();

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final colorScheme = Theme.of(context).colorScheme;

    // İşletme bazlı grupla
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      final business = (t.notes?.trim().isNotEmpty == true)
          ? t.notes!.trim()
          : '— İşletme Belirtilmemiş';
      grouped.putIfAbsent(business, () => []).add(t);
    }

    // Toplam harcamaya göre sırala (belirtilmemiş en sona)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == '— İşletme Belirtilmemiş') return 1;
        if (b == '— İşletme Belirtilmemiş') return -1;
        final totalA = grouped[a]!.fold(
          0.0,
          (s, t) => s + t.amount * t.quantity,
        );
        final totalB = grouped[b]!.fold(
          0.0,
          (s, t) => s + t.amount * t.quantity,
        );
        return totalB.compareTo(totalA);
      });

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_outlined,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz işlem yok',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: sortedKeys.length,
      itemBuilder: (context, i) {
        final business = sortedKeys[i];
        final txList = grouped[business]!
          ..sort((a, b) => b.date.compareTo(a.date));
        final totalExpense = txList
            .where((t) => t.isExpense)
            .fold(0.0, (s, t) => s + t.amount * t.quantity);
        final totalIncome = txList
            .where((t) => t.isIncome)
            .fold(0.0, (s, t) => s + t.amount * t.quantity);
        final isUnlabeled = business == '— İşletme Belirtilmemiş';

        return _BusinessCard(
          business: business,
          transactions: txList,
          totalExpense: totalExpense,
          totalIncome: totalIncome,
          isUnlabeled: isUnlabeled,
        );
      },
    );
  }
}

class _BusinessCard extends StatefulWidget {
  final String business;
  final List<Transaction> transactions;
  final double totalExpense;
  final double totalIncome;
  final bool isUnlabeled;

  const _BusinessCard({
    required this.business,
    required this.transactions,
    required this.totalExpense,
    required this.totalIncome,
    required this.isUnlabeled,
  });

  @override
  State<_BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<_BusinessCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const expenseColor = Color(0xFFFF3B30);
    const incomeColor = Color(0xFF34C759);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Column(
        children: [
          // ── Başlık satırı
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.isUnlabeled
                          ? colorScheme.onSurface.withValues(alpha: 0.06)
                          : colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.isUnlabeled ? '❓' : '🏪',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.business,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: widget.isUnlabeled
                                ? colorScheme.onSurface.withValues(alpha: 0.5)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.transactions.length} işlem',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.totalExpense > 0)
                        Text(
                          '−${widget.totalExpense.toStringAsFixed(0)} ₺',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: expenseColor,
                          ),
                        ),
                      if (widget.totalIncome > 0)
                        Text(
                          '+${widget.totalIncome.toStringAsFixed(0)} ₺',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: incomeColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          // ── Açılır işlem listesi
          if (_expanded) ...[
            Divider(
              height: 1,
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              indent: 16,
            ),
            ...widget.transactions.asMap().entries.map((entry) {
              final t = entry.value;
              final isIncome = t.isIncome;
              final color = isIncome ? incomeColor : expenseColor;
              final total = t.amount * t.quantity;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Text(
                          t.displayEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${t.displayCategory} · ${DateFormat('d MMM', 'tr_TR').format(t.date)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '−'}${total.toStringAsFixed(2)} ₺',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.key < widget.transactions.length - 1)
                    Divider(
                      height: 1,
                      color: colorScheme.onSurface.withValues(alpha: 0.06),
                      indent: 52,
                    ),
                ],
              );
            }).toList(),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
