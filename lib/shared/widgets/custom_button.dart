import 'package:flutter/material.dart';

/// [CustomButton] is a wrapper around Flutter's ElevatedButton.
///
/// By creating this widget, you ensure that every button in your app
/// has the same "look and feel" (borderRadius, elevation, etc.)
/// without copying the styling code 50 times.
class CustomButton extends StatelessWidget {
  // The function to run when clicked. If null, the button is automatically disabled.
  final VoidCallback? onPressed;

  // Usually a Text widget, but could be a Row with an Icon or a Spinner.
  final Widget child;

  // Optional parameters allow for specific variations (e.g., a Red "Delete" button).
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50, // Default height set to 50 for consistency
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,

      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
          elevation: 2,
        ),
        child: child,
      ),
    );
  }
}
