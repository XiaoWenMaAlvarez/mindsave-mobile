import 'package:flutter/material.dart';
import 'package:mindsave/registro_estado_animo/domain/entities/entities.dart';

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
  late final TextEditingController _fechaController;

  @override
  void initState() {
    super.initState();
    _fechaController = TextEditingController(
      text: _formattedDate(widget.registroEstadoAnimo.fecha),
    );
  }

  @override
  void didUpdateWidget(covariant DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final formatted = _formattedDate(widget.registroEstadoAnimo.fecha);
    if (_fechaController.text != formatted) {
      _fechaController.text = formatted;
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }

  String _formattedDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = widget.registroEstadoAnimo.fecha.isAfter(now)
        ? now
        : widget.registroEstadoAnimo.fecha;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (!mounted) return;
    if (pickedDate == null) return;
    setState(() {
      _fechaController.text = _formattedDate(pickedDate);
      widget.registroEstadoAnimo.fecha = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
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
