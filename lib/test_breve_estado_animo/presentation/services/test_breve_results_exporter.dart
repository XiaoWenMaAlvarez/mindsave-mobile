import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mindsave/test_breve_estado_animo/domain/entities/entities.dart';

class TestBreveExportFile {
  const TestBreveExportFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

class TestBreveResultsExporter {
  const TestBreveResultsExporter._();

  static const _headers = <String>[
    'Fecha',
    'Ansiedad emocional (0-20)',
    'Ansiedad física (0-40)',
    'Estado de ánimo (0-20)',
    'Seguridad personal (0-8)',
    'Notas',
  ];
  static const _pdfHeaders = <String>[
    'Fecha',
    'Ansiedad emocional (0-20)',
    'Ansiedad fisica (0-40)',
    'Estado de animo (0-20)',
    'Seguridad personal (0-8)',
    'Notas',
  ];

  static Future<TestBreveExportFile> pdf({
    required int year,
    required List<TestBreveEstadoDeAnimo> tests,
  }) async {
    final orderedTests = _ordered(tests);
    final document = pw.Document(
      title: 'Resultados de test breve $year',
      author: 'MindSave',
      subject: 'Seguimiento anual del estado de animo',
    );
    final accent = PdfColor.fromHex('#6D5BD0');
    final border = PdfColor.fromHex('#D9D4E8');
    final muted = PdfColor.fromHex('#5F5A69');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(32, 34, 32, 30),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'MindSave - Uso personal',
              style: pw.TextStyle(fontSize: 8, color: muted),
            ),
            pw.Text(
              'Pagina ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: muted),
            ),
          ],
        ),
        build: (context) => [
          pw.Text(
            'Resultados de test breve',
            style: pw.TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Anio $year - ${orderedTests.length} ${orderedTests.length == 1 ? 'evaluacion' : 'evaluaciones'}',
            style: pw.TextStyle(fontSize: 11, color: muted),
          ),
          pw.SizedBox(height: 18),
          if (orderedTests.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text('No hay evaluaciones registradas para este anio.'),
            )
          else
            pw.TableHelper.fromTextArray(
              context: context,
              headers: _pdfHeaders,
              data: [for (final test in orderedTests) _pdfRow(test)],
              border: pw.TableBorder.all(color: border, width: .6),
              headerDecoration: pw.BoxDecoration(color: accent),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: const {
                0: pw.FlexColumnWidth(1.1),
                1: pw.FlexColumnWidth(1.2),
                2: pw.FlexColumnWidth(1.2),
                3: pw.FlexColumnWidth(1.15),
                4: pw.FlexColumnWidth(1.2),
                5: pw.FlexColumnWidth(2.4),
              },
            ),
          pw.SizedBox(height: 14),
          pw.Text(
            'Estos resultados permiten observar tendencias y no reemplazan una evaluacion profesional.',
            style: pw.TextStyle(fontSize: 8.5, color: muted),
          ),
        ],
      ),
    );

    return TestBreveExportFile(
      bytes: await document.save(),
      fileName: 'mindsave_test_breve_$year.pdf',
      mimeType: 'application/pdf',
    );
  }

  static TestBreveExportFile excel({
    required int year,
    required List<TestBreveEstadoDeAnimo> tests,
  }) {
    final orderedTests = _ordered(tests);
    final rows = <List<Object>>[
      _headers,
      for (final test in orderedTests) _row(test),
    ];
    final archive = Archive()
      ..addFile(ArchiveFile.string('[Content_Types].xml', _contentTypes))
      ..addFile(ArchiveFile.string('_rels/.rels', _packageRelationships))
      ..addFile(ArchiveFile.string('xl/workbook.xml', _workbook))
      ..addFile(
        ArchiveFile.string(
          'xl/_rels/workbook.xml.rels',
          _workbookRelationships,
        ),
      )
      ..addFile(ArchiveFile.string('xl/styles.xml', _styles))
      ..addFile(
        ArchiveFile.string('xl/worksheets/sheet1.xml', _worksheet(rows)),
      );

    return TestBreveExportFile(
      bytes: ZipEncoder().encodeBytes(archive),
      fileName: 'mindsave_test_breve_$year.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  static List<TestBreveEstadoDeAnimo> _ordered(
    List<TestBreveEstadoDeAnimo> tests,
  ) => [...tests]..sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));

  static List<Object> _row(TestBreveEstadoDeAnimo test) => [
    _formatDate(test.fechaCreacion),
    test.sentimientosAnsiedadEmocionalTestBreve.totalScore,
    test.sentimientosAnsiedadFisicaTestBreve.totalScore,
    test.depresionTestBreve.totalScore,
    test.impulsoSuicidaTestBreve.totalScore,
    _singleLine(test.notas),
  ];

  static List<Object> _pdfRow(TestBreveEstadoDeAnimo test) => [
    _formatDate(test.fechaCreacion),
    test.sentimientosAnsiedadEmocionalTestBreve.totalScore,
    test.sentimientosAnsiedadFisicaTestBreve.totalScore,
    test.depresionTestBreve.totalScore,
    test.impulsoSuicidaTestBreve.totalScore,
    _ascii(_singleLine(test.notas)),
  ];

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _singleLine(String? value) =>
      value?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';

  static String _ascii(String value) {
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'Ü': 'U',
      'Ñ': 'N',
    };
    var normalized = value;
    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized.replaceAll(RegExp(r'[^\x20-\x7E]'), '?');
  }

  static String _worksheet(List<List<Object>> rows) {
    final lastRow = rows.length;
    final rowXml = StringBuffer();

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final rowNumber = rowIndex + 1;
      rowXml.write('<row r="$rowNumber">');
      for (
        var columnIndex = 0;
        columnIndex < rows[rowIndex].length;
        columnIndex++
      ) {
        final reference = '${_columnName(columnIndex)}$rowNumber';
        final value = rows[rowIndex][columnIndex];
        if (value is num) {
          rowXml.write('<c r="$reference"><v>$value</v></c>');
        } else {
          final style = rowIndex == 0 ? ' s="1"' : '';
          rowXml.write(
            '<c r="$reference" t="inlineStr"$style>'
            '<is><t xml:space="preserve">${_xmlEscape('$value')}</t></is>'
            '</c>',
          );
        }
      }
      rowXml.write('</row>');
    }

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <dimension ref="A1:F$lastRow"/>
  <sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>
  <sheetFormatPr defaultRowHeight="15"/>
  <cols>
    <col min="1" max="1" width="13" customWidth="1"/>
    <col min="2" max="5" width="23" customWidth="1"/>
    <col min="6" max="6" width="48" customWidth="1"/>
  </cols>
  <sheetData>$rowXml</sheetData>
  <autoFilter ref="A1:F$lastRow"/>
</worksheet>''';
  }

  static String _columnName(int index) {
    var value = index + 1;
    final name = StringBuffer();
    while (value > 0) {
      value--;
      name.writeCharCode(65 + value % 26);
      value ~/= 26;
    }
    return name.toString().split('').reversed.join();
  }

  static String _xmlEscape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  static const _contentTypes =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>''';

  static const _packageRelationships =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>''';

  static const _workbook =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets><sheet name="Resultados" sheetId="1" r:id="rId1"/></sheets>
</workbook>''';

  static const _workbookRelationships =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''';

  static const _styles =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="2">
    <font><sz val="11"/><name val="Calibri"/></font>
    <font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font>
  </fonts>
  <fills count="3">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF6D5BD0"/><bgColor indexed="64"/></patternFill></fill>
  </fills>
  <borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="2">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1" applyAlignment="1"><alignment wrapText="1"/></xf>
  </cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
</styleSheet>''';
}
