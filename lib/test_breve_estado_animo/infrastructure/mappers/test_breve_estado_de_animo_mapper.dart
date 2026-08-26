import 'package:prueba/test_breve_estado_animo/domain/entities/entities.dart';
import 'package:prueba/test_breve_estado_animo/infrastructure/models/models.dart';

class TestBreveEstadoDeAnimoMapper {
  static TestBreveEstadoDeAnimo testBreveEstadoDeAnimoResponseToEntity(
    TestBreveEstadoDeAnimoResponse testBreveEstadoDeAnimoResponse,
  ) {
    return TestBreveEstadoDeAnimo(
      fechaCreacion: testBreveEstadoDeAnimoResponse.fecha,
      sentimientosAnsiedadEmocionalTestBreve:
          _sentimientosAnsiedadEmocionalTestBreveDBToEntity(
            testBreveEstadoDeAnimoResponse.ansiedadEmocional,
          ),
      sentimientosAnsiedadFisicaTestBreve:
          _sentimientosAnsiedadFisicaTestBreveDBToEntity(
            testBreveEstadoDeAnimoResponse.ansiedadFisica,
          ),
      depresionTestBreve: _depresionTestBreveDBToEntity(
        testBreveEstadoDeAnimoResponse.depresion,
      ),
      impulsoSuicidaTestBreve: _impulsoSuicidaTestBreveDBToEntity(
        testBreveEstadoDeAnimoResponse.impulsoSuicida,
      ),
      notas: testBreveEstadoDeAnimoResponse.notas,
    );
  }

  static DepresionTestBreve _depresionTestBreveDBToEntity(
    DepresionTestBreveResponse depresionTestBreveResponse,
  ) {
    return DepresionTestBreve(
      tristeza: depresionTestBreveResponse.tristeza,
      desesperanza: depresionTestBreveResponse.desesperanza,
      bajaAutoestima: depresionTestBreveResponse.bajaAutoestima,
      faltaDeValor: depresionTestBreveResponse.faltaDeValor,
      perdidaDeSatisfaccion: depresionTestBreveResponse.perdidaDeSatisfaccion,
    );
  }

  static ImpulsoSuicidaTestBreve _impulsoSuicidaTestBreveDBToEntity(
    ImpulsoSuicidaTestBreveResponse impulsoSuicidaTestBreveResponse,
  ) {
    return ImpulsoSuicidaTestBreve(
      pensamientosSuicidas:
          impulsoSuicidaTestBreveResponse.pensamientosSuicidas,
      deseosDeMorir: impulsoSuicidaTestBreveResponse.deseosDeMorir,
    );
  }

  static SentimientosAnsiedadEmocionalTestBreve
  _sentimientosAnsiedadEmocionalTestBreveDBToEntity(
    SentimientosAnsiedadEmocionalTestBreveResponse
    sentimientosAnsiedadEmocionalTestBreveResponse,
  ) {
    return SentimientosAnsiedadEmocionalTestBreve(
      angustiado: sentimientosAnsiedadEmocionalTestBreveResponse.angustiado,
      nervioso: sentimientosAnsiedadEmocionalTestBreveResponse.nervioso,
      preocupado: sentimientosAnsiedadEmocionalTestBreveResponse.preocupado,
      asustado: sentimientosAnsiedadEmocionalTestBreveResponse.asustado,
      tenso: sentimientosAnsiedadEmocionalTestBreveResponse.tenso,
    );
  }

  static SentimientosAnsiedadFisicaTestBreve
  _sentimientosAnsiedadFisicaTestBreveDBToEntity(
    SentimientosAnsiedadFisicaTestBreveResponse
    sentimientosAnsiedadFisicaTestBreveResponse,
  ) {
    return SentimientosAnsiedadFisicaTestBreve(
      palpitaciones: sentimientosAnsiedadFisicaTestBreveResponse.palpitaciones,
      sudoracion: sentimientosAnsiedadFisicaTestBreveResponse.sudoracion,
      temblores: sentimientosAnsiedadFisicaTestBreveResponse.temblores,
      dificultadRespirar:
          sentimientosAnsiedadFisicaTestBreveResponse.dificultadRespirar,
      ahogo: sentimientosAnsiedadFisicaTestBreveResponse.ahogo,
      dolorPecho: sentimientosAnsiedadFisicaTestBreveResponse.dolorPecho,
      nauseas: sentimientosAnsiedadFisicaTestBreveResponse.nauseas,
      mareos: sentimientosAnsiedadFisicaTestBreveResponse.mareos,
      sensacionIrrealidad:
          sentimientosAnsiedadFisicaTestBreveResponse.sensacionIrrealidad,
      inestabilidadHormigueos:
          sentimientosAnsiedadFisicaTestBreveResponse.inestabilidadHormigueos,
    );
  }

  static ImpulsoSuicidaTestBreveResponse
  _impulsoSuicidaTestBreveEntityToResponse(
    ImpulsoSuicidaTestBreve impulsoSuicidaTestBreveEntity,
  ) {
    return ImpulsoSuicidaTestBreveResponse(
      pensamientosSuicidas: impulsoSuicidaTestBreveEntity.pensamientosSuicidas,
      deseosDeMorir: impulsoSuicidaTestBreveEntity.deseosDeMorir,
    );
  }

  static DepresionTestBreveResponse _depresionTestBreveEntityToResponse(
    DepresionTestBreve depresionTestBreveEntity,
  ) {
    return DepresionTestBreveResponse(
      tristeza: depresionTestBreveEntity.tristeza,
      desesperanza: depresionTestBreveEntity.desesperanza,
      bajaAutoestima: depresionTestBreveEntity.bajaAutoestima,
      faltaDeValor: depresionTestBreveEntity.faltaDeValor,
      perdidaDeSatisfaccion: depresionTestBreveEntity.perdidaDeSatisfaccion,
    );
  }

  static SentimientosAnsiedadEmocionalTestBreveResponse
  _sentimientosAnsiedadEmocionalTestBreveEntityToResponse(
    SentimientosAnsiedadEmocionalTestBreve
    sentimientosAnsiedadEmocionalTestBreveEntity,
  ) {
    return SentimientosAnsiedadEmocionalTestBreveResponse(
      angustiado: sentimientosAnsiedadEmocionalTestBreveEntity.angustiado,
      nervioso: sentimientosAnsiedadEmocionalTestBreveEntity.nervioso,
      preocupado: sentimientosAnsiedadEmocionalTestBreveEntity.preocupado,
      asustado: sentimientosAnsiedadEmocionalTestBreveEntity.asustado,
      tenso: sentimientosAnsiedadEmocionalTestBreveEntity.tenso,
    );
  }

  static SentimientosAnsiedadFisicaTestBreveResponse
  _sentimientosAnsiedadFisicaTestBreveEntityToResponse(
    SentimientosAnsiedadFisicaTestBreve
    sentimientosAnsiedadFisicaTestBreveEntity,
  ) {
    return SentimientosAnsiedadFisicaTestBreveResponse(
      palpitaciones: sentimientosAnsiedadFisicaTestBreveEntity.palpitaciones,
      sudoracion: sentimientosAnsiedadFisicaTestBreveEntity.sudoracion,
      temblores: sentimientosAnsiedadFisicaTestBreveEntity.temblores,
      dificultadRespirar:
          sentimientosAnsiedadFisicaTestBreveEntity.dificultadRespirar,
      ahogo: sentimientosAnsiedadFisicaTestBreveEntity.ahogo,
      dolorPecho: sentimientosAnsiedadFisicaTestBreveEntity.dolorPecho,
      nauseas: sentimientosAnsiedadFisicaTestBreveEntity.nauseas,
      mareos: sentimientosAnsiedadFisicaTestBreveEntity.mareos,
      sensacionIrrealidad:
          sentimientosAnsiedadFisicaTestBreveEntity.sensacionIrrealidad,
      inestabilidadHormigueos:
          sentimientosAnsiedadFisicaTestBreveEntity.inestabilidadHormigueos,
    );
  }

  static TestBreveEstadoDeAnimoResponse testBreveEstadoDeAnimoEntityToResponse(
    TestBreveEstadoDeAnimo testBreveEstadoDeAnimoEntity,
  ) {
    return TestBreveEstadoDeAnimoResponse(
      fecha: testBreveEstadoDeAnimoEntity.fechaCreacion,
      ansiedadEmocional:
          _sentimientosAnsiedadEmocionalTestBreveEntityToResponse(
            testBreveEstadoDeAnimoEntity.sentimientosAnsiedadEmocionalTestBreve,
          ),
      ansiedadFisica: _sentimientosAnsiedadFisicaTestBreveEntityToResponse(
        testBreveEstadoDeAnimoEntity.sentimientosAnsiedadFisicaTestBreve,
      ),
      depresion: _depresionTestBreveEntityToResponse(
        testBreveEstadoDeAnimoEntity.depresionTestBreve,
      ),
      impulsoSuicida: _impulsoSuicidaTestBreveEntityToResponse(
        testBreveEstadoDeAnimoEntity.impulsoSuicidaTestBreve,
      ),
      notas: testBreveEstadoDeAnimoEntity.notas,
    );
  }
}
