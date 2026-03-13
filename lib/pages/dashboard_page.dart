import 'package:flutter/material.dart';
import '../../unealta_model.dart';

class DashboardPage extends StatelessWidget {

  const DashboardPage({super.key});

  Map<String,int> calculeazaStatistica() {

    Map<String,int> rezultat = {};

    for(var u in listaUnelte){

      rezultat[u.unealta] = (rezultat[u.unealta] ?? 0) + 1;

    }

    return rezultat;

  }

  @override
  Widget build(BuildContext context) {

    final stats = calculeazaStatistica();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Dashboard Scule"),
      ),

      body: ListView(

        children: stats.entries.map((e){

          return ListTile(

            title: Text(e.key),

            trailing: Text(
              e.value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

          );

        }).toList(),

      ),

    );

  }

}