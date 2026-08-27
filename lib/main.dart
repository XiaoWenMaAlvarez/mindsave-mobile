import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindsave/config/router/app_router.dart';
import 'package:mindsave/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/home/presentation/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(themeProvider.notifier).getDarkModeFromLocalStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme appTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Mindsave',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(goRouterProvider),
      theme: appTheme.getTheme(),
    );
  }
}
