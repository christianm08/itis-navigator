class Landmark {
  final int order;
  final String name;
  final String description;
  final double latitude;
  final double longitude;

  const Landmark({
    required this.order,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  static List<Landmark> routeCsvPoints() {
    // Dati di esempio per i landmark dell'ITIS
    return [
      const Landmark(
        order: 1,
        name: 'Ingresso Principale',
        description: 'Entrata principale dell\'istituto',
        latitude: 41.4897,
        longitude: 13.8283,
      ),
      const Landmark(
        order: 2,
        name: 'Palestra',
        description: 'Area sportiva',
        latitude: 41.4900,
        longitude: 13.8290,
      ),
      // Aggiungi altri landmark se necessario
    ];
  }
}
