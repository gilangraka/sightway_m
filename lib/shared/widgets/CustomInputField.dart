import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final IconData icon;
  final String placeholder;
  final bool isPassword;
  final bool isSelect;
  final List<String>? options;
  final TextEditingController? controller;
  final void Function(String?)? onChanged;

  const CustomInputField({
    super.key,
    required this.icon,
    required this.placeholder,
    this.isPassword = false,
    this.isSelect = false,
    this.options,
    this.controller,
    this.onChanged,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isSelect)
          TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon),
              hintText: widget.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    )
                  : null,
            ),
            onChanged: widget.onChanged,
          )
        else
          DropdownButtonFormField<String>(
            value: selectedValue,
            items: widget.options?.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon),
              hintText: widget.placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() => selectedValue = value);
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
          ),
      ],
    );
  }
}
