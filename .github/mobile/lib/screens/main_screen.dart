import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'publish/publish_screen.dart';
import 'settings/settings_screen.dart';
import 'tutorial/tutorial_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PublishScreen(),
    SettingsScreen(),
    TutorialScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'dashboard'),
    _NavItem(icon: Icons.rocket_launch_rounded, label: 'publish'),
    _NavItem(icon: Icons.settings_rounded, label: 'settings'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'tutorial'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: IndexedStack(
          key: ValueKey(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDim, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == _currentIndex;
              return _buildNavItem(item, selected, () => setState(() => _currentIndex = i));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.purpleGradient : null,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: selected ? Colors.white : AppColors.textDim,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: selected ? AppColors.accentPurple : AppColors.textDim,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}