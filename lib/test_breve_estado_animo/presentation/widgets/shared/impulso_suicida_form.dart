import 'package:flutter/material.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';

class ImpulsoSuicidaForm extends StatefulWidget {
  final ImpulsoSuicidaTestBreve impulsoSuicidaTestBreve;

  const ImpulsoSuicidaForm(this.impulsoSuicidaTestBreve, {super.key});

  @override
  State<ImpulsoSuicidaForm> createState() => _ImpulsoSuicidaFormState();
}

class _ImpulsoSuicidaFormState extends State<ImpulsoSuicidaForm> {
  @override
  Widget build(BuildContext context) {
    final int minValue = ImpulsoSuicidaTestBreve.valorMin;
    final int maxValue = ImpulsoSuicidaTestBreve.valorMax;
    final List<String> labels = ImpulsoSuicidaTestBreve.etiquetaPuntuacion;

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
        Text("Impulsos Suicidas", style: titleStyle),
        const SizedBox(height: 10),

        CustomRadioButton(
          title: "¿Tiene algún pensamiento de suicidarse?",
          groupValue: widget.impulsoSuicidaTestBreve.pensamientosSuicidas,
          onChanged: (value) {
            setState(
              () => widget.impulsoSuicidaTestBreve.pensamientosSuicidas =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "¿Quisiera poner fin a su vida?",
          groupValue: widget.impulsoSuicidaTestBreve.deseosDeMorir,
          onChanged: (value) {
            setState(
              () => widget.impulsoSuicidaTestBreve.deseosDeMorir = value ?? 0,
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
              "Total de hoy: ${widget.impulsoSuicidaTestBreve.totalScore} (${widget.impulsoSuicidaTestBreve.result})",
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
