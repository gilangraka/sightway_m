import 'package:flutter/material.dart';

class CustomSelectField extends StatelessWidget {
  final IconData icon;
  final String placeholder;
  final List<String> options;
  final String? selectedValue;
  final void Function(String?)? onChanged;

  const CustomSelectField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.options,
    this.selectedValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options.map((option) {
        return DropdownMenuItem(value: option, child: Text(option));
      }).toList(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: onChanged,
    );
  }
}
