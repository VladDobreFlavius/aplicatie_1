import 'dart:convert';
import 'package:http/http.dart' as http;
import '../unealta_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {

  static const String baseUrl = "https://unealte-api.onrender.com";

  // GET UNELTE

  static Future<List<Unealta>> getUnelte() async {

    final prefs = await SharedPreferences.getInstance();

    try {

      final response = await http
          .get(Uri.parse("https://unealte-api.onrender.com/get_stoc"))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {

        List data = jsonDecode(response.body);

        // salvare cache local
        prefs.setString("cache_unelte", response.body);

        return data.map((e) => Unealta.fromJson(e)).toList();

      }

    } catch (_) {}

    // dacă serverul nu răspunde -> citim cache
    final cache = prefs.getString("cache_unelte");

    if (cache != null) {

      List data = jsonDecode(cache);

      return data.map((e) => Unealta.fromJson(e)).toList();

    }

    return [];

  }

  // SAVE UNEALTA

  static Future<void> saveUnealta(
      String unealta,
      String nume,
      DateTime data) async {

    try {

      await http.post(
        Uri.parse("$baseUrl/save_stoc"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "unealta": unealta,
          "nume": nume,
          "data": data.toString(),
        }),
      ).timeout(const Duration(seconds: 60));

    } catch (e) {

      print("Eroare saveUnealta: $e");

    }
  }

  // DELETE UNEALTA

  static Future<void> deleteUnealta(int id) async {

    try {

      await http.post(
        Uri.parse("$baseUrl/delete_tool"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      ).timeout(const Duration(seconds: 60));

    } catch (e) {

      print("Eroare deleteUnealta: $e");

    }
  }

}