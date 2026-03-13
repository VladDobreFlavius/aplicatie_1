import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../unealta_model.dart';
import '../services/api_service.dart';
import 'adauga_unealta_page.dart';
import 'cautare_unealta_page.dart';
import 'dashboard_page.dart';

class AdministrativPage extends StatefulWidget {
  const AdministrativPage({super.key});

  @override
  State<AdministrativPage> createState() => _AdministrativPageState();
}

class _AdministrativPageState extends State<AdministrativPage> {

  bool loading = true;

  @override
  void initState() {
    super.initState();
    incarcaUnelte();
  }

  Future<void> incarcaUnelte() async {


    try {

    setState(() {
    loading = true;
    });

    listaUnelte.clear();

    final data = await ApiService.getUnelte();

    listaUnelte.addAll(data);

    } catch (e) {

    print("Eroare incarcaUnelte: $e");

    }

    if (!mounted) return;

    setState(() {
    loading = false;
    });


  }

// ================= EXPORT EXCEL =================

  Future<void> exportExcel() async {


    final url = Uri.parse(
    "https://unealte-api.onrender.com/export_excel",
    );

    if (await canLaunchUrl(url)) {
    await launchUrl(url);
    }


  }

// RETUR

  void retur(int index){


    setState(() {

    listaUnelte[index].nume = "";
    listaUnelte[index].status = "disponibila";

    });


  }

// TRANSFER

  void transfer(int index){


    final ctrl = TextEditingController();

    showDialog(
    context: context,
    builder: (context){

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
    onPressed: (){
    Navigator.pop(context);
    },
    child: const Text("Anulează"),
    ),

    TextButton(
    onPressed: (){

    setState(() {
    listaUnelte[index].nume = ctrl.text;
    });

    Navigator.pop(context);

    },
    child: const Text("Salvează"),
    ),

    ],

    );

    },
    );


  }

// DELETE

  void sterge(int index) async {


    final id = listaUnelte[index].id;

    await ApiService.deleteUnealta(id);

    setState(() {
    listaUnelte.removeAt(index);
    });


  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

    appBar: AppBar(
    title: const Text("Administrativ"),
    actions: [

    IconButton(
    icon: const Icon(Icons.table_view),
    tooltip: "Export Excel",
    onPressed: exportExcel,
    ),

    ],
    ),

    body: loading
    ? const Center(child: CircularProgressIndicator())
        : Column(

    children: [

    const SizedBox(height:10),

    // BUTOANELE DE SUS

    Row(

    mainAxisAlignment: MainAxisAlignment.center,

    children: [

    ElevatedButton(

    onPressed: () async {

    await Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => const AdaugaUnealtaPage(),
    ),
    );

    incarcaUnelte();

    },

    child: const Text("Adăugare"),

    ),

    const SizedBox(width:10),

    ElevatedButton(

    onPressed: () {

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => const CautareUnealtaPage(),
    ),
    );

    },

    child: const Text("Căutare"),

    ),

    const SizedBox(width:10),

    ElevatedButton(

    onPressed: () {

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => const DashboardPage(),
    ),
    );

    },

    child: const Text("Dashboard"),

    ),

    ],

    ),

    const SizedBox(height:20),

    Expanded(

    child: ListView.builder(

    itemCount: listaUnelte.length,

    itemBuilder: (_,index){

    final u = listaUnelte[index];

    return Card(

    margin: const EdgeInsets.all(10),

    child: Padding(

    padding: const EdgeInsets.all(12),

    child: Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

    Text(
    u.unealta,
    style: const TextStyle(
    fontSize:18,
    fontWeight:FontWeight.bold,
    ),
    ),

    const SizedBox(height:5),

    Text(
    u.nume.isEmpty
    ? "Disponibilă"
        : "La ${u.nume}",
    ),

    const SizedBox(height:10),

    ],

    ),

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
