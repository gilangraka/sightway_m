import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final String role;
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  });

  List<NavigationDestination> _buildDestinations() {
    if (role == 'penyandang') {
      return const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.groups), label: 'Pemantau'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else if (role == 'pemantau') {
      return const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Penyandang'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ];
    } else {
      return const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: _buildDestinations(),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    );
  }
}
