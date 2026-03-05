import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _currency = 'TRY';
  String _language = 'TR';

  static const String _soundEnabledKey = 'sound_enabled';

  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
  }

  Future<void> _loadSoundSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    });
  }

  Future<void> _setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
    setState(() => _soundEnabled = value);
  }

  Future<void> _toggleAiUsage(SettingsProvider settings, bool value) async {
    if (!value) {
      await settings.setAiEnabled(false);
      return;
    }

    final enteredToken = await _showGroqTokenDialog(initialValue: settings.groqToken);
    if (enteredToken == null) return;

    if (enteredToken.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI kullanımı için Groq tokeni zorunludur.')),
      );
      return;
    }

    await settings.setGroqToken(enteredToken);
    await settings.setAiEnabled(true);
  }

  Future<String?> _showGroqTokenDialog({String initialValue = ''}) async {
    final controller = TextEditingController(text: initialValue);
    final token = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Groq Tokeni'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Token',
            hintText: 'gsk_... ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    controller.dispose();
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Genel'),
          _buildSettingCard(
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Bildirimler',
                  subtitle: 'Hatırlatma bildirimleri al',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Ses Efektleri',
                  subtitle: 'Uygulama içi sesler',
                  value: _soundEnabled,
                  onChanged: _setSoundEnabled,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Görünüm'),
          _buildSettingCard(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Karanlık Mod',
                  subtitle: 'Koyu tema kullan',
                  value: settings.darkMode,
                  onChanged: (value) {
                    settings.setDarkMode(value);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Yapay Zeka'),
          _buildSettingCard(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI Kullan',
                      subtitle: 'Özet sekmesini ve AI analizini aç',
                      value: settings.aiEnabled,
                      onChanged: (value) => _toggleAiUsage(settings, value),
                    ),
                    if (settings.aiEnabled) ...[
                      const Divider(height: 1),
                      _buildActionTile(
                        icon: Icons.key_outlined,
                        title: 'Groq Tokenini Güncelle',
                        subtitle: settings.groqToken.isEmpty
                            ? 'Henüz token girilmedi'
                            : 'Token kayıtlı',
                        onTap: () async {
                          final enteredToken = await _showGroqTokenDialog(
                            initialValue: settings.groqToken,
                          );
                          if (enteredToken == null || enteredToken.trim().isEmpty) {
                            return;
                          }
                          await settings.setGroqToken(enteredToken);
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Bölge ve Dil'),
          _buildSettingCard(
            child: Column(
              children: [
                _buildDropdownTile(
                  icon: Icons.attach_money,
                  title: 'Para Birimi',
                  value: _currency,
                  items: const ['TRY', 'USD', 'EUR', 'GBP'],
                  labels: const {
                    'TRY': '₺ Türk Lirası',
                    'USD': '\$ Dolar',
                    'EUR': '€ Euro',
                    'GBP': '£ Sterlin',
                  },
                  onChanged: (value) {
                    setState(() => _currency = value!);
                  },
                ),
                const Divider(height: 1),
                _buildDropdownTile(
                  icon: Icons.language,
                  title: 'Dil',
                  value: _language,
                  items: const ['TR', 'EN'],
                  labels: const {'TR': 'Türkçe', 'EN': 'English'},
                  onChanged: (value) {
                    setState(() => _language = value!);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Veri Yönetimi'),
          _buildSettingCard(
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.backup_outlined,
                  title: 'Yedekleme',
                  subtitle: 'Verilerini yedekle',
                  onTap: _showBackupDialog,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.restore_outlined,
                  title: 'Geri Yükle',
                  subtitle: 'Yedeği geri yükle',
                  onTap: _showRestoreDialog,
                ),
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.delete_outline,
                  title: 'Tüm Verileri Sil',
                  subtitle: 'Uygulamayı sıfırla',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: _showDeleteDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green, size: 24),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Map<String, String> labels,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green, size: 24),
      ),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(labels[item] ?? item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.green).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Colors.green, size: 24),
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yedekleme'),
        content: const Text('Verileriniz yedeğe alınsın mı?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yedekleme tamamlandı!')),
              );
            },
            child: const Text('Yedekle'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geri Yükle'),
        content: const Text('Yedekten geri yüklemek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Geri yükleme tamamlandı!')),
              );
            },
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text(
          'Bu işlem geri alınamaz! Tüm verileriniz silinecek. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tüm veriler silindi!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
