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
      label: 'Cimitero Polacco',
      password: 'pass5',
      lat: 41.47781906390782,
      lng: 13.826406429123592,
      placeName: 'Cimitero Militare Polacco',
      placeDescription:
          'Il Cimitero Militare Polacco di Cassino accoglie le spoglie di oltre '
          '1.000 soldati polacchi caduti durante la Battaglia di Cassino nel 1944. '
          'È uno dei luoghi più toccanti della città, dedicato ai soldati del II Corpo '
          'Polacco che combatterono sotto il generale Anders per la liberazione d\'Italia.',
      placeAddress: 'Via Sant\'Angelo, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Monte_Cassino_-_the_Polish_War_Cemetery_-_closer.JPG/960px-Monte_Cassino_-_the_Polish_War_Cemetery_-_closer.JPG',
    ),
    QrPoint(
      label: 'Abbazia di Montecassino',
      password: 'pass6',
      lat: 41.50350,
      lng: 13.81380,
      placeName: 'Abbazia di Montecassino',
      placeDescription:
          'L\'Abbazia di Montecassino, fondata da San Benedetto da Norcia nel 529 d.C., '
          'è uno dei monasteri più importanti e antichi del mondo occidentale. '
          'Distrutta più volte e sempre ricostruita, è simbolo di resilienza e fede. '
          'Dichiarata patrimonio storico e artistico, domina il Monte Cairo con vista '
          'panoramica sulla Valle del Liri.',
      placeAddress: 'Via Montecassino, Montecassino, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/MonteCassino_Abbey.jpg/960px-MonteCassino_Abbey.jpg',
    ),
    QrPoint(
      label: 'Parco Folcara',
      password: 'pass7',
      lat: 41.472449200349764,
      lng: 13.828219859628286,
      placeName: 'Parco e Pista Ciclabile Folcara',
      placeDescription:
          'L\'area verde di Folcara è il polmone verde di Cassino, attraversata dalla '
          'pista ciclabile che collega Via Ausonia al Sentiero Mastronardi. '
          'Un percorso ideale per chi ama la mobilità sostenibile e le passeggiate '
          'nella natura, con aree attrezzate per il tempo libero.',
      placeAddress: 'Via Ausonia / Sentiero Mastronardi, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Hills_Behind_Cassino_-_panoramio.jpg/960px-Hills_Behind_Cassino_-_panoramio.jpg',
    ),
    QrPoint(
      label: 'Università di Cassino',
      password: 'pass8',
      lat: 41.47220,
      lng: 13.82980,
      placeName: 'Università degli Studi di Cassino e del Lazio Meridionale',
      placeDescription:
          'L\'Università degli Studi di Cassino e del Lazio Meridionale (UNICAS) '
          'è un ateneo statale fondato nel 1979. Il campus principale si trova nella '
          'località Folcara e ospita i dipartimenti di Ingegneria, Economia, '
          'Lettere e Scienze. È un polo formativo di riferimento per tutto il Lazio meridionale.',
      placeAddress: 'Viale dell\'Università, Loc. Folcara, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/e/ec/Polo_Folcara.jpg',
    ),
    QrPoint(
      label: 'ITIS Majorana',
      password: 'pass9',
      lat: 41.46884,
      lng: 13.83426,
      placeName: 'ITIS "Ettore Majorana" di Cassino',
      placeDescription:
          'L\'Istituto Tecnico Industriale Statale "Ettore Majorana" di Cassino '
          'è uno dei principali istituti tecnici della provincia di Frosinone. '
          'Offre percorsi di studio in Informatica e Telecomunicazioni, Elettronica, '
          'Meccanica e altri indirizzi tecnici, formando ogni anno centinaia di studenti '
          'nel settore tecnologico e industriale.',
      placeAddress: 'Via G. Di Biasio, Cassino (FR)',
      placeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Cassino_2010-by-RaBoe-02.jpg/960px-Cassino_2010-by-RaBoe-02.jpg',
    ),
  ];
}
