import 'package:flutter/material.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';
import 'package:prueba/registro_estado_animo/presentation/widgets/widgets.dart';

class RegistroEstadoAnimoPaso3 extends StatefulWidget {
  final RegistroEstadoAnimo registroEstadoAnimo;
  final GlobalKey<FormState> formKey;

  const RegistroEstadoAnimoPaso3(
    this.registroEstadoAnimo,
    this.formKey, {
    super.key,
  });

  @override
  State<RegistroEstadoAnimoPaso3> createState() =>
      _RegistroEstadoAnimoPaso3State();
}

class _RegistroEstadoAnimoPaso3State extends State<RegistroEstadoAnimoPaso3> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.psychology_alt_outlined,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pensamientos automáticos',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Registra las frases o imágenes que aparecieron en tu mente durante la situación.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withAlpha(75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primary.withAlpha(45)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 22,
                  color: colors.primary,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escríbelo tal como apareció',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No necesitas corregirlo ni juzgarlo. Después podrás analizarlo con más distancia.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '¿Cuánto creíste en cada pensamiento?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            'Usa la escala desde 1% (casi nada) hasta 100% (completamente).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          PensamientosNegativosGroup(
            pensamientos: widget.registroEstadoAnimo.listaPensamientos,
            formKey: widget.formKey,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
