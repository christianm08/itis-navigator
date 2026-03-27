import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStazione = LatLng(41.485302, 13.831859);
const _kItis     = LatLng(41.468840, 13.834258);

const kQrPoints = [
  QrPoint(
    label: 'Punto 1',
    password: 'pass1',
    lat: 41.482421,
    lng: 13.825648,
    placeName: 'Nome del luogo 1',
    placeDescription: 'Descrizione del primo punto di interesse lungo il '
        'percorso dalla Stazione all\'ITIS. Aggiungi qui le informazioni '
        'storiche, curiosità o indicazioni utili.',
    placeAddress: 'Via Example 1, Cassino (FR)',
    placeImageAsset: '',
  ),
  QrPoint(
    label: 'Punto 2',
    password: 'pass2',
    lat: 41.475818,
    lng: 13.828921,
    placeName: 'Nome del luogo 2',
    placeDescription: 'Descrizione del secondo punto di interesse. '
        'Puoi inserire informazioni sul quartiere, punti di riferimento '
        'o qualsiasi dettaglio utile per gli studenti.',
    placeAddress: 'Via Example 2, Cassino (FR)',
    placeImageAsset: '',
  ),
  QrPoint(
    label: 'Punto 3',
    password: 'pass3',
    lat: 41.474282,
    lng: 13.828943,
    placeName: 'Nome del luogo 3',
    placeDescription: 'Descrizione del terzo punto di interesse, '
        'l\'ultimo prima di arrivare all\'ITIS. Aggiungi qui le '
        'informazioni che ritieni più utili.',
    placeAddress: 'Via Example 3, Cassino (FR)',
    placeImageAsset: '',
  ),
];

const double _kScanRadius = 200.0;
const _kPrefsKey = 'qr_unlocked_points';

// ─── Modello ──────────────────────────────────────────────────────────────────

class QrPoint {
  final String label;
  final String password;
  final double lat;
  final double lng;
  final String placeName;
  final String placeDescription;
  final String placeAddress;
  final String placeImageAsset;

  const QrPoint({
    required this.label,
    required this.password,
    required this.lat,
    required this.lng,
    this.placeName = '',
    this.placeDescription = '',
    this.placeAddress = '',
    this.placeImageAsset = '',
  });
  LatLng get latLng => LatLng(lat, lng);
}

// ─── Screen principale: mappa + lista ─────────────────────────────────────────

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  Position?   _position;
  bool        _loadingGps = true;
  Set<String> _unlocked = {};
  bool        _loadingPrefs = true;

  GoogleMapController? _mapController;
  static const _cassinoCenter = LatLng(41.476, 13.829);

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _fetchPosition();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kPrefsKey) ?? [];
    if (mounted) setState(() { _unlocked = Set.from(saved); _loadingPrefs = false; });
  }

  Future<void> _saveUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPrefsKey, _unlocked.toList());
  }

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

  double? _distanceTo(QrPoint p) {
    if (_position == null) return null;
    return Geolocator.distanceBetween(
        _position!.latitude, _position!.longitude, p.lat, p.lng);
  }

  bool _isNearby(QrPoint p) {
    final d = _distanceTo(p);
    return d != null && d <= _kScanRadius;
  }

  Set<Marker> _buildMarkers() {
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
    for (final p in kQrPoints) {
      final done = _unlocked.contains(p.label);
      markers.add(Marker(
        markerId: MarkerId('qr_${p.label}'),
        position: p.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          done ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueYellow,
        ),
        infoWindow: InfoWindow(
          title: p.label,
          snippet: done ? '✅ Sbloccato' : 'Tocca poi premi "Scan" nella lista',
        ),
        onTap: () {
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
            if (_unlocked.length == kQrPoints.length) {
              Future.delayed(const Duration(milliseconds: 300), _showCompletionDialog);
            }
          },
        ),
      ),
    );
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
          'Hai scansionato tutti e 3 i punti del percorso '
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
    final camPos = _position != null
        ? LatLng(_position!.latitude, _position!.longitude)
        : _cassinoCenter;

    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 56),
                    child: Row(children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Stazione → ITIS',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                            Text('Premi "Scan" su ogni punto per scansionare il QR',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
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
                  Text('Progresso',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    '${(_unlocked.length / kQrPoints.length * 100).round()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: kQrPoints.isEmpty ? 0 : _unlocked.length / kQrPoints.length,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 14),
                _GpsStatusBanner(
                    loading: _loadingGps, position: _position, onRefresh: _fetchPosition),
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
              child: Wrap(spacing: 16, runSpacing: 4, children: [
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

// ─── Camera QR — ora PUBBLICA e accetta tutti i punti ─────────────────────────

class QrCameraPage extends StatefulWidget {
  /// Lista di tutti i punti QR da riconoscere.
  final List<QrPoint> points;
  /// Punti già sbloccati (per non ri-sbloccarli).
  final Set<String> unlockedLabels;
  /// Callback con il label del punto appena sbloccato.
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
  bool _processing = false;
  String? _errorMsg;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

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

  void _onBarcode(BarcodeCapture capture) {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    setState(() { _processing = true; _errorMsg = null; });
    _ctrl?.stop();

    // Cerca il punto corrispondente tra tutti i punti
    final matched = widget.points.cast<QrPoint?>().firstWhere(
      (p) => p!.password.trim() == raw,
      orElse: () => null,
    );

    if (matched == null) {
      // QR non riconosciuto
      setState(() {
        _errorMsg = 'QR non riconosciuto. Assicurati di scansionare '
            'uno dei QR code del percorso.';
        _processing = false;
      });
      _ctrl?.start();
      return;
    }

    if (widget.unlockedLabels.contains(matched.label)) {
      // Già sbloccato
      setState(() {
        _errorMsg = '${matched.label} è già stato sbloccato!';
        _processing = false;
      });
      _ctrl?.start();
      return;
    }

    // Successo!
    _showSuccess(matched);
  }

  void _showSuccess(QrPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceInfoSheet(
        point: point,
        onContinue: () {
          widget.onUnlock(point.label);
          Navigator.pop(context); // chiude bottom sheet
          Navigator.pop(context); // chiude camera
        },
      ),
    );
  }

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
          const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Avvio fotocamera...', style: TextStyle(color: Colors.white70)),
            ]),
          ),
        if (_ctrl != null && _errorMsg == null)
          Center(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(borderColor: theme.colorScheme.primary),
              child: const SizedBox(width: 260, height: 260),
            ),
          ),
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
        if (_processing)
          Container(
            color: Colors.black45,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
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

// ─── Legenda ──────────────────────────────────────────────────────────────────

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

// ─── Banner GPS ───────────────────────────────────────────────────────────────

class _GpsStatusBanner extends StatelessWidget {
  final bool loading;
  final Position? position;
  final VoidCallback onRefresh;
  const _GpsStatusBanner(
      {required this.loading, required this.position, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('Rilevamento GPS...',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
        ]),
      );
    }
    if (position == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(children: [
          Icon(Icons.location_off_rounded, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(child: Text('GPS non disponibile — puoi comunque scansionare',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange.shade800))),
          IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              color: Colors.orange.shade700,
              onPressed: onRefresh,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(14),
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

// ─── Card punto ───────────────────────────────────────────────────────────────

class _QrPointCard extends StatelessWidget {
  final QrPoint point;
  final int index;
  final double? distance;
  final bool isNearby;
  final bool isUnlocked;
  final VoidCallback onLocate;
  final VoidCallback onScan;

  const _QrPointCard({
    required this.point,
    required this.index,
    required this.distance,
    required this.isNearby,
    required this.isUnlocked,
    required this.onLocate,
    required this.onScan,
  });

  String _fmt(double d) =>
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
            ? '📡 Sei vicino — pronto per scansionare!'
            : distance != null
                ? '📍 A ${_fmt(distance!)} da qui'
                : '📍 GPS non disponibile';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: isNearby ? 2 : 1.2),
        boxShadow: [
          BoxShadow(
            color: isNearby
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: isUnlocked
                ? Icon(Icons.check_rounded, color: Colors.green.shade700, size: 22)
                : Text('${index + 1}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isNearby ? theme.colorScheme.primary : Colors.grey.shade500)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(point.label,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(stateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? Colors.green.shade600
                        : isNearby ? theme.colorScheme.primary : Colors.grey.shade500,
                    fontWeight: isNearby ? FontWeight.w600 : FontWeight.normal,
                  )),
            ]),
          ),
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
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isNearby
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.7),
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
                  color: Colors.green.shade100, borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.check_rounded, color: Colors.green.shade700, size: 20),
            ),
        ]),
      ),
    );
  }
}

// ─── Painter mirino ───────────────────────────────────────────────────────────

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

// ─── Bottom Sheet info luogo ──────────────────────────────────────────────────

class _PlaceInfoSheet extends StatelessWidget {
  final QrPoint point;
  final VoidCallback onContinue;
  const _PlaceInfoSheet({required this.point, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = point.placeImageAsset.isNotEmpty;
    final name = point.placeName.isNotEmpty ? point.placeName : point.label;

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 18),
                          const SizedBox(width: 6),
                          Text('${point.label} sbloccato!',
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasImage
                        ? Image.asset(point.placeImageAsset,
                            height: 200, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(theme))
                        : _buildPlaceholder(theme),
                  ),
                  const SizedBox(height: 20),
                  Text(name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (point.placeAddress.isNotEmpty) ...[
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(child: Text(point.placeAddress,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600))),
                    ]),
                    const SizedBox(height: 16),
                  ],
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    point.placeDescription.isNotEmpty
                        ? point.placeDescription
                        : 'Descrizione non ancora disponibile.',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey.shade800, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: 24, right: 24, top: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continua'),
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

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.image_rounded,
            size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        Text('Immagine in arrivo',
            style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}
