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
    return const [
      Landmark(order: 1, name: 'INIZIO (STAZIONE)', description: 'Punto di partenza', latitude: 41.4847222, longitude: 13.83225),

      Landmark(order: 2, name: 'ATTRAVERSAMENTO 1 (St-Sc)', description: 'Attraversamento pedonale 1', latitude: 41.4846944, longitude: 13.8321111),
      Landmark(order: 3, name: 'ATTRAVERSAMENTO 1 (Sc-St)', description: 'Attraversamento pedonale 1 (ritorno)', latitude: 41.4847222, longitude: 13.8320833),

      Landmark(order: 4, name: 'ATTRAVERSAMENTO 2 (St-Sc)', description: 'Attraversamento pedonale 2', latitude: 41.48475, longitude: 13.8320833),
      Landmark(order: 5, name: 'ATTRAVERSAMENTO 2 (Sc-St)', description: 'Attraversamento pedonale 2 (ritorno)', latitude: 41.4848333, longitude: 13.8320556),

      Landmark(order: 6, name: 'ATTRAVERSAMENTO 3 (St-Sc)', description: 'Attraversamento pedonale 3', latitude: 41.48525, longitude: 13.8319167),
      Landmark(order: 7, name: 'ATTRAVERSAMENTO 3 (Sc-St)', description: 'Attraversamento pedonale 3 (ritorno)', latitude: 41.4853056, longitude: 13.8319167),

      Landmark(order: 8, name: 'ATTRAVERSAMENTO 4 (St-Sc)', description: 'Attraversamento pedonale 4', latitude: 41.4853333, longitude: 13.8318611),
      Landmark(order: 9, name: 'ATTRAVERSAMENTO 4 (Sc-St)', description: 'Attraversamento pedonale 4 (ritorno)', latitude: 41.4853056, longitude: 13.8316667),

      Landmark(order: 10, name: 'ATTRAVERSAMENTO 5 (St-Sc)', description: 'Attraversamento pedonale 5', latitude: 41.4850833, longitude: 13.8301111),
      Landmark(order: 11, name: 'ATTRAVERSAMENTO 5 (Sc-St)', description: 'Attraversamento pedonale 5 (ritorno)', latitude: 41.4850278, longitude: 13.8299444),

      Landmark(order: 12, name: 'ATTRAVERSAMENTO 6 (St-Sc)', description: 'Attraversamento pedonale 6', latitude: 41.48475, longitude: 13.8288333),
      Landmark(order: 13, name: 'ATTRAVERSAMENTO 6 (Sc-St)', description: 'Attraversamento pedonale 6 (ritorno)', latitude: 41.48475, longitude: 13.82875),

      Landmark(order: 14, name: 'ATTRAVERSAMENTO 7 (St-Sc)', description: 'Attraversamento pedonale 7', latitude: 41.4828889, longitude: 13.82625),
      Landmark(order: 15, name: 'ATTRAVERSAMENTO 7 (Sc-St)', description: 'Attraversamento pedonale 7 (ritorno)', latitude: 41.4827222, longitude: 13.8261389),

      Landmark(order: 16, name: 'ATTRAVERSAMENTO 8 (St-Sc)', description: 'Attraversamento pedonale 8', latitude: 41.4812778, longitude: 13.8259444),
      Landmark(order: 17, name: 'ATTRAVERSAMENTO 8 (Sc-St)', description: 'Attraversamento pedonale 8 (ritorno)', latitude: 41.4811667, longitude: 13.8259444),

      Landmark(order: 18, name: 'ATTRAVERSAMENTO 9 (St-Sc)', description: 'Attraversamento pedonale 9', latitude: 41.4784167, longitude: 13.8273611),
      Landmark(order: 19, name: 'ATTRAVERSAMENTO 9 (Sc-St)', description: 'Attraversamento pedonale 9 (ritorno)', latitude: 41.4783333, longitude: 13.8274167),

      Landmark(order: 20, name: 'ATTRAVERSAMENTO 10 (St-Sc)', description: 'Attraversamento pedonale 10', latitude: 41.4783056, longitude: 13.8274167),
      Landmark(order: 21, name: 'ATTRAVERSAMENTO 10 (Sc-St)', description: 'Attraversamento pedonale 10 (ritorno)', latitude: 41.4784167, longitude: 13.8273611),

      Landmark(order: 22, name: 'ATTRAVERSAMENTO 11 (St-Sc)', description: 'Attraversamento pedonale 11', latitude: 41.4772778, longitude: 13.8276389),
      Landmark(order: 23, name: 'ATTRAVERSAMENTO 11 (Sc-St)', description: 'Attraversamento pedonale 11 (ritorno)', latitude: 41.4774444, longitude: 13.8275833),

      Landmark(order: 24, name: 'ATTRAVERSAMENTO 12 (St-Sc)', description: 'Attraversamento pedonale 12', latitude: 41.4762222, longitude: 13.8284167),
      Landmark(order: 25, name: 'ATTRAVERSAMENTO 12 (Sc-St)', description: 'Attraversamento pedonale 12 (ritorno)', latitude: 41.4762778, longitude: 13.8283333),

      Landmark(order: 26, name: 'ATTRAVERSAMENTO 13 (St-Sc)', description: 'Attraversamento pedonale 13', latitude: 41.4758333, longitude: 13.82925),
      Landmark(order: 27, name: 'ATTRAVERSAMENTO 13 (Sc-St)', description: 'Attraversamento pedonale 13 (ritorno)', latitude: 41.4758611, longitude: 13.829),

      Landmark(order: 28, name: 'ATTRAVERSAMENTO 14 (St-Sc)', description: 'Attraversamento pedonale 14', latitude: 41.4755, longitude: 13.8298889),
      Landmark(order: 29, name: 'ATTRAVERSAMENTO 14 (Sc-St)', description: 'Attraversamento pedonale 14 (ritorno)', latitude: 41.4755833, longitude: 13.8300278),

      Landmark(order: 30, name: 'ATTRAVERSAMENTO 15 (St-Sc)', description: 'Attraversamento pedonale 15', latitude: 41.4748889, longitude: 13.8294444),
      Landmark(order: 31, name: 'ATTRAVERSAMENTO 15 (Sc-St)', description: 'Attraversamento pedonale 15 (ritorno)', latitude: 41.4750556, longitude: 13.8296667),

      Landmark(order: 32, name: 'ATTRAVERSAMENTO 16 (St-Sc)', description: 'Attraversamento pedonale 16', latitude: 41.4688611, longitude: 13.8340833),
      Landmark(order: 33, name: 'ATTRAVERSAMENTO 16 (Sc-St)', description: 'Attraversamento pedonale 16 (ritorno)', latitude: 41.4689722, longitude: 13.8340833),

      Landmark(order: 34, name: 'ARRIVO (BIENNIO)', description: 'Arrivo sede Biennio', latitude: 41.4688333, longitude: 13.8341111),
      Landmark(order: 35, name: 'ARRIVO (TRIENNIO)', description: 'Arrivo sede Triennio', latitude: 41.4686389, longitude: 13.8322778),
    ];
  }
}
