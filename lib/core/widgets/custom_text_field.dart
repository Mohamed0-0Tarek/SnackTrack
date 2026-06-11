import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure      = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      validator:    validator,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText:    hint,
        prefixIcon:  prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        filled:      true,
        fillColor:   scheme.surface,
        border:      OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
