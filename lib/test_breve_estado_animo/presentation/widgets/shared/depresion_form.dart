import 'package:flutter/material.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';

class DepresionForm extends StatefulWidget {
  final DepresionTestBreve depresionTestBreve;

  const DepresionForm(this.depresionTestBreve, {super.key});

  @override
  State<DepresionForm> createState() => _DepresionFormState();
}

class _DepresionFormState extends State<DepresionForm> {
  @override
  Widget build(BuildContext context) {
    final int minValue = DepresionTestBreve.valorMin;
    final int maxValue = DepresionTestBreve.valorMax;
    final List<String> labels = DepresionTestBreve.etiquetaPuntuacion;

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
      color: primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    TextStyle boldBodyStyle = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontSize: 16, fontWeight: FontWeight.bold);

    return Column(
      children: [
        const SizedBox(height: 10),
        Text("Depresión", style: titleStyle),
        const SizedBox(height: 10),

        CustomRadioButton(
          title: "Triste o decaído",
          groupValue: widget.depresionTestBreve.tristeza,
          onChanged: (value) {
            setState(() => widget.depresionTestBreve.tristeza = value ?? 0);
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Desanimado o desesperanzado",
          groupValue: widget.depresionTestBreve.desesperanza,
          onChanged: (value) {
            setState(() => widget.depresionTestBreve.desesperanza = value ?? 0);
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Autoestima baja",
          groupValue: widget.depresionTestBreve.bajaAutoestima,
          onChanged: (value) {
            setState(
              () => widget.depresionTestBreve.bajaAutoestima = value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Sensación de no valer o de ser inadecuado",
          groupValue: widget.depresionTestBreve.faltaDeValor,
          onChanged: (value) {
            setState(() => widget.depresionTestBreve.faltaDeValor = value ?? 0);
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Pérdida de placer o de satisfacción con la vida",
          groupValue: widget.depresionTestBreve.perdidaDeSatisfaccion,
          onChanged: (value) {
            setState(
              () =>
                  widget.depresionTestBreve.perdidaDeSatisfaccion = value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        SizedBox(height: 10),

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Total de hoy: ${widget.depresionTestBreve.totalScore} (${widget.depresionTestBreve.result})",
              style: boldBodyStyle,
            ),
          ),
        ),

        SizedBox(height: 10),

        Divider(),
      ],
    );
  }
}
