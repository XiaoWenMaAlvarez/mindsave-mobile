import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w700,
    );

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset("assets/img/icon.png", fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Text('Mindsave', style: titleStyle),
          const Spacer(),
        ],
      ),
    );
  }
}
