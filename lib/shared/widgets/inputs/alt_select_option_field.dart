import 'package:flutter/material.dart';
import 'package:sightway_mobile/shared/constants/const.dart';

class AltSelectOptionField extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final void Function(String) onChanged;

  const AltSelectOptionField({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  IconData _getIcon(String role) {
    switch (role.toLowerCase()) {
      case 'penyandang':
        return Icons.person;
      case 'pemantau':
        return Icons.supervisor_account;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedValue == option;

        return GestureDetector(
          onTap: () => onChanged(option),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(_getIcon(option), size: 28, color: AppColors.text),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
