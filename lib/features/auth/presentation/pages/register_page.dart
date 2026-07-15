import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/models/user.dart';
import 'package:flutter_task_manager/core/providers/auth_provider.dart';
import 'package:flutter_task_manager/shared/widgets/custom_button.dart';
import 'package:flutter_task_manager/shared/widgets/custom_text_field.dart';
import 'package:flutter_task_manager/shared/widgets/loading_indicator.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // Controllers to manage and retrieve text from input fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // A GlobalKey to validate all fields in the Form at once
  final _formKey = GlobalKey<FormState>();

  // Local state for UI feedback (Error messages and loading spinners)
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers when the widget is removed to save memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Logic to process registration
  void _register() async {
    // 1. Validation: Check if all FormFields pass their 'validator' logic
    if (!_formKey.currentState!.validate()) return;

    // 2. Loading State: Update UI to show progress
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 3. Remote Action: Call the AuthController to save the user to SharedPreferences
      await ref
          .read(authProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      // 4. Navigation on Success:
      if (mounted) {
        // 'pushAndRemoveUntil' wipes the navigation history.
        // This prevents the user from accidentally "backing" into the registration page after success.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Placeholder()),
          (route) => false,
        );

        // Notify the user of success via a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Please Login'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen allows us to react to state changes without rebuilding the whole widget.
    // Here we listen for any unexpected global errors in the authProvider.
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          setState(() {
            _errorMessage = error.toString();
            _isLoading = false;
          });
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Connects the GlobalKey to the Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Join Us',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Error UI: Only appears if an error occurs
                if (_errorMessage != null) _buildErrorCard(),

                // Form Fields with individual validation logic
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Enter your name'
                      : null,
                ),

                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  validator: (value) =>
                      (value == null || value.isEmpty || !value.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),

                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  validator: (value) =>
                      (value == null || value.isEmpty || value.length < 6)
                      ? 'Minimum six characters'
                      : null,
                ),

                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_reset,
                  validator: (value) {
                    if (value != _passwordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),
            
                // Register Button: Switches to a spinner during the async operation
                CustomButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// UI Helper: Displays error messages in a consistent style
  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  /// Navigation Helper: Takes user back to the Login screen
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? '),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
