import 'package:flutter/material.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';

class CustomCheckBoxGroupEmociones extends StatefulWidget {
  final String title;
  final Emociones grupoEmociones;

  const CustomCheckBoxGroupEmociones({
    super.key,
    required this.title,
    required this.grupoEmociones,
  });

  @override
  State<CustomCheckBoxGroupEmociones> createState() =>
      _CustomCheckBoxGroupEmocionesState();
}

class _CustomCheckBoxGroupEmocionesState
    extends State<CustomCheckBoxGroupEmociones> {
  String? _validate() {
    final selected = widget.grupoEmociones.seleccionEmociones.any(
      (value) => value,
    );
    final intensity = widget.grupoEmociones.porcentajeCreenciaAntes ?? 0;
    if (selected && intensity == 0) {
      return 'Indica una intensidad mayor que 0 para esta emoción.';
    }
    if (!selected && intensity > 0) {
      return 'Selecciona al menos una emoción o lleva la intensidad a 0.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = widget.grupoEmociones.seleccionEmociones
        .where((selected) => selected)
        .length;
    final intensity = widget.grupoEmociones.porcentajeCreenciaAntes ?? 0;

    return FormField<bool>(
      initialValue: true,
      validator: (_) => _validate(),
      builder: (field) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: field.hasError
                  ? theme.colorScheme.error
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedCount > 0
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                selectedCount > 0
                    ? Icons.check_rounded
                    : Icons.favorite_border_rounded,
                color: selectedCount > 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(widget.title, style: theme.textTheme.titleSmall),
            subtitle: Text(
              selectedCount == 0
                  ? 'Sin seleccionar'
                  : '$selectedCount seleccionada${selectedCount == 1 ? '' : 's'} · $intensity%',
            ),
            children: [
              for (
                int i = 0;
                i < widget.grupoEmociones.listaEmociones.length;
                i++
              )
                CheckboxListTile(
                  title: Text(widget.grupoEmociones.listaEmociones[i]),
                  value: widget.grupoEmociones.seleccionEmociones[i],
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.grupoEmociones.seleccionEmociones[i] =
                          value ?? false;
                    });
                    field.didChange(!field.value!);
                  },
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Intensidad inicial',
                          style: theme.textTheme.labelLarge,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$intensity%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: intensity.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$intensity%',
                      onChanged: (value) {
                        setState(() {
                          widget.grupoEmociones.porcentajeCreenciaAntes = value
                              .round();
                        });
                        field.didChange(!field.value!);
                      },
                    ),
                    if (field.errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          field.errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
