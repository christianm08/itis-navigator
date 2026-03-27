import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ─────────────────────────────────────────────
// Coordinate di riferimento del percorso
// Stazione: [41.485302, 13.831859]
// ITIS:      [41.468840, 13.834258]
// ─────────────────────────────────────────────

const _kStazione = LatLng(41.485302, 13.831859);
const _kItis     = LatLng(41.468840, 13.834258);

/// Lista pubblica dei punti QR — usata anche da MapNavigationScreen
const kQrPoints = [
  QrPoint(
    label: 'Tappa 1',
    password: 'pass1',
    lat: 41.482421,
    lng: 13.825648,
    placeImageAsset: 'assets/place1.jpg',
    placeName: 'Piazza De Gasperi',
    placeAddress: 'Piazza Alcide De Gasperi, Cassino (FR)',
    placeDescription:
        'Cuore del centro moderno di Cassino, la piazza ospita il celebre '
        'carro armato Sherman M4 e un cannone da 105 mm — simboli della '
        'Battaglia di Cassino (1943-44) durante la quale la città fu '
        'completamente rasa al suolo dalla Linea Gustav. Oggi è luogo di '
        'ritrovo e punto di riferimento della vita cittadina.',
    placeInfo: [
      _PlaceInfo(icon: Icons.history_edu_rounded,    label: 'Periodo',   value: 'Ricostruita 1945-1960'),
      _PlaceInfo(icon: Icons.military_tech_rounded,  label: 'Monumento', value: 'Carro armato Sherman M4'),
      _PlaceInfo(icon: Icons.directions_walk_rounded, label: 'Distanza dalla stazione', value: '~900 m · 12 min a piedi'),
    ],
  ),
  QrPoint(
    label: 'Tappa 2',
    password: 'pass2',
    lat: 41.475818,
    lng: 13.828921,
    placeImageAsset: 'assets/place2.jpg',
    placeName: 'Via Bellini — Zona Scolastica',
    placeAddress: 'Via Vincenzo Bellini, Cassino (FR)',
    placeDescription:
        'Asse viario che attraversa il quartiere scolastico di Cassino, '
        'a pochi passi dalla Scuola Media Statale e dagli istituti superiori. '
        'Il nome ricorda il compositore siciliano Vincenzo Bellini. '
        'La zona è anche servita dalla fermata bus COTRAL che collega '
        'la stazione ferroviaria con gli istituti scolastici.',
    placeInfo: [
      _PlaceInfo(icon: Icons.school_rounded,          label: 'Zona',       value: 'Quartiere scolastico'),
      _PlaceInfo(icon: Icons.directions_bus_rounded,  label: 'Bus COTRAL', value: 'Fermata Via Bellini'),
      _PlaceInfo(icon: Icons.directions_walk_rounded, label: 'Distanza da Tappa 1', value: '~700 m · 9 min a piedi'),
    ],
  ),
  QrPoint(
    label: 'Tappa 3',
    password: 'pass3',
    lat: 41.474282,
    lng: 13.828943,
    placeImageAsset: 'assets/place3.jpg',
    placeName: 'ITIS E. Majorana',
    placeAddress: 'Via G. Labriola, Cassino (FR)',
    placeDescription:
        'L\'Istituto Tecnico Industriale "Ettore Majorana" di Cassino, '
        'intitolato al fisico siciliano scomparso misteriosamente nel 1938. '
        'Offre indirizzi in Informatica e Telecomunicazioni, Elettronica, '
        'Meccanica e Meccatronica. È servito dalla fermata COTRAL '
        'Viale Garigliano/Via Volturno a soli 4 minuti a piedi.',
    placeInfo: [
      _PlaceInfo(icon: Icons.science_rounded,         label: 'Intitolato a', value: 'Ettore Majorana (1906-1938)'),
      _PlaceInfo(icon: Icons.computer_rounded,        label: 'Indirizzo',    value: 'Informatica & Telecomunicazioni'),
      _PlaceInfo(icon: Icons.directions_bus_rounded,  label: 'Bus COTRAL',  value: 'Viale Garigliano · 4 min'),
    ],
  ),
];
const _qrPoints = kQrPoints;

/// Raggio entro cui l'utente deve trovarsi per poter scansionare (metri)
const double _kScanRadius = 30.0;

// ─────────────────────────────────────────────
// Modello info aggiuntiva per il posto
// ─────────────────────────────────────────────

class _PlaceInfo {
  final IconData icon;
  final String label;
  final String value;
  const _PlaceInfo({required this.icon, required this.label, required this.value});
}

// ─────────────────────────────────────────────
// Modello punto QR
// ─────────────────────────────────────────────

class QrPoint {
  final String label;
  final String password;
  final double lat;
  final double lng;
  final String placeImageAsset;
  final String placeName;
  final String placeAddress;
  final String placeDescription;
  final List<_PlaceInfo> placeInfo;

  const QrPoint({
    required this.label,
    required this.password,
    required this.lat,
    required this.lng,
    this.placeImageAsset = '',
    this.placeName = '',
    this.placeAddress = '',
    this.placeDescription = '',
    this.placeInfo = const [],
  });

  LatLng get latLng => LatLng(lat, lng);
}

typedef _QrPoint = QrPoint;

// ─────────────────────────────────────────────
// Screen principale: mappa + lista punti
// ─────────────────────────────────────────────

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  Position?  _position;
  bool       _loadingGps = true;
  final Set<String> _unlocked = {};

  GoogleMapController? _mapController;
  static const _cassinoCenter = LatLng(41.476, 13.829);

  @override
  void initState() {
    super.initState();
    _fetchPosition();
  }

  Future<void> _fetchPosition() async {
    setState(() => _loadingGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _loadingGps = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) setState(() { _position = pos; _loadingGps = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  double? _distanceTo(_QrPoint p) {
    if (_position == null) return null;
    return Geolocator.distanceBetween(_position!.latitude, _position!.longitude, p.lat, p.lng);
  }

  bool _isNearby(_QrPoint p) {
    final d = _distanceTo(p);
    return d != null && d <= _kScanRadius;
  }

  Set<Marker> _buildMarkers() {
    Theme.of(context);
    final markers = <Marker>{};
    markers.add(Marker(
      markerId: const MarkerId('stazione'),
      position: _kStazione,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Stazione Ferroviaria', snippet: 'Partenza'),
    ));
    markers.add(Marker(
      markerId: const MarkerId('itis'),
      position: _kItis,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'ITIS E. Majorana', snippet: 'Arrivo'),
    ));
    for (final p in _qrPoints) {
      final done = _unlocked.contains(p.label);
      markers.add(Marker(
        markerId: MarkerId('qr_${p.label}'),
        position: p.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          done ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueYellow,
        ),
        infoWindow: InfoWindow(
          title: p.placeName,
          snippet: done ? '✅ Sbloccato' : 'Scansiona il QR code',
        ),
        onTap: () {
          if (!done) {
            final nearby = _isNearby(p);
            if (nearby) {
              _openScanner(p);
            } else {
              final d = _distanceTo(p);
              final msg = d != null
                  ? 'Sei a ${d.round()} m — avvicinati a ${_kScanRadius.round()} m'
                  : 'GPS non disponibile';
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
            }
          }
        },
      ));
    }
    return markers;
  }

  Future<void> _openScanner(_QrPoint point) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _SingleQrCameraPage(
          point: point,
          onSuccess: () {
            Navigator.pop(context);
            _onUnlock(point.label);
          },
        ),
      ),
    );
  }

  void _onUnlock(String label) {
    setState(() => _unlocked.add(label));
    if (_unlocked.length == _qrPoints.length) {
      Future.delayed(const Duration(milliseconds: 300), _showCompletionDialog);
    }
  }

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
        content: const Text(
          'Hai scansionato tutte e 3 le tappe del percorso '
          'dalla Stazione all\'ITIS E. Majorana. Ottimo lavoro!',
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
    final camPos = _position != null
        ? LatLng(_position!.latitude, _position!.longitude)
        : _cassinoCenter;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Percorso QR  ${_unlocked.length}/${_qrPoints.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 56),
                    child: Row(children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Text('Stazione → ITIS',
                            style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text('Tocca un punto giallo sulla mappa per scansionare',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Progresso', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text('${(_unlocked.length / _qrPoints.length * 100).round()}%',
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: _qrPoints.isEmpty ? 0 : _unlocked.length / _qrPoints.length,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 14),
                _GpsStatusBanner(loading: _loadingGps, position: _position, onRefresh: _fetchPosition),
                const SizedBox(height: 14),
              ]),
            ),
          ),
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
                    onMapCreated: (c) => _mapController = c,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
              child: Wrap(spacing: 16, children: [
                _LegendDot(color: Colors.green.shade600, label: 'Stazione'),
                _LegendDot(color: Colors.blue.shade600, label: 'ITIS'),
                _LegendDot(color: Colors.amber.shade700, label: 'Da scansionare'),
                _LegendDot(color: Colors.purple.shade400, label: 'Sbloccato'),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = _qrPoints[i];
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
                      loadingGps: _loadingGps,
                      onLocate: () => _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                              CameraPosition(target: p.latLng, zoom: 17))),
                      onScan: () => _openScanner(p),
                    ),
                  );
                },
                childCount: _qrPoints.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget legenda mappa
// ─────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

// ─────────────────────────────────────────────
// Banner stato GPS
// ─────────────────────────────────────────────

class _GpsStatusBanner extends StatelessWidget {
  final bool loading;
  final Position? position;
  final VoidCallback onRefresh;
  const _GpsStatusBanner({required this.loading, required this.position, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Rilevamento GPS...', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ]),
      );
    }
    if (position == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(children: [
          Icon(Icons.location_off_rounded, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text('GPS non disponibile',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.shade800))),
          IconButton(icon: const Icon(Icons.refresh, size: 18), color: Colors.orange.shade700,
              onPressed: onRefresh, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(children: [
        Icon(Icons.my_location_rounded, size: 18, color: Colors.green.shade700),
        const SizedBox(width: 10),
        Text('GPS attivo — precisione ${position!.accuracy.round()} m',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.green.shade800)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Card singolo punto QR
// ─────────────────────────────────────────────

class _QrPointCard extends StatelessWidget {
  final _QrPoint point;
  final int index;
  final double? distance;
  final bool isNearby;
  final bool isUnlocked;
  final bool loadingGps;
  final VoidCallback onLocate;
  final VoidCallback onScan;

  const _QrPointCard({
    required this.point, required this.index, required this.distance,
    required this.isNearby, required this.isUnlocked, required this.loadingGps,
    required this.onLocate, required this.onScan,
  });

  String _formatDistance(double d) =>
      d < 1000 ? '${d.round()} m' : '${(d / 1000).toStringAsFixed(1)} km';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color borderColor;
    Color iconBg;

    if (isUnlocked) {
      borderColor = Colors.green.shade300;
      iconBg = Colors.green.shade100;
    } else if (isNearby) {
      borderColor = theme.colorScheme.primary;
      iconBg = theme.colorScheme.primaryContainer;
    } else {
      borderColor = Colors.grey.shade200;
      iconBg = Colors.grey.shade100;
    }

    final stateLabel = isUnlocked
        ? '✅ Completato'
        : isNearby
            ? '📡 Pronto per la scansione!'
            : distance != null
                ? '📍 A ${_formatDistance(distance!)} da qui'
                : '📍 Posizione non disponibile';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: isNearby ? 2 : 1.2),
        boxShadow: [BoxShadow(
          color: isNearby
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.06),
          blurRadius: 14, offset: const Offset(0, 6),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Riga superiore con numero, nome, bottoni
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: isUnlocked
                  ? Icon(Icons.check_rounded, color: Colors.green.shade700, size: 22)
                  : Text('${index + 1}', style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17,
                      color: isNearby ? theme.colorScheme.primary : Colors.grey.shade500)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(point.placeName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(point.label,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
              const SizedBox(height: 3),
              Text(stateLabel, style: theme.textTheme.bodySmall?.copyWith(
                color: isUnlocked
                    ? Colors.green.shade600
                    : isNearby
                        ? theme.colorScheme.primary
                        : Colors.grey.shade500,
                fontWeight: isNearby ? FontWeight.w600 : FontWeight.normal,
              )),
            ])),
            IconButton(
              icon: Icon(Icons.map_rounded, color: theme.colorScheme.primary, size: 22),
              onPressed: onLocate,
              tooltip: 'Mostra sulla mappa',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            if (!isUnlocked)
              ElevatedButton.icon(
                onPressed: (isNearby || loadingGps) ? onScan : null,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: const Text('Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNearby ? theme.colorScheme.primary : Colors.grey.shade200,
                  foregroundColor: isNearby ? Colors.white : Colors.grey.shade400,
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
                    color: Colors.green.shade100, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.check_rounded, color: Colors.green.shade700, size: 20),
              ),
          ]),
        ),
        // Indirizzo
        if (point.placeAddress.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Row(children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(child: Text(point.placeAddress,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500))),
            ]),
          ),
        // Descrizione breve
        if (point.placeDescription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Text(
              point.placeDescription.length > 120
                  ? '${point.placeDescription.substring(0, 120)}…'
                  : point.placeDescription,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, height: 1.5),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Wrapper pubblico per scansione multipla punti QR
// ─────────────────────────────────────────────

class QrCameraPage extends StatefulWidget {
  final List<QrPoint> points;
  final Set<String> unlockedLabels;
  final Function(String) onUnlock;

  const QrCameraPage({
    required this.points,
    required this.unlockedLabels,
    required this.onUnlock,
  });

  @override
  State<QrCameraPage> createState() => _QrCameraPageState();
}

class _QrCameraPageState extends State<QrCameraPage> {
  late int _currentPointIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentPoint = widget.points[_currentPointIndex];
    return _SingleQrCameraPage(
      point: currentPoint,
      onSuccess: () {
        widget.onUnlock(currentPoint.label);
        if (_currentPointIndex < widget.points.length - 1) {
          setState(() => _currentPointIndex++);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

// ─────────────────────────────────────────────
// Pagina fotocamera QR
// ─────────────────────────────────────────────

class _SingleQrCameraPage extends StatefulWidget {
  final _QrPoint point;
  final VoidCallback onSuccess;
  const _SingleQrCameraPage({required this.point, required this.onSuccess});

  @override
  State<_SingleQrCameraPage> createState() => _SingleQrCameraPageState();
}

class _SingleQrCameraPageState extends State<_SingleQrCameraPage>
    with WidgetsBindingObserver {
  late final MobileScannerController _ctrl;
  StreamSubscription<Object?>? _subscription;
  bool _processing = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ctrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _subscription = _ctrl.barcodes.listen(_onBarcode);
    unawaited(_ctrl.start());
  }

  void _onBarcode(BarcodeCapture capture) {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    setState(() { _processing = true; _errorMsg = null; });
    unawaited(_ctrl.stop());

    if (raw.trim() == widget.point.password.trim()) {
      _showSuccessSheet();
    } else {
      setState(() { _errorMsg = 'QR non valido per questa tappa. Riprova.'; _processing = false; });
      unawaited(_ctrl.start());
    }
  }

  // ── Info Sheet post-scansione ────────────────
  void _showSuccessSheet() {
    final p = widget.point;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99)),
                ),
              ),

              // Badge successo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text('${p.label} sbloccata!',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: Colors.green.shade700)),
                    ]),
                  ),
                ]),
              ),

              // Immagine del posto
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: p.placeImageAsset.isNotEmpty
                      ? Image.asset(
                          p.placeImageAsset,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ImagePlaceholder(name: p.placeName),
                        )
                      : _ImagePlaceholder(name: p.placeName),
                ),
              ),

              // Nome e indirizzo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.placeName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 15, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(child: Text(p.placeAddress,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
                  ]),
                ]),
              ),

              // Info pill chips
              if (p.placeInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: p.placeInfo.map((info) => _InfoChip(info: info)).toList(),
                  ),
                ),

              // Descrizione
              if (p.placeDescription.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Storia e curiosità',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(p.placeDescription,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6)),
                  ]),
                ),

              // Bottone Continua
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // chiude sheet
                      widget.onSuccess();      // avanza navigazione
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continua'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_ctrl.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = _ctrl.barcodes.listen(_onBarcode);
        unawaited(_ctrl.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_ctrl.stop());
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await _ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Scansiona — ${widget.point.label}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          ValueListenableBuilder(
            valueListenable: _ctrl,
            builder: (_, state, __) {
              final torch = state.torchState;
              return IconButton(
                icon: Icon(
                  torch == TorchState.on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: torch == TorchState.on ? Colors.yellow : Colors.white,
                ),
                onPressed: () => _ctrl.toggleTorch(),
                tooltip: 'Torcia',
              );
            },
          ),
        ],
      ),
      body: Stack(children: [
        MobileScanner(controller: _ctrl),
        Center(
          child: CustomPaint(
            painter: _ScannerOverlayPainter(borderColor: theme.colorScheme.primary),
            child: const SizedBox(width: 260, height: 260),
          ),
        ),
        Positioned(
          top: 32, left: 20, right: 20,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
              child: Text(
                'Inquadra il QR code — ${widget.point.placeName}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.red.shade700.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14)),
                child: Text(_errorMsg!, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ]),
        ),
        if (_processing)
          Container(
            color: Colors.black45,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 14),
                const Text('Verifica...', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Chip info (icona + label + valore)
// ─────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final _PlaceInfo info;
  const _InfoChip({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(info.icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(info.label,
              style: TextStyle(fontSize: 10, color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600)),
          Text(info.value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Placeholder immagine (quando asset non presente)
// ─────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  final String name;
  const _ImagePlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.place_rounded, size: 52, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        Text(name,
            style: TextStyle(color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Text('Immagine non disponibile',
            style: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.6), fontSize: 12)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Painter mirino scanner
// ─────────────────────────────────────────────

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
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, cornerLen), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, cornerLen), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -cornerLen), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -cornerLen), paint);

    final linePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.8;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => old.borderColor != borderColor;
}
