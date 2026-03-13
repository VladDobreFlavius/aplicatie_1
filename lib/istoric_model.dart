class Istoric {

  String unealta;
  String persoana;
  DateTime dataStart;
  DateTime? dataStop;

  Istoric({
    required this.unealta,
    required this.persoana,
    required this.dataStart,
    this.dataStop,
  });

}

List<Istoric> istoricUnelte = [];