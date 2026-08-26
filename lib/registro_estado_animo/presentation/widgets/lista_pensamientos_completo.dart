import 'package:flutter/material.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class ListaPensamientosCompleto extends StatelessWidget {
  const ListaPensamientosCompleto({
    super.key,
    required this.title,
    required this.pensamiento,
  });

  final String title;
  final Pensamiento pensamiento;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final success = theme.brightness == Brightness.dark
        ? const Color(0xFF73D99A)
        : const Color(0xFF247A4A);
    final distortions = <String>[
      for (
        var index = 0;
        index < pensamiento.distorsion.length &&
            index < Pensamiento.listaDistorsiones.length;
        index++
      )
        if (pensamiento.distorsion[index]) Pensamiento.listaDistorsiones[index],
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _ThoughtBlock(
              label: 'PENSAMIENTO NEGATIVO',
              text: pensamiento.pensamientoNegativo,
              color: colors.error,
              trailing:
                  '${pensamiento.porcentajeCreenciaAntes}% → ${pensamiento.porcentajeCreenciaDespues ?? 0}%',
            ),
            if (distortions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final distortion in distortions)
                    Chip(
                      label: Text(distortion),
                      side: BorderSide(color: colors.error.withAlpha(80)),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _ThoughtBlock(
              label: 'PENSAMIENTO ALTERNATIVO',
              text: pensamiento.pensamientoPositivo ?? 'Sin alternativa',
              color: success,
              trailing: '${pensamiento.porcentajeCreenciaPositivo ?? 0}%',
            ),
          ],
        ),
      ),
    );
  }
}

class _ThoughtBlock extends StatelessWidget {
  const _ThoughtBlock({
    required this.label,
    required this.text,
    required this.color,
    required this.trailing,
  });

  final String label;
  final String text;
  final Color color;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ),
              Text(
                trailing,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
