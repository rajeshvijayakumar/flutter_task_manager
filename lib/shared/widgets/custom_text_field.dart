import 'package:flutter/material.dart';

/// [CustomTextField] is a reusable input component.
///
/// By wrapping TextFormField, you ensure that every text input in your app
/// (Email, Password, Task Title) has the same border radius, padding, and colors.
class CustomTextField extends StatelessWidget {
  // The controller that actually holds the text value
  final TextEditingController controller;

  // The text shown inside the field (e.g., "Enter your email")
  final String label;

  // Optional icon at the start of the field
  final IconData? prefixIcon;

  // Set to 'true' for passwords to hide characters
  final bool obscureText;

  // Validation logic (e.g., check if email contains '@')
  final String? Function(String?)? validator;

  // Changes the keyboard (e.g., shows the "@" symbol for emails)
  final TextInputType? keyboardType;

  // Controls the height. 1 for standard fields, 3+ for descriptions.
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
