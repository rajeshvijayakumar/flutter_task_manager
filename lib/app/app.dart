
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/core/providers/auth_provider.dart';
import 'package:flutter_task_manager/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_task_manager/features/auth/presentation/pages/onboarding_page.dart';
import 'package:flutter_task_manager/features/auth/presentation/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user){
        return FutureBuilder<bool>(
          future: _hasSeenOnBoarding(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasSeenOnboarding = snapshot.data ?? false;

            if (!hasSeenOnboarding) {
              return const OnboardingPage();
            }
            
            if (user == null) {
              return const LoginPage();
            }

            //TODO: Need to navigate to Task Page
            return const RegisterPage();

          }
          );
      },

      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error:  (error, stack) {
        // Fallback to LoginPage so the user can try to re-authenticate.
        return const LoginPage();
      }
    );
  }


  Future<bool> _hasSeenOnBoarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('has_seen_onboarding') ?? false;
    } catch (e) {
      return false; // Safety fallback
    }
  }
}