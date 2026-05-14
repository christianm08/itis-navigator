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
      label: 'Piazzale Stazione',
      password: 'pass1',
      lat: 41.48483058959342,
      lng: 13.83213562732474,
      placeName: 'Piazzale Stazione',
      placeDescription:
          'Piazza centrale di Cassino. Punto di riferimento storico e sociale '
          'della città, circondata da edifici storici e attività commerciali. '
          'La piazza ospita eventi culturali e mercati locali durante tutto l\'anno.',
      placeAddress: 'Piazzale Stazione, Cassino (FR)',
      placeImageUrl:
          'https://www.luceweb.eu/wp-content/uploads/2025/07/250318_Cassino_%C2%A9Stefano-Anzini_IMG_7643-HDR_Hi.jpg',
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
          'https://www.comune.cassino.fr.it/it-it/immagine/img-56160-O-36-1687-0-0-35216660025c8651c959ba162d206dcc',
    ),
    QrPoint(
      label: 'Terme Romane',
      password: 'pass3',
      lat: 41.48320703366475,
      lng: 13.831191489793465,
      placeName: 'Terme Varroniane di Cassino',
      placeDescription:
          'Le antiche terme varroniane di Cassino (Casinum) risalgono al periodo imperiale. '
          'Erano un luogo di incontro sociale e igiene pubblica fondamentale '
          'per la vita quotidiana della città romana. I resti ancora visibili '
          'testimoniano la grandezza dell\'antica civiltà romana nel territorio.',
      placeAddress: 'Via delle Terme, Cassino (FR)',
      placeImageUrl:
          'https://cdn-media.italiani.it/site-cassino/sites/67/2020/09/terme-varroniane-terme-romane.jpg',
    ),
    QrPoint(
      label: 'Rocca Janula',
      password: 'pass4',
      lat: 41.49571539606111,
      lng: 13.825049033341385,
      placeName: 'Rocca Janula',
      placeDescription:
          'La Rocca Janula è una fortezza medievale del X secolo situata a Cassino,' 
          'costruita dall\'abate Aligerno per difendere l\'Abbazia di Montecassino.' 
          'Arroccata su una rupe, è dominata da una celebre torre pentagonale e'
          'rappresenta oggi un importante sito storico e panoramico visitabile.',
      placeAddress: 'Via Rocca Janula, Cassino (FR)',
      placeImageUrl:
          'https://www.comune.cassino.fr.it/de-de/immagine/img-58117-O-36-1687-0-0-b0a57d5f944e65069b0604af91c7a4d5',
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
      lat: 41.4978911,
      lng: 13.8050766,
      placeName: 'Abbazia di Montecassino',
      placeDescription:
          'L\'Abbazia di Montecassino, fondata da San Benedetto da Norcia nel 529 d.C., '
          'è uno dei monasteri più importanti e antichi del mondo occidentale. '
          'Distrutta più volte e sempre ricostruita, è simbolo di resilienza e fede. '
          'Dichiarata patrimonio storico e artistico, domina il Monte Cairo con vista '
          'panoramica sulla Valle del Liri.',
      placeAddress: 'Via Montecassino, Cassino (FR)',
      placeImageUrl:
          'https://content.storicang.it/medio/2022/07/25/lopera-di-ricostruzione-iniziata-con-la-posa-simbolica-della-prima-pietra-il-15-marzo-1945-ha-richiesto-circa-dieci-anni-di-lavori-labbazia-venne-nuovamente-consacrata-da-papa-paolo-vi-nel-1964_ce4de71d_1200x630.jpg',
    ),
    QrPoint(
      label: 'Università degli Studi di Cassino e del Lazio Meridionale',
      password: 'pass7',
      lat: 41.4745746,
      lng: 13.826098,
      placeName: 'Università degli Studi di Cassino e del Lazio Meridionale',
      placeDescription:
          'L\'Università di Cassino (UNICAS) è un ateneo statale fondato nel 1979. Offre corsi in ingegneria,'
          'economia, lettere, giurisprudenza e scienze umane nel moderno Campus della Folcara.'
          'Si distingue per il forte orientamento internazionale'
          'e l\'ottimo rapporto numerico tra studenti e docenti.',
      placeAddress: 'SP76, Cassino (FR)',
      placeImageUrl:
          'https://www.frosinonenews.eu/wp-content/uploads/2025/03/WhatsApp-Image-2025-03-02-at-19.12.35-e1741006221167.jpeg',
    ),
    QrPoint(
      label: 'Campus Folcara',
      password: 'pass8',
      lat: 41.472579593312105,
      lng: 13.828346672634332,
      placeName: 'Campus Folcara',
      placeDescription:
          'Il Campus Folcara dell\'Università degli Studi di Cassino e del Lazio Meridionale è un moderno polo universitario situato a Cassino (FR),' 
          'progettato secondo criteri di sostenibilità ambientale e inaugurato gradualmente a partire dal 2021.' 
          'Ospita il Rettorato, dipartimenti umanistici, sociali ed economici, oltre a residenze studentesche, impianti sportivi e biblioteche.',
      placeAddress: 'Viale dell\'Università, Loc. Folcara, Cassino (FR)',
      placeImageUrl:
          'https://cdn-media.italiani.it/site-cassino/sites/67/2022/08/test-di-ingresso-a-distanza-sede-folcara.jpg',
    ),
    QrPoint(
      label: 'ITIS Majorana triennio',
      password: 'pass9',
      lat: 41.468106050072905,
      lng: 13.831627482337437,
      placeName: 'ITIS "Ettore Majorana" di Cassino triennio',
      placeDescription:
          'L\'Istituto Tecnico Industriale Statale "Ettore Majorana" di Cassino '
          'è uno dei principali istituti tecnici della provincia di Frosinone. '
          'Offre percorsi di studio in Informatica e Telecomunicazioni, Elettronica, '
          'Meccanica e altri indirizzi tecnici, formando ogni anno centinaia di studenti '
          'nel settore tecnologico e industriale.',
      placeAddress: 'Via G. Di Biasio, Cassino (FR)',
      placeImageUrl:
          'https://cassinonotizie.com/wp-content/uploads/2023/08/IMG_7837.jpeg',
    ),
    
        QrPoint(
      label: 'ITIS Majorana biennio',
      password: 'pass10',
      lat: 41.46865106258019,
      lng: 13.834062356954897,
      placeName: 'ITIS "Ettore Majorana" di Cassino biennio',
      placeDescription:
          'L\'Istituto Tecnico Industriale Statale "Ettore Majorana" di Cassino '
          'è uno dei principali istituti tecnici della provincia di Frosinone. '
          'Offre percorsi di studio in Informatica e Telecomunicazioni, Elettronica, '
          'Meccanica e altri indirizzi tecnici, formando ogni anno centinaia di studenti '
          'nel settore tecnologico e industriale.',
      placeAddress: 'Via G. Di Biasio, Cassino (FR)',
      placeImageUrl:
          'https://cassinonotizie.com/wp-content/uploads/2020/04/itis.png',
    ),
  ];
}
