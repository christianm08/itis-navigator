import 'package:google_maps_flutter/google_maps_flutter.dart';

/// QR code checkpoint point with associated information
class QrPoint {
  /// Display label for the checkpoint
  final String label;
  
  /// Password/code for QR validation
  final String password;
  
  /// Latitude
  final double lat;
  
  /// Longitude
  final double lng;
  
  /// Coordinate object
  LatLng get latLng => LatLng(lat, lng);
  
  /// Place name
  final String placeName;
  
  /// Place description
  final String placeDescription;
  
  /// Place address
  final String placeAddress;
  
  /// Place image URL
  final String placeImageUrl;

  const QrPoint({
    required this.label,
    required this.password,
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.placeDescription,
    required this.placeAddress,
    required this.placeImageUrl,
  });
}

/// QR checkpoint coordinates along the route from Station to ITIS
class QrCheckpoints {
  QrCheckpoints._();

  static const kQrPoints = [
    QrPoint(
      label: 'Piazza Garibaldi',
      password: 'pass1',
      lat: 41.48483058959342,
      lng: 13.83213562732474,
      placeName: 'Piazza Garibaldi',
      placeDescription:
          'Piazza centrale di Cassino, dedicata a Giuseppe Garibaldi, '
          'eroe del Risorgimento italiano. Punto di riferimento storico e sociale '
          'della città, circondata da edifici storici e attività commerciali. '
          'La piazza ospita eventi culturali e mercati locali durante tutto l\'anno.',
      placeAddress: 'Piazza Giuseppe Garibaldi, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Piazza_Garibaldi_G.jpg/960px-Piazza_Garibaldi_G.jpg',
    ),
    QrPoint(
      label: 'Anfiteatro Romano',
      password: 'pass2',
      lat: 41.48402685411911,
      lng: 13.824518154061039,
      placeName: 'Anfiteatro Romano di Cassino',
      placeDescription:
          'Antico anfiteatro romano risalente all\'epoca imperiale, testimonianza '
          'del ricco passato della città di Casinum. I resti dell\'anfiteatro sono '
          'visibili nell\'area archeologica e rappresentano uno dei monumenti '
          'più significativi della storia romana di Cassino.',
      placeAddress: 'Zona archelogica, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/9/98/Anfiteatro_romano_cassino.jpg',
    ),
    QrPoint(
      label: 'Terme Romane',
      password: 'pass3',
      lat: 41.48320703366475,
      lng: 13.831191489793465,
      placeName: 'Terme Romane di Cassino',
      placeDescription:
          'Le antiche terme romane di Cassino (Casinum) risalgono al periodo imperiale. '
          'Erano un luogo di incontro sociale e igiene pubblica fondamentale '
          'per la vita quotidiana della città romana. I resti ancora visibili '
          'testimoniano la grandezza dell\'antica civiltà romana nel territorio.',
      placeAddress: 'Via delle Terme, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Cassino008.jpg/960px-Cassino008.jpg',
    ),
    QrPoint(
      label: 'Museo Storico della Battaglia',
      password: 'pass4',
      lat: 41.49571539606111,
      lng: 13.825049033341385,
      placeName: 'Museo Storico della Battaglia di Cassino',
      placeDescription:
          'Il Museo Storico della Battaglia di Cassino racconta la storia delle quattro '
          'Battaglie di Cassino (1943–1944), tra le più sanguinose della Seconda Guerra '
          'Mondiale. Il museo conserva armi, documenti, fotografie e reperti bellici '
          'che testimoniano il sacrificio di soldati di numerose nazioni.',
      placeAddress: 'Via Rocca Janula, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Cassino_-_Cassino_Museo_Arte_Contemporanea_-_2024-09-20_11-03-18_002.jpg/960px-Cassino_-_Cassino_Museo_Arte_Contemporanea_-_2024-09-20_11-03-18_002.jpg',
    ),
    QrPoint(
      label: 'Cattedrale di Cassino',
      password: 'pass5',
      lat: 41.48885397692469,
      lng: 13.822508833341388,
      placeName: 'Cattedrale di Cassino',
      placeDescription:
          'La Cattedrale di Cassino, dedicata a Santa Maria Assunta, è il principale '
          'luogo di culto della città. Ricostruita dopo la Seconda Guerra Mondiale, '
          'conserva importanti opere d\'arte e rappresenta il centro religioso '
          'della comunità cassinate.',
      placeAddress: 'Piazza cattedrale, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Cassino005.jpg/960px-Cassino005.jpg',
    ),
    QrPoint(
      label: 'Parco Archeologico',
      password: 'pass6',
      lat: 41.48373330821452,
      lng: 13.82515583334139,
      placeName: 'Parco Archeologico di Cassino',
      placeDescription:
          'Il Parco Archeologico di Cassino custodisce i resti dell\'antica città '
          'romana di Casinum. Tra le rovine si possono osservare il foro, i templi '
          'e altri edifici pubblici che testimoniano l\'importanza di questo '
          'insediamento nell\'antichità.',
      placeAddress: 'Via Monterone, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Cassino006.jpg/960px-Cassino006.jpg',
    ),
    QrPoint(
      label: 'Via Casilina',
      password: 'pass7',
      lat: 41.47802990405469,
      lng: 13.82748583334139,
      placeName: 'Via Casilina',
      placeDescription:
          'Via Casilina è un\'importante arteria stradale che collega Cassino '
          'con Roma. Anticamente ricalcava il percorso della via Latina, '
          'una delle più antiche vie consolari romane. Oggi è una strada '
          'commerciale molto trafficata.',
      placeAddress: 'Via Casilina, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Via_Casilina.jpg/960px-Via_Casilina.jpg',
    ),
    QrPoint(
      label: 'Piazza Alcide De Gasperi',
      password: 'pass8',
      lat: 41.47400990405469,
      lng: 13.82845583334139,
      placeName: 'Piazza Alcide De Gasperi',
      placeDescription:
          'Piazza dedicata ad Alcide De Gasperi, statista italiano e uno dei '
          'padri fondatori dell\'Unione Europea. La piazza è un punto di '
          'incontro importante per i cittadini di Cassino.',
      placeAddress: 'Piazza Alcide De Gasperi, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Piazza_De_Gasperi.jpg/960px-Piazza_De_Gasperi.jpg',
    ),
    QrPoint(
      label: 'ITIS E. Majorana',
      password: 'pass9',
      lat: 41.468840,
      lng: 13.834258,
      placeName: 'ITIS E. Majorana - Cassino',
      placeDescription:
          'L\'Istituto Tecnico Industriale Statale "Ettore Majorana" è una '
          'scuola secondaria di secondo grado di Cassino. Fondata per fornire '
          'una formazione tecnica di qualità, offre corsi in informatica, '
          'elettronica, meccanica e altri settori tecnologici.',
      placeAddress: 'Via S. Angelo, 2 - 03043 Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/ITIS_Majorana.jpg/960px-ITIS_Majorana.jpg',
    ),
  ];
}
