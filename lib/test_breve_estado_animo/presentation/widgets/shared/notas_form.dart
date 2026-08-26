import 'package:flutter/material.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';

class NotasForm extends StatefulWidget {
  final TestBreveEstadoDeAnimo testBreveEstadoDeAnimo;

  const NotasForm(this.testBreveEstadoDeAnimo, {super.key});

  @override
  State<NotasForm> createState() => _NotasFormState();
}

class _NotasFormState extends State<NotasForm> {
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

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
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          focusNode: focusNode,
          onTapOutside: (event) {
            focusNode.unfocus();
          },
          decoration: InputDecoration(
            labelText: 'Añade tu nota aquí',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.testBreveEstadoDeAnimo.notas = value,
        ),

        SizedBox(height: 10),

        Divider(),
      ],
    );
  }
}
