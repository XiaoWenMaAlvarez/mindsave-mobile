import 'package:flutter/material.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';

class AnsiedadFisicaForm extends StatefulWidget {
  final SentimientosAnsiedadFisicaTestBreve sentimientosAnsiedadFisicaTestBreve;

  const AnsiedadFisicaForm(
    this.sentimientosAnsiedadFisicaTestBreve, {
    super.key,
  });

  @override
  State<AnsiedadFisicaForm> createState() => _AnsiedadFisicaFormState();
}

class _AnsiedadFisicaFormState extends State<AnsiedadFisicaForm> {
  @override
  Widget build(BuildContext context) {
    final int minValue = SentimientosAnsiedadFisicaTestBreve.valorMin;
    final int maxValue = SentimientosAnsiedadFisicaTestBreve.valorMax;
    final List<String> labels =
        SentimientosAnsiedadFisicaTestBreve.etiquetaPuntuacion;

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
        Text("Sentimientos de Ansiedad Física", style: titleStyle),
        const SizedBox(height: 10),

        CustomRadioButton(
          title: "Palpitaciones, pulso acelerado o taquicardia",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.palpitaciones,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadFisicaTestBreve.palpitaciones =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Sudores, escalofríos o sofocos",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.sudoracion,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadFisicaTestBreve.sudoracion =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Temblores o estremecimientos",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.temblores,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadFisicaTestBreve.temblores =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Falta de aliento o dificultades para respirar",
          groupValue:
              widget.sentimientosAnsiedadFisicaTestBreve.dificultadRespirar,
          onChanged: (value) {
            setState(
              () =>
                  widget
                          .sentimientosAnsiedadFisicaTestBreve
                          .dificultadRespirar =
                      value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Sensación de ahogo",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.ahogo,
          onChanged: (value) {
            setState(
              () =>
                  widget.sentimientosAnsiedadFisicaTestBreve.ahogo = value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Dolor o tensión en el pecho",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.dolorPecho,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadFisicaTestBreve.dolorPecho =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Estómago revuelto o náuseas",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.nauseas,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadFisicaTestBreve.nauseas =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Sensación de mareo o de que todo da vueltas",
          groupValue: widget.sentimientosAnsiedadFisicaTestBreve.mareos,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadFisicaTestBreve.mareos =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Sensación de que usted es irreal o de que el mundo es irreal",
          groupValue:
              widget.sentimientosAnsiedadFisicaTestBreve.sensacionIrrealidad,
          onChanged: (value) {
            setState(
              () =>
                  widget
                          .sentimientosAnsiedadFisicaTestBreve
                          .sensacionIrrealidad =
                      value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Sensación de insensibilidad o de hormigueos",
          groupValue: widget
              .sentimientosAnsiedadFisicaTestBreve
              .inestabilidadHormigueos,
          onChanged: (value) {
            setState(
              () =>
                  widget
                          .sentimientosAnsiedadFisicaTestBreve
                          .inestabilidadHormigueos =
                      value ?? 0,
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
              "Total de hoy: ${widget.sentimientosAnsiedadFisicaTestBreve.totalScore} (${widget.sentimientosAnsiedadFisicaTestBreve.result})",
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
