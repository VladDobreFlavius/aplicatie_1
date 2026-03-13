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
    'dobrevlad': {
      'password': '123',
      'isAdmin': false,
      'departments': ['Productie','Administrativ']
    },

    'todoroctavian': {
      'password': 'tavi123',
      'isAdmin': false,
      'departments': ['Productie']
    },

    'bogdanlepadat': {
      'password': '1234',
      'isAdmin': true,
      'departments': ['Productie']
    },

    'eugenlepadat': {
      'password': '12345',
      'isAdmin': true,
      'departments': ['Productie']
    },

    'bogdan': {
      'password': '1',
      'isAdmin': true,
      'departments': ['Productie']
    },

    'paultodea': {
      'password': '1234',
      'isAdmin': false,
      'departments': ['Productie']
    },

    'adrianmaxim': {
      'password': '1234',
      'isAdmin': false,
      'departments': ['Productie']
    },

    'radudumitru': {
      'password': 'radu26',
      'isAdmin': false,
      'departments': ['Productie']
    },

    'taniadenisa': {
      'password': 'deni123',
      'isAdmin': false,
      'departments': ['Productie']
    },

    'alexandrucostea': {
      'password': 'alex1234',
      'isAdmin': false,
      'departments': ['Productie']
    },

    'ionutiacsa': {
      'password': 'ionut1234',
      'isAdmin': false,
      'departments': ['Administrativ']
    },
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

    setState(() {
      darkMode = value;
    });
  }

  Future<void> _login() async {

    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = "Completează toate câmpurile");
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
        error = "Username sau parolă greșită";
        loading = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('username', username);
    await prefs.setBool('isAdmin', users[username]!['isAdmin']);

    await prefs.setStringList(
      'departments',
      List<String>.from(users[username]!['departments']),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DepartmentsPage(
          username: username,
          isAdmin: users[username]!['isAdmin'],
          departments: List<String>.from(users[username]!['departments']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final gradient = darkMode
        ? const LinearGradient(
        colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight)
        : const LinearGradient(
        colors: [Color(0xff667eea), Color(0xff764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 420,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: darkMode
                    ? Colors.black.withOpacity(0.35)
                    : Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 15),
                  )
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// LOGO
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
                      ),
                    ),
                    child: const Icon(
                      Icons.factory,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Sun Aqua",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "Production System",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// DARK MODE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dark_mode),
                      const SizedBox(width: 6),
                      const Text("Dark Mode"),
                      Switch(
                        value: darkMode,
                        onChanged: _toggleTheme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// USERNAME
                  TextField(
                    controller: _userCtrl,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3b82f6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "© Sun Aqua Industrial System",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}