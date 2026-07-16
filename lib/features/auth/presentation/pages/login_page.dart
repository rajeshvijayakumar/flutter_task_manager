

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/providers/auth_provider.dart';
import 'package:flutter_task_manager/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_task_manager/shared/widgets/custom_button.dart';
import 'package:flutter_task_manager/shared/widgets/custom_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {

  // Controllers to capture text input from the user
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // A key to uniquely identify the form and perform validation
  final _formKey = GlobalKey<FormState>();

  // Local state variables for handling UI feedback
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    // Memory Management: Always dispose controllers when the widget is destroyed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// The main logic for handling the login button press.
  void _login() async {

    // 1. Validate Form: Check if email/password meet the basic requirements
    if (!_formKey.currentState!.validate()) return;

    // 2. Start Loading: Update UI to show the spinner and hide old errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try{
      // 3. Trigger Controller: Call the login method in the AuthController
      await ref
      .read(authProvider.notifier)
      .login(_emailController.text.trim(), _passwordController.text.trim());

       // 4. Navigation: If login is successful, move the user to the Home/Task page.
      // pushNamedAndRemoveUntil ensures the user cannot press "back" to return to login.
      if (mounted) {
        final user = ref.read(authProvider).value;
        if (user != null) {
          log("Manual Navigation Triggered for ${user.name}");
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    }catch(e){

      // 5. Error Handling: If the repository throws an error (e.g., Wrong Password),
      // we catch it here and display it in our red Error Card.
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    } finally {
      // 6. Cleanup: Ensure the loading spinner stops regardless of success or failure
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Login'), elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding:  EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Links the form to our validation key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 Icon(Icons.task_alt, size: 100, color: Colors.blue),
                 SizedBox(height: 16),
                 Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                 const SizedBox(height: 32),

                // Error Card: Only displays if there is an active error message
                if (_errorMessage != null) _buildErrorCard(),

                 CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                 const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 4)
                      ? 'Password too short'
                      : null,
                ),
                 const SizedBox(height: 24),

                // Login Button: Disables itself while loading to prevent double-clicks
                CustomButton(
                  backgroundColor: Colors.blue,
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ?  SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      :  Text('Login', style: TextStyle(fontSize: 16)),
                ),

                 const SizedBox(height: 16),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// UI Helper: Builds a stylized red card to show error messages clearly.
  Widget _buildErrorCard() {
    return Container(
      padding:  const EdgeInsets.all(12),
      margin:  const EdgeInsets.only(bottom: 20),
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
              style:  TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon:  Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  /// UI Helper: Builds the link to navigate to the Registration page.
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         const Text("Don't have an account?"),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          ),
          child:  Text(
            'Register',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}