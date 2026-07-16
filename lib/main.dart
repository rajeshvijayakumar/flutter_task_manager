import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_task_manager/app/app.dart';
import 'package:flutter_task_manager/app/theme/app_theme.dart';
import 'package:flutter_task_manager/core/providers/theme_provider.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final themeMode = ref.watch(
      themeProvider.select((state) => state.themeMode)
    );

    return MaterialApp(
      title: "Task manager",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: themeMode,
      home: const Center(
        child: App(),
      ),

    );
  }
  
}
