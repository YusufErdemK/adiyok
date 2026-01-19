import 'package:flutter/material.dart';
import 'tree_screen.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final screens = [const TreeScreen(), const TransactionScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
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
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.nature_outlined),
              selectedIcon: const Icon(Icons.nature),
              label: 'Ağaç',
            ),
            NavigationDestination(
              icon: const Icon(Icons.wallet_outlined),
              selectedIcon: const Icon(Icons.wallet),
              label: 'Finans',
            ),
          ],
        ),
      ),
    );
  }
}
