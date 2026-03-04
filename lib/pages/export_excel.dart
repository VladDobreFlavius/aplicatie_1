import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportIstoricToExcel(
    List<Map<String, dynamic>> istoric, {
      String? customPath,
    }) async {
  final excel = Excel.createExcel();
  final sheet = excel['Producție'];

  sheet.appendRow([
    'Proiect',
    'Utilizator',
    'Data',
    'Lucrare',
    'Cantitate',
    'Unitate',
    'Utilaje',
    'Personal',
  ]);

  for (final item in istoric) {
    final lucrari = (item['lucrari'] as List? ?? [])
        .map((l) =>
    '${l['descriere']} (${l['cantitate']} ${l['unitate']})')
        .join(' | ');

    final utilaje = (item['utilaje'] as List? ?? [])
        .map((u) => '${u['utilaj']} x${u['nr']}')
        .join(', ');

    final personal = (item['personal'] as List? ?? [])
        .map((p) => '${p['functie']} x${p['nr']}')
        .join(', ');

    sheet.appendRow([
      item['project'] ?? '',
      item['username'] ?? '',
      item['dataCuOra'] ?? item['data'] ?? '',
      lucrari,
      '',
      '',
      utilaje,
      personal,
    ]);
  }

  // 📁 CALE SALVARE
  final path = customPath ??
      '${(await getExternalStorageDirectory())!.path}/istoric_productie.xlsx';

  final file = File(path);
  file.writeAsBytesSync(excel.encode()!);

  print('✅ Excel generat: $path');
}
