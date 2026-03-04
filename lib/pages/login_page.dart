import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'departments_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool loading = false;
  bool darkMode = false;
  String? error;

  final Map<String, Map<String, dynamic>> users = {
    'dobrevlad': {'password': '123', 'isAdmin': false},
    'todoroctavian': {'password': 'tavi123', 'isAdmin': false},
    'bogdanlepadat': {'password': '1234', 'isAdmin': true},
    'eugenlepadat': {'password': '12345', 'isAdmin': true},
    'bogdan': {'password': '1', 'isAdmin': true},
    'paultodea': {'password': '1234', 'isAdmin': false},
    'adrianmaxim': {'password': '1234', 'isAdmin': false},
    'radudumitru': {'password': 'radu26', 'isAdmin': false},
    'taniadenisa': {'password': 'deni123', 'isAdmin': false},
  };

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => darkMode = value);

    // restart app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _login() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = 'Completează toate câmpurile');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!users.containsKey(username) ||
        users[username]!['password'] != password) {
      setState(() {
        error = 'Username sau parolă greșită';
        loading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('username', username);
    await prefs.setBool('isAdmin', users[username]!['isAdmin']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DepartmentsPage(
          username: username,
          isAdmin: users[username]!['isAdmin'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.factory,
                    size: 56,
                    color: isDark ? Colors.blue[200] : Colors.blue),
                const SizedBox(height: 8),
                const Text(
                  'Sun Aqua – Producție',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dark mode'),
                    Switch(value: darkMode, onChanged: _toggleTheme),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),

                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!,
                      style:
                      const TextStyle(color: Colors.red, fontSize: 14)),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
