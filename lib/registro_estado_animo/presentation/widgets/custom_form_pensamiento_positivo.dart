import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class CustomFormPensamientoPositivo extends StatefulWidget {
  const CustomFormPensamientoPositivo({
    super.key,
    required this.title,
    required this.pensamiento,
    required this.formKey,
  });

  final String title;
  final Pensamiento pensamiento;
  final GlobalKey<FormState> formKey;

  @override
  State<CustomFormPensamientoPositivo> createState() =>
      _CustomFormPensamientoPositivoState();
}

class _CustomFormPensamientoPositivoState
    extends State<CustomFormPensamientoPositivo> {
  late final TextEditingController _positiveThoughtController;
  late final TextEditingController _positiveBeliefController;
  late final TextEditingController _negativeBeliefController;

  @override
  void initState() {
    super.initState();
    _positiveThoughtController = TextEditingController(
      text: widget.pensamiento.pensamientoPositivo ?? '',
    );
    _positiveBeliefController = TextEditingController(
      text: widget.pensamiento.porcentajeCreenciaPositivo?.toString() ?? '',
    );
    _negativeBeliefController = TextEditingController(
      text: widget.pensamiento.porcentajeCreenciaDespues?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _positiveThoughtController.dispose();
    _positiveBeliefController.dispose();
    _negativeBeliefController.dispose();
    super.dispose();
  }

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
        index < widget.pensamiento.distorsion.length &&
            index < Pensamiento.listaDistorsiones.length;
        index++
      )
        if (widget.pensamiento.distorsion[index])
          Pensamiento.listaDistorsiones[index],
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: widget.formKey,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withAlpha(75),
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(color: colors.error, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENSAMIENTO NEGATIVO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .9,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      widget.pensamiento.pensamientoNegativo,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (distortions.isEmpty)
                      Text(
                        'Sin distorsiones seleccionadas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          for (final distortion in distortions)
                            Chip(
                              avatar: Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: colors.error,
                              ),
                              label: Text(distortion),
                              side: BorderSide(
                                color: colors.error.withAlpha(90),
                              ),
                              backgroundColor: colors.errorContainer.withAlpha(
                                35,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'PENSAMIENTO ALTERNATIVO POSITIVO',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: success,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 9),
              TextFormField(
                controller: _positiveThoughtController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ej. Puedo aprender de esto y pedir apoyo…',
                  alignLabelWithHint: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: success.withAlpha(150)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: success, width: 2),
                  ),
                ),
                validator: isValidoPensamientoPositivo,
                onChanged: (value) =>
                    widget.pensamiento.pensamientoPositivo = value,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final fields = [
                    _BeliefField(
                      label: 'Creencia pensamiento positivo',
                      controller: _positiveBeliefController,
                      color: success,
                      validator: validarPorcentajePensamientoPositivo,
                      onChanged: (value) {
                        if (validarPorcentajePensamientoPositivo(value) ==
                            null) {
                          widget.pensamiento.porcentajeCreenciaPositivo =
                              int.parse(value);
                        }
                      },
                    ),
                    _BeliefField(
                      label: 'Creencia pensamiento negativo',
                      controller: _negativeBeliefController,
                      color: colors.error,
                      validator: validarPorcentajePensamientoNegativo,
                      onChanged: (value) {
                        if (validarPorcentajePensamientoNegativo(value) ==
                            null) {
                          widget.pensamiento.porcentajeCreenciaDespues =
                              int.parse(value);
                        }
                      },
                    ),
                  ];
                  return Column(
                    children: [
                      fields.first,
                      const SizedBox(height: 12),
                      fields.last,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BeliefField extends StatelessWidget {
  const _BeliefField({
    required this.label,
    required this.controller,
    required this.color,
    required this.validator,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final Color color;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
        prefixIcon: Icon(Icons.percent_rounded, color: color),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color.withAlpha(120)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

String? validarPorcentajePensamientoNegativo(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo es obligatorio';
  }
  final numberValue = int.tryParse(value);
  if (numberValue == null) return 'Ingresa un número entero';
  if (numberValue < 0 || numberValue > 100) {
    return 'Debe estar entre 0 y 100';
  }
  return null;
}

String? validarPorcentajePensamientoPositivo(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo es obligatorio';
  }
  final numberValue = int.tryParse(value);
  if (numberValue == null) return 'Ingresa un número entero';
  if (numberValue <= 0 || numberValue > 100) {
    return 'Debe estar entre 1 y 100';
  }
  return null;
}

String? isValidoPensamientoPositivo(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Escribe un pensamiento alternativo';
  }
  return null;
}
