import 'package:flutter/material.dart';
import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/presentation/widgets/widgets.dart';

class AnsiedadEmocionalForm extends StatefulWidget {
  final SentimientosAnsiedadEmocionalTestBreve
  sentimientosAnsiedadEmocionalTestBreve;

  const AnsiedadEmocionalForm(
    this.sentimientosAnsiedadEmocionalTestBreve, {
    super.key,
  });

  @override
  State<AnsiedadEmocionalForm> createState() => _AnsiedadEmocionalFormState();
}

class _AnsiedadEmocionalFormState extends State<AnsiedadEmocionalForm> {
  @override
  Widget build(BuildContext context) {
    final int minValue = SentimientosAnsiedadEmocionalTestBreve.valorMin;
    final int maxValue = SentimientosAnsiedadEmocionalTestBreve.valorMax;
    final List<String> labels =
        SentimientosAnsiedadEmocionalTestBreve.etiquetaPuntuacion;

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
        Text("Sentimientos de Ansiedad Emocional", style: titleStyle),
        const SizedBox(height: 10),

        CustomRadioButton(
          title: "Angustiado",
          groupValue: widget.sentimientosAnsiedadEmocionalTestBreve.angustiado,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadEmocionalTestBreve.angustiado =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),

        CustomRadioButton(
          title: "Nervioso",
          groupValue: widget.sentimientosAnsiedadEmocionalTestBreve.nervioso,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadEmocionalTestBreve.nervioso =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),
        CustomRadioButton(
          title: "Preocupado",
          groupValue: widget.sentimientosAnsiedadEmocionalTestBreve.preocupado,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadEmocionalTestBreve.preocupado =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),
        CustomRadioButton(
          title: "Asustado o aprensivo",
          groupValue: widget.sentimientosAnsiedadEmocionalTestBreve.asustado,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadEmocionalTestBreve.asustado =
                  value ?? 0,
            );
          },
          minValue: minValue,
          maxValue: maxValue,
          labels: labels,
        ),
        CustomRadioButton(
          title: "Tenso o con los nervios de punta",
          groupValue: widget.sentimientosAnsiedadEmocionalTestBreve.tenso,
          onChanged: (value) {
            setState(
              () => widget.sentimientosAnsiedadEmocionalTestBreve.tenso =
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
              "Total de hoy: ${widget.sentimientosAnsiedadEmocionalTestBreve.totalScore} (${widget.sentimientosAnsiedadEmocionalTestBreve.result})",
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
