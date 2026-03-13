import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

class ChestionarProductiePage extends StatefulWidget {
  final String project;
  final String username;

  const ChestionarProductiePage({
    super.key,
    required this.project,
    required this.username,
  });

  @override
  State<ChestionarProductiePage> createState() =>
      _ChestionarProductiePageState();
}

class _ChestionarProductiePageState
    extends State<ChestionarProductiePage> {

  late String data;
  late String dataCuOra;

  String meteo = 'Senin';
  TimeOfDay? ploaieStart;
  TimeOfDay? ploaieStop;

  final descriereCtrl = TextEditingController();
  final cantitateCtrl = TextEditingController();
  final altaUnitateCtrl = TextEditingController();
  final observatiiCtrl = TextEditingController();
  final necesarMaineCtrl = TextEditingController();

  // ================= MATERIALE =================
  final materialCtrl = TextEditingController();
  final materialCantCtrl = TextEditingController();
  final materialAltaUnitateCtrl = TextEditingController();
  String materialUnitate = 'Bucăți';
  final List<Map<String, dynamic>> materiale = [];

  // ================= POZE =================
  final ImagePicker picker = ImagePicker();
  final List<XFile> poze = [];

  String unitate = 'Metri liniari';
  final List<Map<String, dynamic>> lucrari = [];

  List<String> utilajeLista = [
    'Excavator pneuri',
    'Excavator senile',
    'Buldoexcavator',
    'Autobasculantă',
    'Dumper',
    'Autoutilitară',
    'Încărcător frontal',
    'Telehandler',
    'Camion macara',
    'Buldozer',
    'Cilindru compactor',
    'Trailer',
  ];

  List<String> personalLista = [
    'Inginer',
    'Inginer mecanic',
    'Șef de echipă',
    'Operator utilaj',
    'Muncitor necalificat',
    'Dulgher',
    'Conducător auto',
    'Sudor',
  ];

  final Map<String, int> utilaje = {};
  final Map<String, int> personal = {};

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    data = DateFormat('yyyy-MM-dd').format(now);
    dataCuOra = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    for (var u in utilajeLista) {
      utilaje[u] = 0;
    }

    for (var p in personalLista) {
      personal[p] = 0;
    }
  }

  // ---------------- POZE ----------------

  Future<void> adaugaPoze() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        poze.clear();     // 🔥 șterge orice poză veche
        poze.add(image);  // 🔥 adaugă doar una
      });
    }
  }

  void stergePoza(int index) {
    setState(() {
      poze.removeAt(index);
    });
  }

  // ---------------- MATERIALE ----------------

  void adaugaMaterial() {
    final cant =
    double.tryParse(materialCantCtrl.text.replaceAll(',', '.'));

    if (materialCtrl.text.isEmpty || cant == null || cant <= 0) return;

    setState(() {
      materiale.add({
        'material': materialCtrl.text.trim(),
        'cantitate': cant,
        'unitate': materialAltaUnitateCtrl.text.isNotEmpty
            ? materialAltaUnitateCtrl.text
            : materialUnitate,
      });
    });

    materialCtrl.clear();
    materialCantCtrl.clear();
    materialAltaUnitateCtrl.clear();
  }

  // ---------------- METEO ----------------

  Future<void> pickTime(bool start) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t == null) return;
    setState(() => start ? ploaieStart = t : ploaieStop = t);
  }

  // ---------------- LUCRARI ----------------

  void adaugaLucrare() {
    final cant =
    double.tryParse(cantitateCtrl.text.replaceAll(',', '.'));

    if (descriereCtrl.text.isEmpty || cant == null || cant <= 0) return;

    String descriere = descriereCtrl.text.trim();
    descriere =
        descriere[0].toUpperCase() + descriere.substring(1);

    setState(() {
      lucrari.add({
        'descriere': descriere,
        'cantitate': cant,
        'unitate': altaUnitateCtrl.text.isNotEmpty
            ? altaUnitateCtrl.text
            : unitate,
      });
    });

    descriereCtrl.clear();
    cantitateCtrl.clear();
    altaUnitateCtrl.clear();
  }

  // ---------------- UTILAJ NOU ----------------

  void adaugaUtilajNou(String nume) {
    if (nume.trim().isEmpty) return;

    final formatat =
        nume[0].toUpperCase() + nume.substring(1).toLowerCase();

    if (!utilaje.containsKey(formatat)) {
      setState(() {
        utilajeLista.add(formatat);
        utilaje[formatat] = 0;
      });
    }
  }

  void adaugaPersonalNou(String nume) {
    if (nume.trim().isEmpty) return;

    final formatat =
        nume[0].toUpperCase() + nume.substring(1).toLowerCase();

    if (!personal.containsKey(formatat)) {
      setState(() {
        personalLista.add(formatat);
        personal[formatat] = 0;
      });
    }
  }

  // ---------------- LISTA DINAMICA ----------------

  Widget listaPlusMinus(
      Map<String, int> data,
      void Function(String) onAddNew,
      ) {
    return Column(
      children: [
        ...data.keys.map((k) {
          return ListTile(
            title: Text(k),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: data[k]! > 0
                      ? () =>
                      setState(() => data[k] = data[k]! - 1)
                      : null,
                ),
                Text(data[k].toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      setState(() => data[k] = data[k]! + 1),
                ),
              ],
            ),
          );
        }),

        const Divider(),

        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return data.keys.where((option) =>
                option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase()));
          },
          onSelected: (selection) {
            setState(() {
              data[selection] = data[selection]! + 1;
            });
          },
          fieldViewBuilder:
              (context, controller, focusNode, _) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textCapitalization:
                    TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: "Adaugă nou",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    onAddNew(controller.text);
                    controller.clear();
                  },
                  child: const Text("+"),
                )
              ],
            );
          },
        ),
      ],
    );
  }

  // ---------------- PAYLOAD ----------------

  Map<String, dynamic> buildPayload() {
    return {
      'project': widget.project,
      'username': widget.username,
      'data': data,
      'dataCuOra': dataCuOra,
      'meteo': meteo,
      'ploaieInterval': meteo == 'Ploaie'
          ? {
        'start': ploaieStart?.format(context),
        'stop': ploaieStop?.format(context),
      }
          : null,
      'lucrari': lucrari,
      'materiale': materiale,
      'utilaje': utilaje,
      'personal': personal,
      'observatii': observatiiCtrl.text,
      'necesarMaine': necesarMaineCtrl.text,
    };
  }

  // ---------------- WHATSAPP TEXT ----------------

  String buildWhatsappText() {
    final utilajeActive =
    utilaje.entries.where((e) => e.value > 0).toList();

    final personalActiv =
    personal.entries.where((e) => e.value > 0).toList();

    return '''
📋 Chestionar producție
Proiect: ${widget.project}
Data: $data
Inginer: ${widget.username}

🌦 Meteo: $meteo${meteo == 'Ploaie' && ploaieStart != null && ploaieStop != null
        ? ' (${ploaieStart!.format(context)} - ${ploaieStop!.format(context)})'
        : ''}

🛠 Lucrări:
${lucrari.isEmpty
        ? '- Nu sunt lucrări adăugate'
        : lucrari.map((l) => '- ${l['descriere']}: ${l['cantitate']} ${l['unitate']}').join('\n')}

📦 Materiale folosite:
${materiale.isEmpty
        ? '- Nu sunt materiale adăugate'
        : materiale.map((m) => '- ${m['material']}: ${m['cantitate']} ${m['unitate']}').join('\n')}

🏗 Utilaje:
${utilajeActive.isEmpty
        ? '- Nu s-au folosit utilaje'
        : utilajeActive.map((e) => '- ${e.key}: ${e.value}').join('\n')}

👷 Personal:
${personalActiv.isEmpty
        ? '- Nu este personal înregistrat'
        : personalActiv.map((e) => '- ${e.key}: ${e.value}').join('\n')}

📝 Observații:
${observatiiCtrl.text.isEmpty ? 'Nu sunt observații.' : observatiiCtrl.text}
📦 Necesar pentru mâine:
${necesarMaineCtrl.text.isEmpty ? 'Nu este specificat.' : necesarMaineCtrl.text}
''';
  }

  // ---------------- SALVARE ----------------

  Future<void> salveazaSiShare() async {
    final payload = buildPayload();

    try {
      final res = await http
          .post(
        Uri.parse(
            'https://shenna-clavate-hester.ngrok-free.dev/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200) {

        final text = buildWhatsappText();

        if (poze.isNotEmpty) {
          await Share.shareXFiles(
            poze,
            text: text,
          );
        } else {
          await Share.share(text);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('✅ Salvat și trimis pe WhatsApp')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('❌ Eroare server')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('❌ Nu se poate conecta la server')),
      );
    }
  }

  // ---------------- UI ----------------

  Widget section(String title, IconData icon, Widget child) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text('Chestionar producție')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // METEO
          section(
            'Condiții meteo',
            Icons.cloud,
            Column(children: [
              DropdownButton<String>(
                value: meteo,
                items: ['Senin', 'Ploaie']
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => meteo = v!),
              ),
              if (meteo == 'Ploaie')
                Row(
                  children: [
                    TextButton(
                      onPressed: () => pickTime(true),
                      child: Text(
                          'De la: ${ploaieStart?.format(context) ?? '--:--'}'),
                    ),
                    TextButton(
                      onPressed: () => pickTime(false),
                      child: Text(
                          'Până la: ${ploaieStop?.format(context) ?? '--:--'}'),
                    ),
                  ],
                )
            ]),
          ),

          // LUCRARI
          section('Lucrări', Icons.build, Column(children: [
            TextField(
              controller: descriereCtrl,
              textCapitalization:
              TextCapitalization.sentences,
              decoration:
              const InputDecoration(labelText: 'Descriere'),
            ),
            TextField(
              controller: cantitateCtrl,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: 'Cantitate'),
            ),
            DropdownButton<String>(
              value: unitate,
              items: [
                'Metri pătrați',
                'Metri cubi',
                'Metri liniari',
                'Bucăți',
                'Tone'
              ]
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => unitate = v!),
            ),
            TextField(
              controller: altaUnitateCtrl,
              decoration: const InputDecoration(
                  labelText: 'Altă unitate (opțional)'),
            ),
            ElevatedButton(
              onPressed: adaugaLucrare,
              child: const Text('Adaugă lucrare'),
            ),
            ...lucrari.asMap().entries.map((entry) {
              final index = entry.key;
              final l = entry.value;

              return Card(
                child: ListTile(
                  title: Text(l['descriere']),
                  subtitle: Text(
                      '${l['cantitate']} ${l['unitate']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () {
                      setState(() {
                        lucrari.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
          ])),

          // ================= MATERIALE UI =================
          section('Materiale folosite', Icons.inventory, Column(children: [
            TextField(
              controller: materialCtrl,
              textCapitalization:
              TextCapitalization.sentences,
              decoration:
              const InputDecoration(labelText: 'Material'),
            ),
            TextField(
              controller: materialCantCtrl,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: 'Cantitate'),
            ),
            DropdownButton<String>(
              value: materialUnitate,
              items: ['Bucăți', 'Metri','Metri patrati','Metri cubi', 'Tone', 'Kg']
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => materialUnitate = v!),
            ),

            TextField(
              controller: materialAltaUnitateCtrl,
              decoration: const InputDecoration(
                  labelText: 'Altă unitate (opțional)'),
            ),

            ElevatedButton(
              onPressed: adaugaMaterial,
              child: const Text('Adaugă material'),
            ),


                ...materiale.asMap().entries.map((entry) {
              final index = entry.key;
              final m = entry.value;

              return Card(
                child: ListTile(
                  title: Text(m['material']),
                  subtitle: Text(
                      '${m['cantitate']} ${m['unitate']}'
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        materiale.removeAt(index);
                      });
                    },
                  ),
                ),
              );
                }).toList(),

          ],
          ),
          ),


          // ================= POZE UI =================
          section('Adaugă poze', Icons.photo, Column(children: [
            ElevatedButton(
              onPressed: adaugaPoze,
              child: const Text('Selectează o poză'),
            ),
            Wrap(
              spacing: 8,
              children: poze.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Image.file(
                      File(entry.value.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => stergePoza(entry.key),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                );
              }).toList(),
            )
          ])),

          section(
            'Utilaje',
            Icons.agriculture,
            listaPlusMinus(utilaje, adaugaUtilajNou),
          ),

          section(
            'Personal',
            Icons.people,
            listaPlusMinus(personal, adaugaPersonalNou),
          ),

          section(
            'Observații',
            Icons.notes,
            TextField(
              controller: observatiiCtrl,
              textCapitalization:
              TextCapitalization.sentences,
              maxLines: 4,
              decoration: const InputDecoration(
                  border: OutlineInputBorder()),
            ),
          ),

          section(
            'Necesar pentru mâine',
            Icons.inventory_2,
            TextField(
              controller: necesarMaineCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ex: 20 m țeavă, 5 capace, ',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label:
            const Text('Salvează & Share WhatsApp'),
            onPressed: salveazaSiShare,
          ),
        ]),
      ),
    );
  }
}
