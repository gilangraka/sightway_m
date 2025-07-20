import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final IconData icon;
  final String placeholder;
  final bool isPassword;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.icon,
    required this.placeholder,
    this.isPassword = false,
    this.controller,
    this.onChanged,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon),
        hintText: widget.placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}
