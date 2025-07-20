import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/colors.dart';

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

  List<Map<String, dynamic>> _buildDestinations() {
    if (role == 'penyandang') {
      return [
        {'icon': Icons.home, 'label': 'Home'},
        {'icon': Icons.groups, 'label': 'Pemantau'},
        {'icon': Icons.settings, 'label': 'Settings'},
      ];
    } else if (role == 'pemantau') {
      return [
        {'icon': Icons.home, 'label': 'Home'},
        {'icon': Icons.person, 'label': 'Penyandang'},
        {'icon': Icons.settings, 'label': 'Settings'},
      ];
    } else {
      return [
        {'icon': Icons.home, 'label': 'Home'},
        {'icon': Icons.settings, 'label': 'Settings'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations();

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(destinations.length, (index) {
          final isSelected = index == currentIndex;
          final data = destinations[index];
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(
                    data['icon'],
                    color: isSelected ? AppColors.background : AppColors.text,
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        data['label'],
                        style: const TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
