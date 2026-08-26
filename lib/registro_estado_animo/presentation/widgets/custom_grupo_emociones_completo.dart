import 'package:flutter/material.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class CustomGrupoEmocionesCompleto extends StatelessWidget {
  const CustomGrupoEmocionesCompleto({
    super.key,
    required this.title,
    required this.grupoEmociones,
    this.emoji = '💭',
  });

  final String title;
  final String emoji;
  final Emociones grupoEmociones;

  @override
  Widget build(BuildContext context) {
    final selected = <String>[];
    for (var index = 0; index < grupoEmociones.listaEmociones.length; index++) {
      if (index < grupoEmociones.seleccionEmociones.length &&
          grupoEmociones.seleccionEmociones[index]) {
        selected.add(grupoEmociones.listaEmociones[index]);
      }
    }
    if (selected.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final success = theme.brightness == Brightness.dark
        ? const Color(0xFF73D99A)
        : const Color(0xFF247A4A);
    final before = grupoEmociones.porcentajeCreenciaAntes ?? 0;
    final after = grupoEmociones.porcentajeCreenciaDespues ?? 0;
    final difference = before - after;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    selected.join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 9,
                    runSpacing: 6,
                    children: [
                      Text('$before%', style: theme.textTheme.titleMedium),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      Text(
                        '$after%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: difference >= 0 ? success : colors.tertiary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (difference >= 0 ? success : colors.tertiary)
                              .withAlpha(24),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          difference >= 0
                              ? '↓ $difference puntos'
                              : '↑ ${difference.abs()} puntos',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: difference >= 0 ? success : colors.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
