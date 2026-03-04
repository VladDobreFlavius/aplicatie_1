import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'export_excel.dart';

class IstoricProductiePage extends StatefulWidget {
  const IstoricProductiePage({super.key});

  @override
  State<IstoricProductiePage> createState() => _IstoricProductiePageState();
}

class _IstoricProductiePageState extends State<IstoricProductiePage> {
  List<Map<String, dynamic>> istoric = [];

  @override
  void initState() {
    super.initState();
    _loadIstoric();
  }

  Future<void> _loadIstoric() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('istoric_productie') ?? [];

    setState(() {
      istoric = list
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList()
          .reversed
          .toList();
    });
  }

  // ================= BOTTOM SHEET ACTIUNI =================
  void _showActiuni(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['project'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Trimite WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                _shareText(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export Excel'),
              onTap: () async {
                Navigator.pop(context);
                await _shareExcel(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= SHARE TEXT =================
  void _shareText(Map<String, dynamic> item) {
    final totalPersonal = (item['personal'] as Map)
        .values
        .fold<int>(0, (a, b) => a + (b as int));

    final text = '''
📋 Chestionar producție

🏗 Proiect: ${item['project']}
👤 Utilizator: ${item['username']}
📅 Data: ${item['dataCuOra'] ?? item['data']}

🛠 Lucrări:
${(item['lucrari'] as List)
        .map((l) => '- ${l['descriere']}: ${l['cantitate']} ${l['unitate']}')
        .join('\n')}

🚜 Utilaje:
${(item['utilaje'] as Map)
        .entries
        .where((e) => e.value > 0)
        .map((e) => '- ${e.key}: ${e.value}')
        .join('\n')}

👷 Personal total: $totalPersonal

📝 Observații:
${item['observatii'] ?? '-'}
''';

    Share.share(text);
  }

  // ================= SHARE EXCEL =================
  Future<void> _shareExcel(Map<String, dynamic> item) async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/chestionar_${item['project']}_${item['data']}.xlsx';

    await exportIstoricToExcel([item], customPath: path);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Chestionar producție – ${item['project']}',
    );
  }

  // ================= EXPORT TOT =================
  Future<void> _exportTot() async {
    try {
      await exportIstoricToExcel(istoric);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✔ Excel cu tot istoricul creat')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare export: $e')),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Istoric producție'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportă tot istoricul (Excel)',
            onPressed: _exportTot,
          ),
        ],
      ),
      body: istoric.isEmpty
          ? const Center(child: Text('Nu există chestionare salvate'))
          : ListView.builder(
        itemCount: istoric.length,
        itemBuilder: (_, i) {
          final item = istoric[i];

          final totalPersonal = (item['personal'] as Map)
              .values
              .fold<int>(0, (a, b) => a + (b as int));

          return Card(
            elevation: 2,
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.description),
              title: Text(
                item['project'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data: ${item['data']}'),
                  Text('Utilizator: ${item['username']}'),
                  Text('Personal: $totalPersonal'),
                ],
              ),
              trailing: const Icon(Icons.more_vert),
              onTap: () => _showActiuni(item),
            ),
          );
        },
      ),
    );
  }
}
