class Unealta {

  int id;
  String unealta;
  String nume;
  DateTime data;
  String status;

  Unealta({
    required this.id,
    required this.unealta,
    required this.nume,
    required this.data,
    this.status = "imprumutata",
  });

  // CONVERT JSON -> OBJECT
  factory Unealta.fromJson(Map<String, dynamic> json) {

    DateTime parsedDate;

    try {
      parsedDate = DateTime.parse(json["data"]);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Unealta(
      id: json["id"],
      unealta: json["unealta"],
      nume: json["nume"],
      data: parsedDate,
      status: json["status"] ?? "imprumutata",
    );
  }

  // CONVERT OBJECT -> JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "unealta": unealta,
      "nume": nume,
      "data": data.toIso8601String(),
      "status": status,
    };
  }

}

List<Unealta> listaUnelte = [];