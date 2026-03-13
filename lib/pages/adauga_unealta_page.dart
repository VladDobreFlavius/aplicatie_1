import 'package:flutter/material.dart';
import 'package:aplicatie_1/unealta_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AdaugaUnealtaPage extends StatefulWidget {
  const AdaugaUnealtaPage({super.key});

  @override
  State<AdaugaUnealtaPage> createState() => _AdaugaUnealtaPageState();
}

class _AdaugaUnealtaPageState extends State<AdaugaUnealtaPage> {

  final unealtaCtrl = TextEditingController();
  final numeCtrl = TextEditingController();
  final telefonCtrl = TextEditingController();

  DateTime? dataSelectata;
  TimeOfDay? oraSelectata;

  bool loading = false;

  String? categorieSelectata;

  List<String> categorii = [
    "Electrice",
    "Chei",
    "Surubelnite",
    "Masurare",
    "Altele"
  ];

  // ================= WHATSAPP =================

  Future<void> trimiteWhatsappShare(String mesaj) async {

    final url = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(mesaj)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }

  }

  // ================= SALVARE SERVER =================

  Future<void> salveazaPeServer(
      String unealta,
      String nume,
      DateTime data) async {

    final url = Uri.parse("https://unealte-api.onrender.com/save_stoc");

    try {

      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "unealta": unealta,
          "nume": nume,
          "data": data.toString(),
        }),
      ).timeout(const Duration(seconds: 60));

    } catch (e) {

      print("Eroare server: $e");

    }

  }

  // ================= SELECTARE DATA =================

  Future<void> selecteazaData(BuildContext context) async {

    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        dataSelectata = data;
      });
    }

  }

  // ================= SELECTARE ORA =================

  Future<void> selecteazaOra(BuildContext context) async {

    final TimeOfDay? ora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (ora != null) {
      setState(() {
        oraSelectata = ora;
      });
    }

  }

  // ================= SALVARE =================

  Future<void> salveaza() async {

    if (categorieSelectata == null ||
        unealtaCtrl.text.isEmpty ||
        numeCtrl.text.isEmpty ||
        telefonCtrl.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completează toate câmpurile")),
      );
      return;
    }

    if (dataSelectata == null || oraSelectata == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selectează data și ora")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final dataCompleta = DateTime(
      dataSelectata!.year,
      dataSelectata!.month,
      dataSelectata!.day,
      oraSelectata!.hour,
      oraSelectata!.minute,
    );

    await salveazaPeServer(
      unealtaCtrl.text,
      numeCtrl.text,
      dataCompleta,
    );

    listaUnelte.add(
      Unealta(
        id: listaUnelte.length + 1,
        unealta: unealtaCtrl.text,
        nume: numeCtrl.text,
        data: dataCompleta,
      ),
    );

    // WhatsApp confirmare
    String mesaj =
        "Unealtă predată\n\n"
        "Unealta: ${unealtaCtrl.text}\n"
        "Persoană: ${numeCtrl.text}\n"
        "Data: ${dataCompleta.day}/${dataCompleta.month}/${dataCompleta.year} "
        "${dataCompleta.hour}:${dataCompleta.minute}";

    await trimiteWhatsappShare(mesaj);

    unealtaCtrl.clear();
    numeCtrl.clear();
    telefonCtrl.clear();

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unealta a fost salvată ✔"),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);

  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adăugare Unealtă"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              value: categorieSelectata,
              decoration: const InputDecoration(
                labelText: "Categorie",
                border: OutlineInputBorder(),
              ),
              items: categorii.map((c) {

                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );

              }).toList(),
              onChanged: (value) {

                setState(() {
                  categorieSelectata = value;
                });

              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: unealtaCtrl,
              decoration: const InputDecoration(
                labelText: "Unealtă",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: numeCtrl,
              decoration: const InputDecoration(
                labelText: "Dată către",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: telefonCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Telefon",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: () => selecteazaData(context),
                  child: const Text("Selectează data"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () => selecteazaOra(context),
                  child: const Text("Selectează ora"),
                ),

              ],
            ),

            const SizedBox(height: 20),

            if (dataSelectata != null && oraSelectata != null)
              Text(
                "${dataSelectata!.day}/${dataSelectata!.month}/${dataSelectata!.year} "
                    "${oraSelectata!.format(context)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : salveaza,
              child: loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text("Salvează"),
            ),

          ],
        ),
      ),
    );

  }

}