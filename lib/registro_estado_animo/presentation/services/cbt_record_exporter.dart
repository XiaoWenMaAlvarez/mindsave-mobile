import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:prueba/registro_estado_animo/domain/entities/entities.dart';

class CbtRecordExportFile {
  const CbtRecordExportFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

class CbtRecordExporter {
  const CbtRecordExporter._();

  static Future<CbtRecordExportFile> pdf(RegistroEstadoAnimo record) async {
    final document = pw.Document(
      title: 'Registro CBT ${_formatDate(record.fecha)}',
      author: 'MindSave',
      subject: 'Registro individual de estado de animo',
    );
    final accent = PdfColor.fromHex('#006D6F');
    final border = PdfColor.fromHex('#D5DEDA');
    final muted = PdfColor.fromHex('#596562');
    final emotionRows = _emotionRows(record);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 40, 38, 34),
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
            'Registro CBT',
            style: pw.TextStyle(
              color: accent,
              fontSize: 23,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${_formatDate(record.fecha)} - Registro completado',
            style: pw.TextStyle(fontSize: 10.5, color: muted),
          ),
          pw.SizedBox(height: 22),
          _pdfSectionTitle('Situacion', accent),
          pw.SizedBox(height: 7),
          pw.Text(
            _ascii(_singleLine(record.sucesoTrastornador)),
            style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 3),
          ),
          pw.SizedBox(height: 22),
          _pdfSectionTitle('Evolucion emocional', accent),
          pw.SizedBox(height: 9),
          if (emotionRows.isEmpty)
            pw.Text(
              'No hay emociones seleccionadas.',
              style: pw.TextStyle(fontSize: 9.5, color: muted),
            )
          else
            pw.TableHelper.fromTextArray(
              context: context,
              headers: const [
                'Grupo',
                'Emociones',
                'Antes',
                'Despues',
                'Cambio',
              ],
              data: [
                for (final row in emotionRows)
                  [
                    _ascii(row.title),
                    _ascii(row.emotions),
                    '${row.before}%',
                    '${row.after}%',
                    '${row.before - row.after} pts',
                  ],
              ],
              border: pw.TableBorder.all(color: border, width: .6),
              headerDecoration: pw.BoxDecoration(color: accent),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(1.1),
                1: pw.FlexColumnWidth(2.4),
                2: pw.FlexColumnWidth(.7),
                3: pw.FlexColumnWidth(.7),
                4: pw.FlexColumnWidth(.8),
              },
            ),
          pw.SizedBox(height: 22),
          _pdfSectionTitle('Reestructuracion cognitiva', accent),
          pw.SizedBox(height: 5),
          if (record.listaPensamientos.isEmpty)
            pw.Text(
              'No hay pensamientos registrados.',
              style: pw.TextStyle(fontSize: 9.5, color: muted),
            )
          else
            for (
              var index = 0;
              index < record.listaPensamientos.length;
              index++
            ) ...[
              pw.SizedBox(height: index == 0 ? 7 : 14),
              pw.Text(
                'Pensamiento ${index + 1}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              _pdfField(
                'Pensamiento automatico',
                _ascii(
                  _singleLine(
                    record.listaPensamientos[index].pensamientoNegativo,
                  ),
                ),
                muted,
              ),
              _pdfField(
                'Creencia',
                '${record.listaPensamientos[index].porcentajeCreenciaAntes}% antes - '
                    '${record.listaPensamientos[index].porcentajeCreenciaDespues ?? 0}% despues',
                muted,
              ),
              _pdfField(
                'Distorsiones',
                _ascii(_distortions(record.listaPensamientos[index])),
                muted,
              ),
              _pdfField(
                'Pensamiento alternativo',
                _ascii(
                  _singleLine(
                    record.listaPensamientos[index].pensamientoPositivo,
                  ),
                ),
                muted,
              ),
              _pdfField(
                'Creencia en la alternativa',
                '${record.listaPensamientos[index].porcentajeCreenciaPositivo ?? 0}%',
                muted,
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: border, thickness: .7),
            ],
          pw.SizedBox(height: 14),
          pw.Text(
            'Este documento es un resumen personal y no reemplaza una evaluacion profesional.',
            style: pw.TextStyle(fontSize: 8.5, color: muted),
          ),
        ],
      ),
    );

    return CbtRecordExportFile(
      bytes: await document.save(),
      fileName: '${_fileStem(record)}.pdf',
      mimeType: 'application/pdf',
    );
  }

  static CbtRecordExportFile excel(RegistroEstadoAnimo record) {
    final rows = <List<Object>>[
      ['Registro CBT'],
      ['Fecha', _formatDate(record.fecha)],
      ['Estado', 'Completado'],
      ['Situación', _singleLine(record.sucesoTrastornador)],
      const [],
      ['Emociones'],
      ['Grupo', 'Emociones', 'Antes (%)', 'Después (%)', 'Cambio (puntos)'],
      for (final row in _emotionRows(record))
        [
          row.title,
          row.emotions,
          row.before,
          row.after,
          row.before - row.after,
        ],
      const [],
      ['Pensamientos'],
      [
        'N°',
        'Pensamiento automático',
        'Creencia antes (%)',
        'Creencia después (%)',
        'Distorsiones',
        'Pensamiento alternativo',
        'Creencia alternativa (%)',
      ],
      for (var index = 0; index < record.listaPensamientos.length; index++)
        [
          index + 1,
          _singleLine(record.listaPensamientos[index].pensamientoNegativo),
          record.listaPensamientos[index].porcentajeCreenciaAntes,
          record.listaPensamientos[index].porcentajeCreenciaDespues ?? 0,
          _distortions(record.listaPensamientos[index]),
          _singleLine(record.listaPensamientos[index].pensamientoPositivo),
          record.listaPensamientos[index].porcentajeCreenciaPositivo ?? 0,
        ],
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

    return CbtRecordExportFile(
      bytes: ZipEncoder().encodeBytes(archive),
      fileName: '${_fileStem(record)}.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  static pw.Widget _pdfSectionTitle(String title, PdfColor accent) => pw.Text(
    title,
    style: pw.TextStyle(
      color: accent,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    ),
  );

  static pw.Widget _pdfField(String label, String value, PdfColor muted) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.RichText(
          text: pw.TextSpan(
            style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2),
            children: [
              pw.TextSpan(
                text: '$label: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: muted,
                ),
              ),
              pw.TextSpan(text: value.isEmpty ? 'Sin información' : value),
            ],
          ),
        ),
      );

  static List<_EmotionExportRow> _emotionRows(RegistroEstadoAnimo record) {
    final groups = <({String title, Emociones group})>[
      (title: 'Tristeza', group: record.grupoEmociones1),
      (title: 'Ansiedad', group: record.grupoEmociones2),
      (title: 'Culpa', group: record.grupoEmociones3),
      (title: 'Vergüenza', group: record.grupoEmociones4),
      (title: 'Soledad', group: record.grupoEmociones5),
      (title: 'Turbación', group: record.grupoEmociones6),
      (title: 'Desesperanza', group: record.grupoEmociones7),
      (title: 'Frustración', group: record.grupoEmociones8),
      (title: 'Ira', group: record.grupoEmociones9),
      (title: 'Otras emociones', group: record.grupoEmocionesPersonalizadas),
    ];

    return [
      for (final data in groups)
        if (_selectedEmotions(data.group).isNotEmpty)
          _EmotionExportRow(
            title: data.title,
            emotions: _selectedEmotions(data.group).join(', '),
            before: data.group.porcentajeCreenciaAntes ?? 0,
            after: data.group.porcentajeCreenciaDespues ?? 0,
          ),
    ];
  }

  static List<String> _selectedEmotions(Emociones group) => [
    for (var index = 0; index < group.listaEmociones.length; index++)
      if (index < group.seleccionEmociones.length &&
          group.seleccionEmociones[index])
        group.listaEmociones[index],
  ];

  static String _distortions(Pensamiento thought) {
    final selected = <String>[
      for (
        var index = 0;
        index < thought.distorsion.length &&
            index < Pensamiento.listaDistorsiones.length;
        index++
      )
        if (thought.distorsion[index]) Pensamiento.listaDistorsiones[index],
    ];
    return selected.isEmpty
        ? 'Sin distorsiones seleccionadas'
        : selected.join(', ');
  }

  static String _fileStem(RegistroEstadoAnimo record) {
    final date =
        '${record.fecha.year.toString().padLeft(4, '0')}-'
        '${record.fecha.month.toString().padLeft(2, '0')}-'
        '${record.fecha.day.toString().padLeft(2, '0')}';
    var safeId = record.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    if (safeId.length > 8) safeId = safeId.substring(0, 8);
    return 'mindsave_registro_cbt_$date${safeId.isEmpty ? '' : '_$safeId'}';
  }

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
      final row = rows[rowIndex];
      rowXml.write('<row r="$rowNumber">');
      for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
        final reference = '${_columnName(columnIndex)}$rowNumber';
        final value = row[columnIndex];
        final style = _isHeaderRow(row) ? ' s="1"' : '';
        if (value is num) {
          rowXml.write('<c r="$reference"$style><v>$value</v></c>');
        } else {
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
  <dimension ref="A1:G$lastRow"/>
  <sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>
  <sheetFormatPr defaultRowHeight="18"/>
  <cols>
    <col min="1" max="1" width="22" customWidth="1"/>
    <col min="2" max="2" width="48" customWidth="1"/>
    <col min="3" max="4" width="21" customWidth="1"/>
    <col min="5" max="6" width="48" customWidth="1"/>
    <col min="7" max="7" width="25" customWidth="1"/>
  </cols>
  <sheetData>$rowXml</sheetData>
</worksheet>''';
  }

  static bool _isHeaderRow(List<Object> row) =>
      row.isNotEmpty &&
      const {
        'Registro CBT',
        'Emociones',
        'Grupo',
        'Pensamientos',
        'N°',
      }.contains('${row.first}');

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
  <sheets><sheet name="Registro CBT" sheetId="1" r:id="rId1"/></sheets>
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
    <fill><patternFill patternType="solid"><fgColor rgb="FF006D6F"/><bgColor indexed="64"/></patternFill></fill>
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

class _EmotionExportRow {
  const _EmotionExportRow({
    required this.title,
    required this.emotions,
    required this.before,
    required this.after,
  });

  final String title;
  final String emotions;
  final int before;
  final int after;
}
