import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chestionar_productie_page.dart';
import 'istoric_productie_page.dart';

class ProductiePage extends StatelessWidget {
  final String username;
  final bool isAdmin;

  const ProductiePage({
    super.key,
    required this.username,
    required this.isAdmin,
  });

  Future<void> deschideExcel() async {
    final Uri url = Uri.parse(
      'https://shenna-clavate-hester.ngrok-free.dev/download_istoric',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Nu se poate deschide Excel-ul';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> proiecte = [
      'Căpâlna de Jos',
      'Cluj – linia ferată',
      'Băgau',
      'Zlatna – centură',
      'Heria',
      'Orăștioara – pistă biciclete',
      'Orăștioara – străzi',
      'Gârbova – pistă biciclete',
      'Aiud – Str. Strâmtă',
      'Aiud – Transalpina de Sud',
      'Beta',
      'Mintia',
      'Cricău',
      'Refaceri Sibiu',
      'Galda – pistă biciclete',
      'Diverse',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Producție'),
      ),
      body: Column(
        children: [

          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.factory, size: 28),
                SizedBox(width: 8),
                Text(
                  'Proiecte active',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔥 BUTON ADMIN DESCARCARE ISTORIC
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Descarcă istoric producție'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: deschideExcel,
              ),
            ),

          const SizedBox(height: 12),

          // LISTA PROIECTE
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: proiecte.length,
              itemBuilder: (context, index) {
                final proiect = proiecte[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChestionarProductiePage(
                            project: proiect,
                            username: username,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 32,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  proiect,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Chestionar producție zilnic',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // BUTON ISTORIC PAGE
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Istoric producție'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IstoricProductiePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
