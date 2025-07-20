import 'package:flutter/material.dart';
import 'package:sightway_mobile/modules/penyandang/views/penyandang_home_page.dart';
import 'package:sightway_mobile/shared/widgets/navigations/bottom_navigation.dart';

class PenyandangIndexPage extends StatefulWidget {
  const PenyandangIndexPage({super.key});

  @override
  State<PenyandangIndexPage> createState() => _PenyandangIndexPageState();
}

class _PenyandangIndexPageState extends State<PenyandangIndexPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PenyandangHomePage(),
    Center(child: Text('Pemantau Page')),
    Center(child: Text('Settings Page')),
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
        // ⬅️ Ini penting!
        child: BottomNavbar(
          role: "penyandang",
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
