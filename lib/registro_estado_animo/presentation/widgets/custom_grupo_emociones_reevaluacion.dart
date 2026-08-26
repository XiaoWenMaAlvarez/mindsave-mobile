import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class CustomGrupoEmocionesReevaluacion extends StatefulWidget {
  const CustomGrupoEmocionesReevaluacion({
    super.key,
    required this.title,
    required this.grupoEmociones,
    required this.formKey,
    this.emoji = '💭',
    this.onChanged,
  });

  final String title;
  final String emoji;
  final Emociones grupoEmociones;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onChanged;

  @override
  State<CustomGrupoEmocionesReevaluacion> createState() =>
      _CustomGrupoEmocionesReevaluacionState();
}

class _CustomGrupoEmocionesReevaluacionState
    extends State<CustomGrupoEmocionesReevaluacion> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.grupoEmociones.porcentajeCreenciaDespues?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedEmotions(widget.grupoEmociones);
    if (selected.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final before = widget.grupoEmociones.porcentajeCreenciaAntes ?? 0;
    final after = widget.grupoEmociones.porcentajeCreenciaDespues;
    final improvement = after == null ? null : before - after;
    final success = theme.brightness == Brightness.dark
        ? const Color(0xFF73D99A)
        : const Color(0xFF247A4A);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(
                          selected.join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _IntensityValue(
                      label: 'ANTES',
                      value: '$before%',
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 27),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'DESPUÉS',
                        suffixText: '%',
                        hintText: 'Ej. 30',
                      ),
                      validator: validarPorcentajeEmocion,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        setState(() {
                          widget.grupoEmociones.porcentajeCreenciaDespues =
                              parsed != null && parsed <= 100 ? parsed : null;
                        });
                        widget.onChanged?.call();
                      },
                    ),
                  ),
                ],
              ),
              if (improvement != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: (improvement >= 0 ? success : colors.tertiary)
                        .withAlpha(24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        improvement >= 0
                            ? Icons.south_rounded
                            : Icons.north_rounded,
                        size: 18,
                        color: improvement >= 0 ? success : colors.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          improvement >= 0
                              ? 'Redujo $improvement% · Buen progreso'
                              : 'Aumentó ${improvement.abs()}% · Sigue observando',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: improvement >= 0 ? success : colors.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityValue extends StatelessWidget {
  const _IntensityValue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 7),
        Text(value, style: theme.textTheme.headlineSmall),
      ],
    );
  }
}

List<String> _selectedEmotions(Emociones group) {
  final selected = <String>[];
  for (var index = 0; index < group.listaEmociones.length; index++) {
    if (index < group.seleccionEmociones.length &&
        group.seleccionEmociones[index]) {
      selected.add(group.listaEmociones[index]);
    }
  }
  return selected;
}

String? validarPorcentajeEmocion(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo es obligatorio';
  }
  final number = int.tryParse(value);
  if (number == null) return 'Ingresa un número entero';
  if (number < 0 || number > 100) return 'Debe estar entre 0 y 100';
  return null;
}
