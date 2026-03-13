import 'package:flutter/material.dart';
import 'package:aplicatie_1/unealta_model.dart';

class CautareUnealtaPage extends StatefulWidget {
  const CautareUnealtaPage({super.key});

  @override
  State<CautareUnealtaPage> createState() => _CautareUnealtaPageState();
}

class _CautareUnealtaPageState extends State<CautareUnealtaPage> {

  final searchCtrl = TextEditingController();

  List<Unealta> rezultate = [];

  void cauta(String text) {

    setState(() {

      rezultate = listaUnelte.where((u) {

        return u.unealta.toLowerCase().contains(text.toLowerCase()) ||
            u.nume.toLowerCase().contains(text.toLowerCase());

      }).toList();

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Căutare Unealtă"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: "Caută unealtă sau nume",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: cauta,
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: rezultate.length,
                itemBuilder: (context, index) {

                  final u = rezultate[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            u.unealta,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "${u.nume} - "
                                "${u.data.day}/${u.data.month}/${u.data.year} "
                                "${u.data.hour}:${u.data.minute}",
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [

                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    u.nume = "";
                                    u.status = "disponibila";
                                  });
                                },
                                child: const Text("Retur"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                onPressed: () {
                                  final ctrl = TextEditingController();

                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text("Transfer unealtă"),
                                        content: TextField(
                                          controller: ctrl,
                                          decoration: const InputDecoration(
                                            labelText: "Persoană",
                                          ),
                                        ),
                                        actions: [

                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Anulează"),
                                          ),

                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                u.nume = ctrl.text;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Salvează"),
                                          ),

                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text("Transfer"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    listaUnelte.remove(u);
                                    rezultate.removeAt(index);
                                  });
                                },
                                child: const Text("Șterge"),
                              ),

                            ],
                          ),

                        ],
                      ),
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}