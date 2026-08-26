import 'package:flutter/material.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';

class EmocionesPersonalizadasCheckBoxGroup extends StatefulWidget {
  final Emociones grupoEmociones;

  const EmocionesPersonalizadasCheckBoxGroup({
    super.key,
    required this.grupoEmociones,
  });

  @override
  State<EmocionesPersonalizadasCheckBoxGroup> createState() =>
      _EmocionesPersonalizadasCheckBoxGroupState();
}

class _EmocionesPersonalizadasCheckBoxGroupState
    extends State<EmocionesPersonalizadasCheckBoxGroup> {
  late TextEditingController _controller;
  late FocusNode _nuevaEmocionFocusNode;
  late String? _hayError;

  @override
  void initState() {
    _controller = TextEditingController(text: '');
    _nuevaEmocionFocusNode = FocusNode();
    _hayError = null;
    super.initState();
  }

  String? _validate() {
    final hasEmotions = widget.grupoEmociones.listaEmociones.isNotEmpty;
    final intensity = widget.grupoEmociones.porcentajeCreenciaAntes ?? 0;
    if (hasEmotions && intensity == 0) {
      return 'Indica una intensidad mayor que 0 para esta emoción.';
    }
    if (!hasEmotions && intensity > 0) {
      return 'Agrega una emoción o lleva la intensidad a 0.';
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nuevaEmocionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grupoEmociones = widget.grupoEmociones;
    final intensity = grupoEmociones.porcentajeCreenciaAntes ?? 0;

    bool isValidaEmocion(String? value) {
      if (value == null || value.trim() == "") {
        setState(() => _hayError = "No puede agregar una emoción vacía");
        return false;
      }
      if (grupoEmociones.listaEmociones.any(
        (String emocion) => emocion == value,
      )) {
        setState(() => _hayError = "La emoción ya está agregada");
        return false;
      }
      setState(() => _hayError = null);
      return true;
    }

    return FormField<bool>(
      initialValue: true,
      validator: (_) => _validate(),
      builder: (field) => ExpansionTile(
        title: const Text('Otras (describir)'),
        children: [
          for (int i = 0; i < grupoEmociones.listaEmociones.length; i++)
            CheckboxListTile(
              title: Text(grupoEmociones.listaEmociones[i]),
              value: grupoEmociones.seleccionEmociones[i],
              onChanged: (bool? value) {
                if (value != false) return;
                setState(() {
                  grupoEmociones.listaEmociones.removeAt(i);
                  grupoEmociones.seleccionEmociones.removeAt(i);
                  if (grupoEmociones.listaEmociones.isEmpty) {
                    grupoEmociones.porcentajeCreenciaAntes = 0;
                  }
                });
                field.didChange(!field.value!);
              },
            ),
          if (grupoEmociones.listaEmociones.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
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
                        grupoEmociones.porcentajeCreenciaAntes = value.round();
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: _controller,
              focusNode: _nuevaEmocionFocusNode,
              onTapOutside: (_) => _nuevaEmocionFocusNode.unfocus(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Agregar nueva emoción (opcional)'),
                hintText: 'Abrumado/a',
              ),
            ),
          ),
          if (_hayError != null) ...[
            const SizedBox(height: 5),
            Text(_hayError!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 5),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Agregar emoción'),
            onPressed: () {
              final emocionEscrita = _controller.text;
              if (isValidaEmocion(emocionEscrita)) {
                grupoEmociones.listaEmociones.add(emocionEscrita);
                grupoEmociones.seleccionEmociones.add(true);
                _controller.clear();
                setState(() {});
                field.didChange(!field.value!);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
