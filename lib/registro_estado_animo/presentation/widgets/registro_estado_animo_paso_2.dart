import 'package:flutter/material.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';
import 'package:prueba/registro_estado_animo/presentation/widgets/widgets.dart';

class RegistroEstadoAnimoPaso2 extends StatefulWidget {
  final RegistroEstadoAnimo registroEstadoAnimo;
  final GlobalKey<FormState> formKey;

  const RegistroEstadoAnimoPaso2(
    this.registroEstadoAnimo,
    this.formKey, {
    super.key,
  });

  @override
  State<RegistroEstadoAnimoPaso2> createState() =>
      _RegistroEstadoAnimoPaso2State();
}

class _RegistroEstadoAnimoPaso2State extends State<RegistroEstadoAnimoPaso2> {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    TextStyle titleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
      color: primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    TextStyle bodyStyle = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontSize: 16);

    List<Emociones> gruposEmociones = [
      widget.registroEstadoAnimo.grupoEmociones1,
      widget.registroEstadoAnimo.grupoEmociones2,
      widget.registroEstadoAnimo.grupoEmociones3,
      widget.registroEstadoAnimo.grupoEmociones4,
      widget.registroEstadoAnimo.grupoEmociones5,
      widget.registroEstadoAnimo.grupoEmociones6,
      widget.registroEstadoAnimo.grupoEmociones7,
      widget.registroEstadoAnimo.grupoEmociones8,
      widget.registroEstadoAnimo.grupoEmociones9,
    ];
    const nombresGrupos = [
      'Tristeza y ánimo bajo',
      'Ansiedad y miedo',
      'Culpa',
      'Vergüenza',
      'Soledad y rechazo',
      'Incomodidad',
      'Desesperanza',
      'Frustración',
      'Ira y enojo',
    ];

    for (final grupo in gruposEmociones) {
      grupo.porcentajeCreenciaAntes ??= 0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text("Emociones", style: titleStyle),
          const SizedBox(height: 10),
          Text(
            "Seleccione las palabras que describan sus sentimientos en ese momento y califique cada sentimiento en una escala que va del 0% (nada en absoluto) al 100% (extremadamente).",
            style: bodyStyle,
          ),
          const SizedBox(height: 15),
          Form(
            key: widget.formKey,
            child: Column(
              children: [
                for (int i = 0; i < gruposEmociones.length; i++)
                  CustomCheckBoxGroupEmociones(
                    title: nombresGrupos[i],
                    grupoEmociones: gruposEmociones[i],
                  ),

                EmocionesPersonalizadasCheckBoxGroup(
                  grupoEmociones:
                      widget.registroEstadoAnimo.grupoEmocionesPersonalizadas,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
