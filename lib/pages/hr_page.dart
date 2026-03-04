import 'package:flutter/material.dart';

class HrPage extends StatelessWidget {
  const HrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sectiuni = [
      'Salarizati',
      'Contracte',
      'Valabilitate',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('HR')),
      body: ListView.builder(
        itemCount: sectiuni.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sectiuni[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sectiune: ${sectiuni[index]}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
