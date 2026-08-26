import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';
import 'package:prueba/registro_estado_animo/presentation/providers/providers.dart';

typedef CrearRegistroEstadoDeAnimo =
    Future<void> Function(RegistroEstadoAnimo registroEstadoAnimo);

class NuevoRegistroEstadoDeAnimoNotifier extends Notifier<RegistroEstadoAnimo> {
  late CrearRegistroEstadoDeAnimo _crearRegistroEstadoDeAnimo;

  @override
  RegistroEstadoAnimo build() {
    _crearRegistroEstadoDeAnimo = ref
        .read(registroEstadoDeAnimoProvider.notifier)
        .guardarRegistroEstadoDeAnimo;
    return _nuevoRegistro();
  }

  RegistroEstadoAnimo _nuevoRegistro() => RegistroEstadoAnimo(
    id: "",
    fecha: DateTime.now(),
    sucesoTrastornador: "",
    grupoEmociones1: GrupoEmociones1(),
    grupoEmociones2: GrupoEmociones2(),
    grupoEmociones3: GrupoEmociones3(),
    grupoEmociones4: GrupoEmociones4(),
    grupoEmociones5: GrupoEmociones5(),
    grupoEmociones6: GrupoEmociones6(),
    grupoEmociones7: GrupoEmociones7(),
    grupoEmociones8: GrupoEmociones8(),
    grupoEmociones9: GrupoEmociones9(),
    grupoEmocionesPersonalizadas: GrupoEmocionesPersonalizadas(),
    listaPensamientos: [],
  );

  Future<void> crearNuevoRegistroEstadoAnimo() async {
    state = _nuevoRegistro();
  }

  Future<void> guardarRegistroEstadoDeAnimo() async {
    await _crearRegistroEstadoDeAnimo(state);
    crearNuevoRegistroEstadoAnimo();
  }
}

final nuevoRegistroEstadoDeAnimoProvider =
    NotifierProvider<NuevoRegistroEstadoDeAnimoNotifier, RegistroEstadoAnimo>(
      NuevoRegistroEstadoDeAnimoNotifier.new,
    );
