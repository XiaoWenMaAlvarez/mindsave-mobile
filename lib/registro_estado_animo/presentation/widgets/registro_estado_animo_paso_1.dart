import 'package:flutter/material.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class RegistroEstadoAnimoPaso1 extends StatefulWidget {
  final RegistroEstadoAnimo registroEstadoAnimo;
  final GlobalKey<FormState> formKey;

  const RegistroEstadoAnimoPaso1(
    this.registroEstadoAnimo,
    this.formKey, {
    super.key,
  });

  @override
  State<RegistroEstadoAnimoPaso1> createState() =>
      _RegistroEstadoAnimoPaso1State();
}

class _RegistroEstadoAnimoPaso1State extends State<RegistroEstadoAnimoPaso1> {
  late TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    _controller = TextEditingController(
      text: widget.registroEstadoAnimo.sucesoTrastornador,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleMedium;

    TextStyle bodyStyle = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Fecha del suceso", style: titleStyle),
            ),
            const SizedBox(height: 10),
            Text(
              "Indica cuándo ocurrió. Si fue hoy, no necesitas cambiarla.",
              style: bodyStyle,
            ),
            const SizedBox(height: 15),
            DatePicker(widget.registroEstadoAnimo),
            const SizedBox(height: 15),
            Text(
              "Describe brevemente qué ocurrió y qué hizo difícil ese momento.",
              style: bodyStyle,
            ),
            const SizedBox(height: 15),
            TextFormField(
              focusNode: _focusNode,
              onTapOutside: (event) {
                _focusNode.unfocus();
              },
              controller: _controller,
              maxLines: null,
              minLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ej. Tuve una conversación difícil en el trabajo…',
                alignLabelWithHint: true,
              ),
              onChanged: (String? value) =>
                  widget.registroEstadoAnimo.sucesoTrastornador = value ?? "",
              validator: (String? value) {
                if (value == null || value.trim() == "") {
                  return "El campo es obligatorio";
                }
                return null;
              },
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  final RegistroEstadoAnimo registroEstadoAnimo;

  const DatePicker(this.registroEstadoAnimo, {super.key});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final _fechaController = TextEditingController();
  DateTime? selectedDate;

  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.registroEstadoAnimo.fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;
    setState(() {
      selectedDate = pickedDate;
      _fechaController.text =
          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      widget.registroEstadoAnimo.fecha = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedDate = widget.registroEstadoAnimo.fecha;
    _fechaController.text =
        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    return TextFormField(
      controller: _fechaController,
      readOnly: true,
      onTap: _selectDate,
      decoration: const InputDecoration(
        labelText: 'Fecha seleccionada',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
    );
  }
}
