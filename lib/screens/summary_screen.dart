import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/tree_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _analysisResult = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _hasAnalyzed = false;

  Future<void> _analyzeWithAI() async {
    final txProvider = context.read<TransactionProvider>();
    final treeProvider = context.read<TreeProvider>();

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

Başlıklar ve emoji kullanarak düzenli yaz.''';

    try {
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_groqApiKey',
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

      debugPrint('Groq Status: ${response.statusCode}');
      debugPrint('Groq Body: ${response.body}');

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
      debugPrint('Exception: $e');
      setState(() {
        _errorMessage = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final hasData = txProvider.transactions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Özet'), centerTitle: true),
      body: SingleChildScrollView(
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

            const SizedBox(height: 20),

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

            if (!hasData)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Analiz için önce işlem ekleyin.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
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
                          h2: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          listBullet: const TextStyle(
                            fontSize: 14,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                color: color.withOpacity(0.12),
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
                      ).colorScheme.onSurface.withOpacity(0.55),
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
