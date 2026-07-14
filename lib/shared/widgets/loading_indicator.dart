import 'package:flutter/material.dart';

/// [LoadingIndicator] is a standardized loading screen used across the app.
///
class LoadingIndicator extends StatelessWidget {
  // An optional message like "Logging in..." or "Saving Task..."
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers the content vertically
        children: [
          // The standard material design spinning circle
          CircularProgressIndicator(),

          // Using the "Spread Operator" (...) to conditionally add widgets to the list.
          // This only adds the text and spacing if a message was actually provided.
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
