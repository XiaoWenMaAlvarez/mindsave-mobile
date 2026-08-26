import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';
import 'package:prueba/registro_estado_animo/presentation/services/cbt_record_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('genera un registro CBT individual válido en PDF y Excel', () async {
    final record = _completedRecord();

    final pdf = await CbtRecordExporter.pdf(record);
    expect(pdf.fileName, 'mindsave_registro_cbt_2026-08-18_reg-1234.pdf');
    expect(ascii.decode(pdf.bytes.take(4).toList()), '%PDF');
    expect(pdf.bytes.length, greaterThan(800));

    final excel = CbtRecordExporter.excel(record);
    expect(excel.fileName, 'mindsave_registro_cbt_2026-08-18_reg-1234.xlsx');
    expect(excel.bytes.take(2), orderedEquals([0x50, 0x4b]));

    final archive = ZipDecoder().decodeBytes(excel.bytes);
    expect(
      archive.files.map((file) => file.name),
      containsAll([
        '[Content_Types].xml',
        'xl/workbook.xml',
        'xl/worksheets/sheet1.xml',
      ]),
    );
    final worksheet = archive.files.firstWhere(
      (file) => file.name == 'xl/worksheets/sheet1.xml',
    );
    final xml = utf8.decode(worksheet.readBytes()!);
    expect(xml, contains('Reunión &amp; difícil'));
    expect(xml, contains('Angustiado'));
    expect(xml, contains('Pensamiento todo o nada'));
    expect(xml, contains('Puedo resolverlo paso a paso'));
  });
}

RegistroEstadoAnimo _completedRecord() {
  final record = RegistroEstadoAnimo(
    id: 'reg-123456789',
    fecha: DateTime(2026, 8, 18),
    sucesoTrastornador: 'Reunión & difícil',
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
    listaPensamientos: [
      Pensamiento.fromMapper(
        pensamientoNegativo: 'Todo saldrá mal',
        porcentajeCreenciaAntes: 85,
        porcentajeCreenciaDespues: 30,
        pensamientoPositivo: 'Puedo resolverlo paso a paso',
        porcentajeCreenciaPositivo: 80,
        distorsion: [true, ...List.filled(9, false)],
      ),
    ],
  );

  final groups = <Emociones>[
    record.grupoEmociones1,
    record.grupoEmociones2,
    record.grupoEmociones3,
    record.grupoEmociones4,
    record.grupoEmociones5,
    record.grupoEmociones6,
    record.grupoEmociones7,
    record.grupoEmociones8,
    record.grupoEmociones9,
    record.grupoEmocionesPersonalizadas,
  ];
  for (final group in groups) {
    group.porcentajeCreenciaDespues = 0;
  }
  record.grupoEmociones2
    ..seleccionEmociones[0] = true
    ..porcentajeCreenciaAntes = 80
    ..porcentajeCreenciaDespues = 30;

  return record;
}
