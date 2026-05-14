import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    const ProviderScope(child: PomegranateDetectorApp()),
  );
}

final class PomegranateDetectorApp extends StatelessWidget {
  const PomegranateDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PomeScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const SplashPage(),
    );
  }
}
