import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/pemantau/views/pemantau_home_page.dart';
import 'package:sightway_mobile/modules/pemantau/views/pemantau_settings_page.dart';
import 'package:sightway_mobile/modules/pemantau/views/pemantau_penyandang_page.dart';
import 'package:sightway_mobile/shared/widgets/navigations/bottom_navigation.dart';

class PemantauIndexPage extends StatefulWidget {
  const PemantauIndexPage({super.key});

  @override
  State<PemantauIndexPage> createState() => _PemantauIndexPageState();
}

class _PemantauIndexPageState extends State<PemantauIndexPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PemantauHomePage(),
    const PemantauPenyandangPage(),
    const PemantauSettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: BottomNavbar(
          role: "pemantau",
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
