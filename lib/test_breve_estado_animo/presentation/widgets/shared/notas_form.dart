import 'package:flutter/material.dart';
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';

class NotasForm extends StatefulWidget {
  final TestBreveEstadoDeAnimo testBreveEstadoDeAnimo;

  const NotasForm(this.testBreveEstadoDeAnimo, {super.key});

  @override
  State<NotasForm> createState() => _NotasFormState();
}

class _NotasFormState extends State<NotasForm> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.testBreveEstadoDeAnimo.notas ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant NotasForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentNotes = widget.testBreveEstadoDeAnimo.notas ?? '';
    if (_controller.text != currentNotes) {
      _controller.text = currentNotes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
      color: primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        const SizedBox(height: 10),
        Text("Notas (opcional)", style: titleStyle),
        const SizedBox(height: 10),

        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          focusNode: _focusNode,
          onTapOutside: (event) {
            _focusNode.unfocus();
          },
          decoration: const InputDecoration(
            labelText: 'Añade tu nota aquí',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.testBreveEstadoDeAnimo.notas = value,
        ),

        const SizedBox(height: 10),

        const Divider(),
      ],
    );
  }
}
