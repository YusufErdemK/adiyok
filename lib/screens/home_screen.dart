import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'tree_screen.dart';
import 'transaction_screen.dart';
import 'summary_screen.dart';
import 'wallet_screen.dart';
import 'about_screen.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    final screens = [
      const TreeScreen(),
      const TransactionScreen(),
      const WalletScreen(),
      if (settings.aiEnabled) const SummaryScreen(),
    ];

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.nature_outlined),
        selectedIcon: Icon(Icons.nature),
        label: 'Ağaç',
      ),
      const NavigationDestination(
        icon: Icon(Icons.wallet_outlined),
        selectedIcon: Icon(Icons.wallet),
        label: 'Finans',
      ),
      const NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: 'Cüzdanım',
      ),
      if (settings.aiEnabled)
        const NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: 'Özet',
        ),
    ];

    if (_currentIndex >= screens.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = screens.length - 1);
      });
    }

    final safeIndex = _currentIndex >= screens.length
        ? screens.length - 1
        : _currentIndex;

    return Scaffold(
      body: Stack(
        children: [
          screens[safeIndex],
          Positioned(
            top: 10,
            right: 6,
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 1, child: Text('Ayarlar')),
                PopupMenuItem(value: 2, child: Text('Hakkında')),
              ],
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                } else if (value == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: destinations,
        ),
      ),
    );
  }
}
