import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_provider.dart';

// Coordinate fisse per i punti di partenza e arrivo del percorso
const _kStazione = LatLng(41.485302, 13.831859);
const _kItis     = LatLng(41.468840, 13.834258);

// Stile mappa scura, usato quando il tema dell'app è dark
const String _darkMapStyle = r'['
  r'{"elementType":"geometry","stylers":[{"color":"#212121"}]},'
  r'{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},'
  r'{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},'
  r'{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},'
  r'{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},'
  r'{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},'
  r'{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},'
  r'{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},'
  r'{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},'
  r'{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},'
  r'{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},'
  r'{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},'
  r'{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},'
  r'{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},'
  r'{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},'
  r'{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},'
  r'{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},'
  r'{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},'
  r'{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},'
  r'{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}'
  r']';

/// Lista dei punti QR del percorso da Stazione a ITIS.
/// Ogni punto corrisponde a un luogo di interesse di Cassino.
const kQrPoints = [
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
  // Punto 8: Università degli Studi di Cassino — campus Folcara (Rettorato)
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
  // Punto 9: ITIS Ettore Majorana — istituto tecnico industriale di Cassino
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

// Raggio in metri entro cui l'utente è considerato "vicino" a un punto QR
const double _kScanRadius = 200.0;

// Chiave SharedPreferences per salvare i punti sbloccati
const _kPrefsKey = 'qr_unlocked_points';

// ─── Modello ────────────────────────────────────────────────────────────────────────────────

/// Rappresenta un singolo punto QR del percorso.
class QrPoint {
  final String label;           // Nome visualizzato nella UI
  final String password;        // Stringa attesa dal QR code
  final double lat;
  final double lng;
  final String placeName;       // Titolo esteso del luogo
  final String placeDescription;
  final String placeAddress;
  final String placeImageUrl;   // URL remota immagine Wikimedia

  const QrPoint({
    required this.label,
    required this.password,
    required this.lat,
    required this.lng,
    this.placeName = '',
    this.placeDescription = '',
    this.placeAddress = '',
    this.placeImageUrl = '',
  });

  /// Conversione rapida a LatLng per Google Maps
  LatLng get latLng => LatLng(lat, lng);

  /// Retrocompatibilità con map_navigation_screen (asset locali non usati)
  String get placeImageAsset => '';
}

// ─── Screen principale: mappa + lista ─────────────────────────────────────────────

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  Position?   _position;       // Posizione GPS corrente dell'utente
  bool        _loadingGps = true;
  Set<String> _unlocked = {};  // Label dei punti già sbloccati (da SharedPreferences)
  bool        _loadingPrefs = true;

  GoogleMapController? _mapController;

  // Centro di Cassino usato come fallback se il GPS non è disponibile
  static const _cassinoCenter = LatLng(41.476, 13.829);

  @override
  void initState() {
    super.initState();
    _loadSaved();    // Carica i punti sbloccati salvati
    _fetchPosition(); // Avvia il rilevamento GPS
  }

  /// Legge da SharedPreferences i punti già sbloccati in sessioni precedenti.
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kPrefsKey) ?? [];
    if (mounted) setState(() { _unlocked = Set.from(saved); _loadingPrefs = false; });
  }

  /// Persiste su SharedPreferences i punti attualmente sbloccati.
  Future<void> _saveUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPrefsKey, _unlocked.toList());
  }

  /// Mostra un dialogo di conferma e, se confermato, azzera il progresso.
  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Resetta progresso'),
        content: const Text('Vuoi davvero azzerare tutti i punti sbloccati?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetta'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _unlocked = {});
      await _saveUnlocked();
    }
  }

  /// Richiede il permesso GPS e aggiorna la posizione corrente.
  Future<void> _fetchPosition() async {
    setState(() => _loadingGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingGps = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 10));
      if (mounted) setState(() { _position = pos; _loadingGps = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  /// Calcola la distanza in metri tra l'utente e il punto [p].
  /// Ritorna null se il GPS non è disponibile.
  double? _distanceTo(QrPoint p) {
    if (_position == null) return null;
    return Geolocator.distanceBetween(
        _position!.latitude, _position!.longitude, p.lat, p.lng);
  }

  /// True se l'utente si trova entro [_kScanRadius] metri dal punto [p].
  bool _isNearby(QrPoint p) {
    final d = _distanceTo(p);
    return d != null && d <= _kScanRadius;
  }

  /// Costruisce i [Marker] da mostrare sulla mappa Google.
  ///
  /// Colori usati:
  /// - 🟢 Verde   → Stazione (partenza)
  /// - 🔵 Blu     → ITIS (arrivo)
  /// - 🟢 Verde   → Punto QR già sbloccato
  /// - 🔴 Rosso   → Punto QR non ancora sbloccato
  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Marker stazione di partenza
    markers.add(Marker(
      markerId: const MarkerId('stazione'),
      position: _kStazione,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Stazione Ferroviaria', snippet: 'Partenza'),
    ));

    // Marker ITIS di arrivo
    markers.add(Marker(
      markerId: const MarkerId('itis'),
      position: _kItis,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'ITIS E. Majorana', snippet: 'Arrivo'),
    ));

    // Marker per ciascun punto QR del percorso
    for (final p in kQrPoints) {
      final done = _unlocked.contains(p.label);

      markers.add(Marker(
        markerId: MarkerId('qr_${p.label}'),
        position: p.latLng,
        // Verde se sbloccato, rosso se ancora da scansionare
        icon: BitmapDescriptor.defaultMarkerWithHue(
          done ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: p.label,
          snippet: done ? '✅ Sbloccato' : '🔴 Da scansionare',
        ),
        onTap: () {
          // Se non ancora sbloccato, centra la mappa sul punto toccato
          if (!done) {
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(CameraPosition(target: p.latLng, zoom: 17)),
            );
          }
        },
      ));
    }
    return markers;
  }

  /// Applica lo stile scuro alla mappa se il tema dell'app è dark.
  void _applyMapStyle(GoogleMapController c) {
    final isDark = context.read<ThemeProvider>().isDark;
    c.setMapStyle(isDark ? _darkMapStyle : null);
  }

  /// Apre la pagina della fotocamera QR per il punto [point].
  Future<void> _openScanner(QrPoint point) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => QrCameraPage(
          points: kQrPoints,
          unlockedLabels: _unlocked,
          onUnlock: (label) {
            setState(() => _unlocked.add(label));
            _saveUnlocked();
            // Se tutti i punti sono sbloccati mostra il dialogo di completamento
            if (_unlocked.length == kQrPoints.length) {
              Future.delayed(const Duration(milliseconds: 300), _showCompletionDialog);
            }
          },
        ),
      ),
    );
  }

  /// Mostra il bottom sheet con le informazioni del luogo [point]
  /// senza sbloccare il punto (modalità "anteprima" per utenti vicini).
  void _showPlaceInfo(QrPoint point) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceInfoSheet(
        point: point,
        // Mostra semplicemente "Chiudi" senza sbloccare il punto
        onContinue: () => Navigator.pop(context),
        previewOnly: true,
      ),
    );
  }

  /// Mostra il dialogo di completamento percorso quando tutti i punti sono sbloccati.
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          Text('🎉', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Text('Percorso completato!'),
        ]),
        content: Text(
          'Hai scansionato tutti e ${kQrPoints.length} i punti del percorso '
          'dalla Stazione all\'ITIS. Ottimo lavoro!',
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Torna alla Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Usa la posizione GPS se disponibile, altrimenti centra su Cassino
    final camPos = _position != null
        ? LatLng(_position!.latitude, _position!.longitude)
        : _cassinoCenter;

    // Mostra uno spinner finché non sono caricati i dati salvati
    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar collassabile con contatore progresso ──
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded),
                tooltip: 'Resetta progresso',
                onPressed: _resetProgress,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Percorso QR  ${_unlocked.length}/${kQrPoints.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.primary, cs.secondary],
                  ),
                ),
              ),
            ),
          ),

          // ── Barra progresso + banner GPS ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Progresso',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${(_unlocked.length / kQrPoints.length * 100).round()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.bold),
                  ),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: kQrPoints.isEmpty ? 0 : _unlocked.length / kQrPoints.length,
                    backgroundColor: cs.onSurface.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
                const SizedBox(height: 14),
                _GpsStatusBanner(
                    loading: _loadingGps, position: _position, onRefresh: _fetchPosition),
                const SizedBox(height: 14),
              ]),
            ),
          ),

          // ── Mappa Google ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: camPos, zoom: 14.5),
                    markers: _buildMarkers(),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (c) {
                      _mapController = c;
                      _applyMapStyle(c);
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── Legenda colori mappa ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
              child: Wrap(spacing: 16, runSpacing: 4, children: [
                _LegendDot(color: Colors.green.shade600, label: 'Stazione / Sbloccato'),
                _LegendDot(color: Colors.blue.shade600, label: 'ITIS (arrivo)'),
                _LegendDot(color: Colors.red.shade600, label: 'Da scansionare'),
              ]),
            ),
          ),

          // ── Lista card punti QR ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = kQrPoints[i];
                  final dist = _distanceTo(p);
                  final nearby = _isNearby(p);
                  final done = _unlocked.contains(p.label);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _QrPointCard(
                      point: p,
                      index: i,
                      distance: dist,
                      isNearby: nearby,
                      isUnlocked: done,
                      onLocate: () => _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(target: p.latLng, zoom: 17)),
                      ),
                      onScan: () => _openScanner(p),
                      // Callback per mostrare le info senza scansionare
                      onInfo: () => _showPlaceInfo(p),
                    ),
                  );
                },
                childCount: kQrPoints.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Camera QR ────────────────────────────────────────────────────────────────────────────

class QrCameraPage extends StatefulWidget {
  final List<QrPoint> points;
  final Set<String> unlockedLabels;
  final void Function(String label) onUnlock;

  const QrCameraPage({
    super.key,
    required this.points,
    required this.unlockedLabels,
    required this.onUnlock,
  });

  @override
  State<QrCameraPage> createState() => _QrCameraPageState();
}

class _QrCameraPageState extends State<QrCameraPage>
    with WidgetsBindingObserver {
  MobileScannerController? _ctrl;
  StreamSubscription<Object?>? _subscription;
  bool _processing = false; // True mentre viene verificato un QR appena letto
  String? _errorMsg;
  bool _started = false;    // True dopo che la fotocamera è avviata correttamente

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  /// Inizializza e avvia il controller della fotocamera.
  void _startCamera() {
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _subscription = _ctrl!.barcodes.listen(_onBarcode);
    _ctrl!.start().then((_) {
      if (mounted) setState(() => _started = true);
    }).catchError((e) {
      debugPrint('Camera start error: $e');
      if (mounted) {
        setState(() {
          _errorMsg = 'Impossibile avviare la fotocamera. '
              'Controlla i permessi nelle impostazioni.';
        });
      }
    });
  }

  /// Callback invocata ogni volta che lo scanner rileva un barcode.
  void _onBarcode(BarcodeCapture capture) {
    if (_processing) return; // Ignora nuovi scan mentre si elabora il precedente
    final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    setState(() { _processing = true; _errorMsg = null; });
    _ctrl?.stop();

    // Cerca il punto corrispondente alla password letta dal QR
    final matched = widget.points.cast<QrPoint?>().firstWhere(
      (p) => p!.password.trim() == raw,
      orElse: () => null,
    );

    if (matched == null) {
      // QR non appartenente al percorso
      setState(() {
        _errorMsg = 'QR non riconosciuto. Assicurati di scansionare '
            'uno dei QR code del percorso.';
        _processing = false;
      });
      _ctrl?.start();
      return;
    }

    if (widget.unlockedLabels.contains(matched.label)) {
      // Punto già sbloccato in precedenza
      setState(() {
        _errorMsg = '${matched.label} è già stato sbloccato!';
        _processing = false;
      });
      _ctrl?.start();
      return;
    }

    // QR valido e non ancora sbloccato: mostra le info del luogo
    _showSuccess(matched);
  }

  /// Mostra il bottom sheet con le informazioni del luogo appena sbloccato.
  void _showSuccess(QrPoint point) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceInfoSheet(
        point: point,
        previewOnly: false, // Modalità sblocco: il bottone registra il punto
        onContinue: () {
          widget.onUnlock(point.label);
          Navigator.pop(context); // Chiude il bottom sheet
          Navigator.pop(context); // Torna alla lista punti
        },
      ),
    );
  }

  /// Gestisce la pausa/ripresa della fotocamera al cambio di stato dell'app.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = ctrl.barcodes.listen(_onBarcode);
        unawaited(ctrl.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(ctrl.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _subscription?.cancel();
    _subscription = null;
    super.dispose();
    await _ctrl?.dispose();
    _ctrl = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Scansiona QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Bottone torcia: visibile solo quando la fotocamera è attiva
          if (_ctrl != null)
            ValueListenableBuilder(
              valueListenable: _ctrl!,
              builder: (_, state, __) {
                final torch = state.torchState;
                return IconButton(
                  icon: Icon(
                    torch == TorchState.on
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: torch == TorchState.on ? Colors.yellow : Colors.white,
                  ),
                  onPressed: () => _ctrl?.toggleTorch(),
                  tooltip: 'Torcia',
                );
              },
            ),
        ],
      ),
      body: Stack(children: [
        // ── Preview fotocamera o messaggio errore ──
        if (_ctrl != null && _errorMsg == null)
          MobileScanner(controller: _ctrl!)
        else if (_errorMsg != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.camera_alt_rounded, color: Colors.white54, size: 72),
                const SizedBox(height: 20),
                Text(_errorMsg!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _errorMsg = null; _started = false; });
                    _startCamera();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Riprova'),
                ),
              ]),
            ),
          )
        else
          // Spinner di avvio fotocamera
          const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Avvio fotocamera...', style: TextStyle(color: Colors.white70)),
            ]),
          ),

        // ── Mirino di scansione sovrapposto alla preview ──
        if (_ctrl != null && _errorMsg == null)
          Center(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(borderColor: theme.colorScheme.primary),
              child: const SizedBox(width: 260, height: 260),
            ),
          ),

        // ── Istruzioni e messaggi di errore in alto ──
        Positioned(
          top: 32,
          left: 20,
          right: 20,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.black54, borderRadius: BorderRadius.circular(16)),
              child: const Text(
                'Inquadra un QR code del percorso',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            if (_errorMsg != null && _started) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.red.shade700.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14)),
                child: Text(_errorMsg!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ]),
        ),

        // ── Overlay di caricamento durante la verifica del QR ──
        if (_processing)
          Container(
            color: Colors.black45,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 14),
                Text('Verifica...',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface)),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ─── Legenda ────────────────────────────────────────────────────────────────────────────────

/// Singolo elemento della legenda mappa (pallino colorato + etichetta).
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

// ─── Banner GPS ─────────────────────────────────────────────────────────────────────────

/// Banner che mostra lo stato del GPS (caricamento / non disponibile / attivo).
class _GpsStatusBanner extends StatelessWidget {
  final bool loading;
  final Position? position;
  final VoidCallback onRefresh;
  const _GpsStatusBanner(
      {required this.loading, required this.position, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (loading) {
      // Stato: rilevamento in corso
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Rilevamento GPS...',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500, color: cs.onPrimaryContainer)),
        ]),
      );
    }
    if (position == null) {
      // Stato: GPS non disponibile o permesso negato
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.orange.shade900.withValues(alpha: 0.35)
              : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? Colors.orange.shade700 : Colors.orange.shade200),
        ),
        child: Row(children: [
          Icon(Icons.location_off_rounded,
              size: 18,
              color: isDark ? Colors.orange.shade300 : Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text('GPS non disponibile — puoi comunque scansionare',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.orange.shade300 : Colors.orange.shade800)),
          ),
          IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
              onPressed: onRefresh,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
        ]),
      );
    }
    // Stato: GPS attivo con precisione
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green.shade900.withValues(alpha: 0.35)
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.green.shade700 : Colors.green.shade200),
      ),
      child: Row(children: [
        Icon(Icons.my_location_rounded,
            size: 18,
            color: isDark ? Colors.green.shade400 : Colors.green.shade700),
        const SizedBox(width: 10),
        Text('GPS attivo — precisione ${position!.accuracy.round()} m',
            style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.green.shade400 : Colors.green.shade800)),
      ]),
    );
  }
}

// ─── Card punto ─────────────────────────────────────────────────────────────────────────────

/// Card che rappresenta un singolo punto QR nella lista.
///
/// Stati visivi:
/// - Verde con bordo verde → punto già sbloccato
/// - Bordo primario evidenziato → utente nelle vicinanze, pronto per scansionare
/// - Stile neutro → punto distante
class _QrPointCard extends StatelessWidget {
  final QrPoint point;
  final int index;
  final double? distance;   // Distanza in metri, null se GPS non disponibile
  final bool isNearby;      // True se l'utente è entro il raggio di scansione
  final bool isUnlocked;    // True se il punto è già stato sbloccato
  final VoidCallback onLocate; // Centra la mappa su questo punto
  final VoidCallback onScan;   // Apre la fotocamera QR
  final VoidCallback onInfo;   // Mostra info del luogo senza scansionare

  const _QrPointCard({
    required this.point,
    required this.index,
    required this.distance,
    required this.isNearby,
    required this.isUnlocked,
    required this.onLocate,
    required this.onScan,
    required this.onInfo,
  });

  /// Formatta la distanza in metri o km.
  String _fmt(double d) =>
      d < 1000 ? '${d.round()} m' : '${(d / 1000).toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Colori del bordo e dell'icona in base allo stato
    Color borderColor;
    Color iconBg;
    Color iconTextColor;

    if (isUnlocked) {
      borderColor = isDark ? Colors.green.shade600 : Colors.green.shade300;
      iconBg = isDark
          ? Colors.green.shade900.withValues(alpha: 0.5)
          : Colors.green.shade100;
      iconTextColor = isDark ? Colors.green.shade400 : Colors.green.shade700;
    } else if (isNearby) {
      borderColor = cs.primary;
      iconBg = cs.primaryContainer;
      iconTextColor = cs.primary;
    } else {
      borderColor = isDark
          ? cs.onSurface.withValues(alpha: 0.18)
          : Colors.grey.shade200;
      iconBg = isDark
          ? cs.onSurface.withValues(alpha: 0.08)
          : Colors.grey.shade100;
      iconTextColor = isDark
          ? cs.onSurface.withValues(alpha: 0.4)
          : Colors.grey.shade500;
    }

    // Testo di stato mostrato sotto il nome del punto
    final stateLabel = isUnlocked
        ? '✅ Completato'
        : isNearby
            ? '📡 Sei vicino — pronto per scansionare!'
            : distance != null
                ? '📍 A ${_fmt(distance!)} da qui'
                : '📍 GPS non disponibile';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: isNearby ? 2 : 1.2),
        boxShadow: [
          BoxShadow(
            color: isNearby
                ? cs.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Row(children: [
          // Pallino con numero o check
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: isUnlocked
                ? Icon(Icons.check_rounded, color: iconTextColor, size: 22)
                : Text('${index + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: iconTextColor)),
          ),
          const SizedBox(width: 14),

          // Nome e stato del punto
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(point.label,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(stateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? (isDark ? Colors.green.shade400 : Colors.green.shade600)
                        : isNearby
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.45),
                    fontWeight: isNearby ? FontWeight.w600 : FontWeight.normal,
                  )),
            ]),
          ),

          // Bottone: centra mappa sul punto
          IconButton(
            icon: Icon(Icons.map_rounded, color: cs.primary, size: 22),
            onPressed: onLocate,
            tooltip: 'Mostra sulla mappa',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),

          // Bottone info: mostra descrizione del luogo (solo se vicino o sbloccato)
          if (isNearby || isUnlocked) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.info_outline_rounded,
                  color: isUnlocked
                      ? (isDark ? Colors.green.shade400 : Colors.green.shade600)
                      : cs.primary,
                  size: 22),
              onPressed: onInfo,
              tooltip: 'Informazioni sul luogo',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],

          const SizedBox(width: 4),

          // Bottone scan o check se già completato
          if (!isUnlocked)
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isNearby
                    ? cs.primary
                    : cs.primary.withValues(alpha: 0.7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green.shade900.withValues(alpha: 0.5)
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.check_rounded,
                  color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                  size: 20),
            ),
        ]),
      ),
    );
  }
}

// ─── Painter mirino ────────────────────────────────────────────────────────────────────

/// Disegna il mirino a quattro angoli sovrapposto alla preview della fotocamera.
class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  const _ScannerOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerLen = 36.0;
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    // Angolo in alto a sinistra
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, cornerLen), paint);

    // Angolo in alto a destra
    canvas.drawLine(r.topRight, r.topRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, cornerLen), paint);

    // Angolo in basso a sinistra
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -cornerLen), paint);

    // Angolo in basso a destra
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -cornerLen), paint);

    // Linea orizzontale centrale (guida di mira)
    final linePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.8;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => old.borderColor != borderColor;
}

// ─── Bottom Sheet info luogo ────────────────────────────────────────────────────────────

/// Bottom sheet trascinabile che mostra nome, immagine e descrizione di un luogo.
///
/// [previewOnly] = true  → bottone "Chiudi" (anteprima senza sbloccare il punto)
/// [previewOnly] = false → bottone "Continua" che registra il punto come sbloccato
class _PlaceInfoSheet extends StatelessWidget {
  final QrPoint point;
  final VoidCallback onContinue;
  final bool previewOnly; // Se true non sblocca il punto, mostra solo info

  const _PlaceInfoSheet({
    required this.point,
    required this.onContinue,
    this.previewOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasImage = point.placeImageUrl.isNotEmpty;
    final name = point.placeName.isNotEmpty ? point.placeName : point.label;

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle di trascinamento
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  // Badge di stato: sbloccato o anteprima
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: previewOnly
                            ? (isDark
                                ? Colors.blue.shade900.withValues(alpha: 0.4)
                                : Colors.blue.shade50)
                            : (isDark
                                ? Colors.green.shade900.withValues(alpha: 0.4)
                                : Colors.green.shade50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: previewOnly
                                ? (isDark ? Colors.blue.shade600 : Colors.blue.shade300)
                                : (isDark ? Colors.green.shade600 : Colors.green.shade300)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            previewOnly
                                ? Icons.info_outline_rounded
                                : Icons.check_circle_rounded,
                            color: previewOnly
                                ? (isDark ? Colors.blue.shade400 : Colors.blue.shade600)
                                : (isDark ? Colors.green.shade400 : Colors.green.shade600),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            previewOnly
                                ? 'Sei vicino a ${point.label}'
                                : '${point.label} sbloccato!',
                            style: TextStyle(
                                color: previewOnly
                                    ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
                                    : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Immagine del luogo con gestione loading/errore
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasImage
                        ? Image.network(
                            point.placeImageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            headers: const {
                              'User-Agent': 'ITISNavigatorApp/1.0 (educational project; Flutter)',
                              'Referer': 'https://it.wikipedia.org/',
                            },
                            loadingBuilder: (_, child, progress) => progress == null
                                ? child
                                : _buildImageSkeleton(theme),
                            errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),
                  ),
                  const SizedBox(height: 20),

                  // Nome del luogo
                  Text(name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Indirizzo con icona
                  if (point.placeAddress.isNotEmpty) ...[
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 18,
                          color: cs.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(point.placeAddress,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                      ),
                    ]),
                    const SizedBox(height: 16),
                  ],

                  Divider(color: cs.onSurface.withValues(alpha: 0.1), height: 1),
                  const SizedBox(height: 16),

                  // Descrizione estesa del luogo
                  Text(
                    point.placeDescription.isNotEmpty
                        ? point.placeDescription
                        : 'Descrizione non ancora disponibile.',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: cs.onSurface.withValues(alpha: 0.85), height: 1.6),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Bottone fisso in fondo: "Chiudi" in anteprima, "Continua" dopo scan
            Container(
              padding: EdgeInsets.only(
                  left: 24, right: 24, top: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12, offset: const Offset(0, -4)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onContinue,
                  icon: Icon(previewOnly
                      ? Icons.close_rounded
                      : Icons.arrow_forward_rounded),
                  label: Text(previewOnly ? 'Chiudi' : 'Continua'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton animato mostrato durante il caricamento dell'immagine.
  Widget _buildImageSkeleton(ThemeData theme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  /// Placeholder mostrato quando l'immagine non è disponibile o non si carica.
  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.image_rounded,
            size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        Text('Immagine non disponibile',
            style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}
