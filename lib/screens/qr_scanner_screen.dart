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
    label: 'Punto 1',
    password: 'pass1',
    lat: 41.482421,
    lng: 13.825648,
    placeImageAsset: 'assets/place1.jpg',
    placeName: 'Stazione Centrale',
    placeAddress: 'Via Roma, 1',
    placeDescription: 'Questo è il primo punto di interesse del percorso turistico.',
  ),
  QrPoint(
    label: 'Punto 2',
    password: 'pass2',
    lat: 41.475818,
    lng: 13.828921,
    placeImageAsset: 'assets/place2.jpg',
    placeName: 'Piazza del Duomo',
    placeAddress: 'Via del Duomo, 10',
    placeDescription: 'Secondo punto con una vista panoramica spettacolare.',
  ),
  QrPoint(
    label: 'Punto 3',
    password: 'pass3',
    lat: 41.474282,
    lng: 13.828943,
    placeImageAsset: 'assets/place3.jpg',
    placeName: 'Museo Civico',
    placeAddress: 'Corso Garibaldi, 50',
    placeDescription: 'Il terzo punto conclude il percorso con una visita al museo.',
  ),
];
const _qrPoints = kQrPoints;

/// Raggio entro cui l'utente deve trovarsi per poter scansionare (metri)
const double _kScanRadius = 30.0;

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
  const QrPoint({
    required this.label,
    required this.password,
    required this.lat,
    required this.lng,
    this.placeImageAsset = '',
    this.placeName = '',
    this.placeAddress = '',
    this.placeDescription = '',
  });
  LatLng get latLng => LatLng(lat, lng);
}

// alias privato per comodità interna
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

  // ── GPS ─────────────────────────────────────
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

  // ── Markers mappa ────────────────────────────
  Set<Marker> _buildMarkers() {
    Theme.of(context);
    final markers = <Marker>{};

    // Marker stazione (verde)
    markers.add(Marker(
      markerId: const MarkerId('stazione'),
      position: _kStazione,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Stazione Ferroviaria', snippet: 'Partenza'),
    ));

    // Marker ITIS (blu)
    markers.add(Marker(
      markerId: const MarkerId('itis'),
      position: _kItis,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'ITIS E. Majorana', snippet: 'Arrivo'),
    ));

    // Marker punti QR (giallo = da sbloccare, viola = sbloccato)
    for (final p in _qrPoints) {
      final done = _unlocked.contains(p.label);
      markers.add(Marker(
        markerId: MarkerId('qr_${p.label}'),
        position: p.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          done ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueYellow,
        ),
        infoWindow: InfoWindow(
          title: p.label,
          snippet: done ? '✅ Sbloccato' : 'Scansiona il QR code',
        ),
        onTap: () {
          if (!done) {
            final nearby = _isNearby(p);
            if (nearby) {
              _openScanner(p);
            } else {
              final d = _distanceTo(p);
              final msg = d != null ? 'Sei a ${d.round()} m — avvicinati a ${_kScanRadius.round()} m' : 'GPS non disponibile';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(msg),
                duration: const Duration(seconds: 3),
              ));
            }
          }
        },
      ));
    }

    return markers;
  }

  // ── Apertura scanner ─────────────────────────
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
          'Hai scansionato tutti e 3 i punti del percorso dalla Stazione all\'ITIS. Ottimo lavoro!',
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

  // ── Build ────────────────────────────────────
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
          // App bar
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

          // Barra progresso
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

          // Mappa Google Maps
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

          // Legenda mappa
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

          // Lista punti
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
                          CameraUpdate.newCameraPosition(CameraPosition(target: p.latLng, zoom: 17))),
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
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
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
          Expanded(child: Text('GPS non disponibile', style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.shade800))),
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

  String _formatDistance(double d) => d < 1000 ? '${d.round()} m' : '${(d / 1000).toStringAsFixed(1)} km';

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
          color: isNearby ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
          blurRadius: 14, offset: const Offset(0, 6),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Row(children: [
          // Numero step
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
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(point.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(stateLabel, style: theme.textTheme.bodySmall?.copyWith(
              color: isUnlocked ? Colors.green.shade600 : isNearby ? theme.colorScheme.primary : Colors.grey.shade500,
              fontWeight: isNearby ? FontWeight.w600 : FontWeight.normal,
            )),
          ])),
          // Pulsante centra mappa
          IconButton(
            icon: Icon(Icons.map_rounded, color: theme.colorScheme.primary, size: 22),
            onPressed: onLocate,
            tooltip: 'Mostra sulla mappa',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Pulsante scan
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
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.check_rounded, color: Colors.green.shade700, size: 20),
            ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Wrapper pubblico per scansione multipla punti QR
// Usato dalla mappa di navigazione
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
// Pagina fotocamera QR — implementazione corretta
// con WidgetsBindingObserver per lifecycle
// ─────────────────────────────────────────────

class _SingleQrCameraPage extends StatefulWidget {
  final _QrPoint point;
  final VoidCallback onSuccess;
  const _SingleQrCameraPage({required this.point, required this.onSuccess});

  @override
  State<_SingleQrCameraPage> createState() => _SingleQrCameraPageState();
}

class _SingleQrCameraPageState extends State<_SingleQrCameraPage> with WidgetsBindingObserver {
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
      _showSuccess();
    } else {
      setState(() { _errorMsg = 'QR non valido per questo punto. Riprova.'; _processing = false; });
      unawaited(_ctrl.start());
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          const Text('✅', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Expanded(child: Text('${widget.point.label} sbloccato!')),
        ]),
        content: Text('Hai scansionato correttamente il QR code del ${widget.point.label}.'),
        actions: [
          ElevatedButton(onPressed: widget.onSuccess, child: const Text('Continua')),
        ],
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
          // Torcia
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
        // Camera stream
        MobileScanner(controller: _ctrl),

        // Overlay mirino
        Center(
          child: CustomPaint(
            painter: _ScannerOverlayPainter(borderColor: theme.colorScheme.primary),
            child: const SizedBox(width: 260, height: 260),
          ),
        ),

        // Istruzione in alto
        Positioned(
          top: 32, left: 20, right: 20,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
              child: Text(
                'Inquadra il QR code del ${widget.point.label}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(color: Colors.red.shade700.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(14)),
                child: Text(_errorMsg!, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ]),
        ),

        // Spinner durante elaborazione
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
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => old.borderColor != borderColor;
}
