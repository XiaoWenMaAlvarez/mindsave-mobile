import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindsave/config/theme/app_theme.dart';
import 'package:mindsave/auth/presentation/providers/auth_provider.dart';
import 'package:mindsave/home/infrastructure/services/services.dart';

class ThemeNotifier extends Notifier<AppTheme> {
  late LocalStorageService _localStorageService;

  @override
  AppTheme build() {
    _localStorageService = ref.watch(localStorageServiceProvider);
    return const AppTheme();
  }

  Future<void> getDarkModeFromLocalStorage() async {
    final bool? isDarkMode = await _localStorageService.getValue<bool>(
      "isDarkMode",
    );
    state = state.copyWith(isDarkMode: isDarkMode ?? false);
  }

  Future<void> toggleDarkMode() async {
    final nextIsDarkMode = !state.isDarkMode;
    await _localStorageService.setKeyValue<bool>("isDarkMode", nextIsDarkMode);
    state = state.copyWith(isDarkMode: nextIsDarkMode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppTheme>(
  ThemeNotifier.new,
);
