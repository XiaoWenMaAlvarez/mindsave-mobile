import 'package:flutter/material.dart';
import 'package:prueba/shared/presentation/widgets/mindsave_ui.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentIndex == 0 ? -1 : 1;
    return MindsaveBottomNavigation(currentIndex: selectedIndex);
  }
}
