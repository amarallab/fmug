class Dissease {
  final String name;
  final String description;

  Dissease(Map<String, dynamic> data)
      : name = data["name"],
        description = data["description"];
}
