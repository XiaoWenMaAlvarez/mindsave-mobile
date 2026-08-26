import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  final String title;
  final int groupValue;
  final Function(int?) onChanged;
  final int minValue;
  final int maxValue;
  final List<String> labels;

  const CustomRadioButton({
    super.key,
    required this.title,
    required this.groupValue,
    required this.onChanged,
    required this.minValue,
    required this.maxValue,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = [for (int i = minValue; i <= maxValue; i++) i];
    final selectedLabel = groupValue >= 0 && groupValue < labels.length
        ? labels[groupValue]
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int index = 0; index < values.length; index++) ...[
                if (index > 0) const SizedBox(width: 7),
                Expanded(
                  child: _ScoreChoice(
                    value: values[index],
                    label: values[index] < labels.length
                        ? labels[values[index]]
                        : '${values[index]}',
                    selected: groupValue == values[index],
                    onTap: () => onChanged(values[index]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 9),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              '$groupValue · $selectedLabel',
              key: ValueKey(groupValue),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChoice extends StatelessWidget {
  final int value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScoreChoice({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$value, $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
