import 'package:flutter/material.dart';
import 'login_page.dart';
import 'productie_page.dart';
import 'hr_page.dart';
import 'administrativ_page.dart';

class DepartmentsPage extends StatelessWidget {
  final bool isAdmin;
  final String username;
  final List<String> departments;

  const DepartmentsPage({
    super.key,
    required this.isAdmin,
    required this.username,
    required this.departments,
  });

  Widget departmentCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: enabled ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: enabled ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: enabled ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (!enabled)
                const Chip(
                  label: Text('LOCKED'),
                  backgroundColor: Colors.grey,
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamente'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              child: Text(
                username.substring(0, 1).toUpperCase(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          /// PRODUCTIE
          departmentCard(
            context: context,
            title: 'Producție',
            description: 'Chestionare zilnice, utilaje, personal',
            icon: Icons.factory,
            enabled: isAdmin || departments.contains("Productie"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductiePage(
                    username: username,
                    isAdmin: isAdmin,
                  )
                ),
              );
            },
          ),

          /// HR
          departmentCard(
            context: context,
            title: 'HR',
            description: 'Salarizați, contracte, valabilitate',
            icon: Icons.people,
            enabled: isAdmin,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HrPage(),
                ),
              );
            },
          ),

          /// MECANIZARE
          departmentCard(
            context: context,
            title: 'Mecanizare',
            description: 'Evidență utilaje și mentenanță',
            icon: Icons.agriculture,
            enabled: false,
            onTap: () {},
          ),

          /// IT
          departmentCard(
            context: context,
            title: 'IT',
            description: 'Sisteme interne și suport',
            icon: Icons.computer,
            enabled: false,
            onTap: () {},
          ),

          /// ADMINISTRATIV
          departmentCard(
            context: context,
            title: 'Administrativ',
            description: 'Achiziții și stoc',
            icon: Icons.admin_panel_settings,
            enabled: isAdmin || departments.contains("Administrativ"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdministrativPage(),
                  ),
                );
              },

          ),
        ],
      ),
    );
  }
}
