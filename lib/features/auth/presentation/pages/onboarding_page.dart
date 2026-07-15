

import 'package:flutter/material.dart';
import 'package:flutter_task_manager/features/auth/presentation/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              const Icon(Icons.task_alt, size: 100, color: Colors.blue),
              const SizedBox(height: 40),

              const Text(
                  'Welcome to Task Manager',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              const Text(
                'Organize your tasks efficiently and boost your productivity',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setBool('has_seen_onboarding', true);

                    if(context.mounted) {
                      Navigator.pushReplacement(context,
                       MaterialPageRoute(builder: (context) => RegisterPage())
                       );
                    }
                  },
                  child: const Text('Get Started'),
                ),
              )
          ],
        ),),
    );
  }
}