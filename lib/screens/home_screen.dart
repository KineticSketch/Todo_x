import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'today_screen.dart';
import 'overview_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const TodayScreen(),
    const OverviewScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: Theme.of(context).colorScheme.surface,
        color: Theme.of(context).colorScheme.onSurface,
        activeColor: Theme.of(context).colorScheme.primary,
        items: const [
          TabItem(icon: Icons.edit_note_outlined),
          TabItem(icon: Icons.view_agenda_outlined),
          TabItem(icon: Icons.settings_outlined),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
