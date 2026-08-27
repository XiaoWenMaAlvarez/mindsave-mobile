import 'package:flutter/material.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';

class PensamientosNegativosGroup extends StatefulWidget {
  final List<Pensamiento> pensamientos;
  final GlobalKey<FormState> formKey;

  const PensamientosNegativosGroup({
    super.key,
    required this.pensamientos,
    required this.formKey,
  });

  @override
  State<PensamientosNegativosGroup> createState() =>
      _PensamientosNegativosGroupState();
}

class _PensamientosNegativosGroupState
    extends State<PensamientosNegativosGroup> {
  final _newThoughtFormKey = GlobalKey<FormState>();
  final _newThoughtController = TextEditingController();

  @override
  void dispose() {
    _newThoughtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: widget.formKey,
          child: Column(
            children: [
              for (int i = 0; i < widget.pensamientos.length; i++) ...[
                Container(
                  key: ObjectKey(widget.pensamientos[i]),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pensamiento ${i + 1}',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Eliminar pensamiento',
                            onPressed: () => _removeThought(i),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: ValueKey(widget.pensamientos[i]),
                        initialValue:
                            widget.pensamientos[i].pensamientoNegativo,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Pensamiento automático',
                          hintText: 'Ej. No puedo permitirme fallar otra vez',
                          alignLabelWithHint: true,
                        ),
                        onChanged: (value) =>
                            widget.pensamientos[i].pensamientoNegativo = value,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Escribe el pensamiento antes de continuar.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '¿Cuánto lo creíste?',
                            style: theme.textTheme.labelLarge,
                          ),
                          const Spacer(),
                          Text(
                            '${widget.pensamientos[i].porcentajeCreenciaAntes}%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label:
                            '${widget.pensamientos[i].porcentajeCreenciaAntes}%',
                        value: widget.pensamientos[i].porcentajeCreenciaAntes
                            .clamp(1, 100)
                            .toDouble(),
                        onChanged: (value) => setState(() {
                          widget.pensamientos[i].porcentajeCreenciaAntes = value
                              .round();
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        Form(
          key: _newThoughtFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Agregar pensamiento', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newThoughtController,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Escribe la frase tal como apareció en tu mente…',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe un pensamiento para agregarlo.'
                    : null,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _addThought,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar a la lista'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addThought() {
    if (_newThoughtFormKey.currentState?.validate() != true) return;
    setState(() {
      widget.pensamientos.add(
        Pensamiento(
          pensamientoNegativo: _newThoughtController.text.trim(),
          porcentajeCreenciaAntes: 50,
        ),
      );
      _newThoughtController.clear();
      _newThoughtFormKey.currentState?.reset();
    });
  }

  Future<void> _removeThought(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar pensamiento'),
        content: const Text('¿Quieres quitar este pensamiento del registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      setState(() => widget.pensamientos.removeAt(index));
    }
  }
}
