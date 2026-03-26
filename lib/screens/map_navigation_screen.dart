import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../services/tts_service.dart';
import 'destination_picker_screen.dart';
import 'qr_scanner_screen.dart';

class MapNavigationScreen extends StatefulWidget {
  final Destination destination;
  const MapNavigationScreen({super.key, required this.destination});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _followUser = true;
  bool _usingFallbackPosition = false;

  static const LatLng _cassinoCenter = LatLng(41.4897, 13.8283);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};

  // Posizioni schermo dei punti QR (aggiornate ad ogni rebuild)
  final Map<String, Offset> _qrScreenPositions = {};

  int _lastRoutePointsHash = 0;
  LatLng? _lastCameraTarget;
  static const double _cameraUpdateThreshold = 2.0;

  late final AnimationController _enterCtrl;
  late final Animation<double> _topBarFade;
  late final Animation<Offset> _topBarSlide;
  late final Animation<double> _sideButtonsFade;
  late final Animation<double> _bottomCardFade;
  late final Animation<Offset> _bottomCardSlide;
  late final Animation<double> _bannerFade;
  late final Animation<Offset> _bannerSlide;

  Set<String> _unlockedQr = {};
  static const _kPrefsKey = 'qr_unlocked_points';

  LatLng get _destLatLng =>
      LatLng(widget.destination.latitude, widget.destination.longitude);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUnlockedQr();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterCtrl.forward();
      _initializeNavigation();
      SemanticsService.announce(
        'Navigazione avviata verso ${widget.destination.name}. '
        'Attendi il calcolo del percorso.',
        TextDirection.ltr,
      );
    });
  }

  Future<void> _loadUnlockedQr() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kPrefsKey) ?? [];
    if (mounted) setState(() => _unlockedQr = Set.from(saved));
  }

  Future<void> _saveUnlockedQr() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPrefsKey, _unlockedQr.toList());
  }

  void _setupAnimations() {
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _topBarFade = CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _topBarSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _enterCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));
    _sideButtonsFade = CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.33, 0.85, curve: Curves.easeOut));
    _bottomCardFade = CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.25, 0.9, curve: Curves.easeOut));
    _bottomCardSlide =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _enterCtrl,
                curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic)));
    _bannerFade = CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOut));
    _bannerSlide =
        Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _enterCtrl,
                curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic)));
  }

  Future<void> _initializeNavigation() async {
    final navService = context.read<NavigationService>();
    final locationService = context.read<LocationService>();
    await locationService.initialize();
    await locationService.forceRefreshPosition();
    final pos = locationService.currentPosition;
    Position startPosition;
    if (pos != null) {
      startPosition = pos;
      _usingFallbackPosition = false;
    } else {
      startPosition = Position(
        latitude: _cassinoCenter.latitude,
        longitude: _cassinoCenter.longitude,
        timestamp: DateTime.now(),
        accuracy: 50, altitude: 0, altitudeAccuracy: 0,
        heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0,
      );
      _usingFallbackPosition = true;
      if (mounted) setState(() {});
    }
    await navService.startNavigation(
        start: startPosition,
        destination: _destLatLng,
        fromFallback: _usingFallbackPosition);
    _rebuildMapData();
    locationService.addListener(_handleLocationUpdate);
    if (mounted) setState(() {});
  }

  Future<void> _handleLocationUpdate() async {
    if (!mounted) return;
    final locationService = context.read<LocationService>();
    final navService = context.read<NavigationService>();
    final position = locationService.currentPosition;
    if (position == null) return;
    if (_usingFallbackPosition) setState(() => _usingFallbackPosition = false);
    await navService.updatePosition(position);
    _rebuildMapData();
    if (_followUser && _mapController != null) {
      final newTarget = LatLng(position.latitude, position.longitude);
      final last = _lastCameraTarget;
      if (last != null) {
        final moved = Geolocator.distanceBetween(
            last.latitude, last.longitude,
            newTarget.latitude, newTarget.longitude);
        if (moved < _cameraUpdateThreshold) return;
      }
      _lastCameraTarget = newTarget;
      double bearing = 0;
      try { bearing = locationService.heading ?? 0; } catch (_) {}
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: newTarget, zoom: 18, bearing: bearing, tilt: 45)));
    }
  }

  void _rebuildMapData() {
    final navService = context.read<NavigationService>();
    final locationService = context.read<LocationService>();
    final position = locationService.currentPosition;
    final newHash = navService.routePoints.length;
    if (newHash != _lastRoutePointsHash) {
      _lastRoutePointsHash = newHash;
      _polylines.clear();
      if (navService.routePoints.isNotEmpty) {
        _polylines.add(Polyline(
          polylineId: const PolylineId('active_route'),
          points: navService.routePoints,
          color: Theme.of(context).colorScheme.primary,
          width: 9,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ));
      }
    }
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: _destLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: widget.destination.name),
    ));

    // Marker QR: viola se sbloccato, giallo se no
    for (final qp in kQrPoints) {
      final unlocked = _unlockedQr.contains(qp.label);
      _markers.add(Marker(
        markerId: MarkerId('qr_nav_${qp.label}'),
        position: qp.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          unlocked ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueYellow,
        ),
        infoWindow: InfoWindow(
          title: qp.label,
          snippet: unlocked ? '✅ Sbloccato — tocca ℹ️ per i dettagli' : 'Avvicinati e scansiona il QR',
        ),
        onTap: unlocked ? () => _showPlaceSheet(qp) : null,
      ));
    }

    final currentStep = navService.currentStep;
    if (currentStep != null) {
      _markers.add(Marker(
        markerId: const MarkerId('current_step'),
        position: currentStep.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: 'Prossima manovra', snippet: currentStep.instruction),
      ));
    }
    _circles.clear();
    final displayPos = position != null
        ? LatLng(position.latitude, position.longitude)
        : _cassinoCenter;
    _circles.add(Circle(
      circleId: const CircleId('user_position'),
      center: displayPos,
      radius: position?.accuracy ?? 50,
      fillColor: const Color(0x221D4ED8),
      strokeColor: const Color(0x661D4ED8),
      strokeWidth: 1,
    ));
    if (mounted) setState(() {});
    // Aggiorna posizioni schermo degli overlay dopo il frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateQrScreenPositions());
  }

  /// Converte lat/lng dei punti QR sbloccati in coordinate schermo per gli overlay.
  Future<void> _updateQrScreenPositions() async {
    final ctrl = _mapController;
    if (ctrl == null || !mounted) return;
    final Map<String, Offset> updated = {};
    for (final qp in kQrPoints) {
      if (!_unlockedQr.contains(qp.label)) continue;
      try {
        final sp = await ctrl.getScreenCoordinate(qp.latLng);
        updated[qp.label] = Offset(sp.x.toDouble(), sp.y.toDouble());
      } catch (_) {}
    }
    if (mounted) setState(() => _qrScreenPositions
      ..clear()
      ..addAll(updated));
  }

  /// Mostra il bottom sheet con le informazioni del luogo (riutilizza _PlaceInfoSheet da qr_scanner_screen).
  void _showPlaceSheet(QrPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrInfoSheetWrapper(point: point),
    );
  }

  Future<void> _openQrScanner() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => QrCameraPage(
          points: kQrPoints,
          unlockedLabels: _unlockedQr,
          onUnlock: (label) {
            setState(() => _unlockedQr.add(label));
            _saveUnlockedQr();
            _rebuildMapData();
          },
        ),
      ),
    );
    // Aggiorna anche al ritorno dalla camera (nel caso)
    _rebuildMapData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = context.watch<LocationService>().currentPosition;
    final cameraTarget = position != null
        ? LatLng(position.latitude, position.longitude)
        : _cassinoCenter;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: cameraTarget, zoom: 15),
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            onMapCreated: (c) {
              _mapController = c;
              c.animateCamera(CameraUpdate.newLatLngZoom(cameraTarget, 15));
            },
            onCameraMoveStarted: () {
              if (_followUser) setState(() => _followUser = false);
            },
            onCameraIdle: () => _updateQrScreenPositions(),
            onCameraMove: (_) => _updateQrScreenPositions(),
          ),

          // ── Overlay icone ✅ sui punti QR sbloccati ──────────────────────
          for (final qp in kQrPoints)
            if (_unlockedQr.contains(qp.label) &&
                _qrScreenPositions.containsKey(qp.label))
              Positioned(
                left: _qrScreenPositions[qp.label]!.dx - 18,
                // -52 per stare sopra al marker (alto ~44px)
                top: _qrScreenPositions[qp.label]!.dy - 52,
                child: GestureDetector(
                  onTap: () => _showPlaceSheet(qp),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade900.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),

          // Banner GPS fallback
          if (_usingFallbackPosition)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 16, right: 16,
              child: FadeTransition(
                opacity: _bannerFade,
                child: SlideTransition(
                  position: _bannerSlide,
                  child: Semantics(
                    liveRegion: true,
                    label: 'GPS non disponibile. Percorso calcolato dal centro di Cassino.',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Row(children: [
                        Icon(Icons.location_off, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: ExcludeSemantics(
                            child: Text(
                              'GPS non disponibile — percorso da centro Cassino',
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16, right: 16,
            child: FadeTransition(
              opacity: _topBarFade,
              child: SlideTransition(
                position: _topBarSlide,
                child: RepaintBoundary(
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Ferma la navigazione e torna indietro',
                        child: _buildTopButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () {
                            context.read<LocationService>().removeListener(_handleLocationUpdate);
                            context.read<NavigationService>().stopNavigation();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 16, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Consumer<NavigationService>(
                            builder: (_, nav, __) {
                              if (!nav.isCalculatingRoute &&
                                  nav.currentInstruction.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  SemanticsService.announce(
                                      nav.currentInstruction, TextDirection.ltr);
                                });
                              }
                              return nav.isCalculatingRoute
                                  ? Semantics(
                                      liveRegion: true,
                                      label: 'Calcolo percorso in corso, attendere',
                                      child: Row(children: [
                                        const SizedBox(
                                            width: 18, height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2.2)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ExcludeSemantics(
                                            child: Text('Calcolo percorso...',
                                                style: theme.textTheme.titleMedium
                                                    ?.copyWith(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ]),
                                    )
                                  : Semantics(
                                      liveRegion: true,
                                      label: nav.error != null
                                          ? 'Errore: ${nav.error}'
                                          : '${nav.currentInstruction}. '
                                            'Distanza rimanente: ${nav.getFormattedDistance()}. '
                                            'Tempo stimato: ${nav.getFormattedETA()}',
                                      child: ExcludeSemantics(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nav.currentInstruction.isEmpty
                                                  ? 'Preparazione percorso...'
                                                  : nav.currentInstruction,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: nav.error != null
                                                    ? Colors.red
                                                    : const Color(0xFF1F2937),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              nav.error != null
                                                  ? nav.error!
                                                  : '${nav.getFormattedDistance()} • ETA ${nav.getFormattedETA()}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: nav.error != null
                                                    ? Colors.red.shade300
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Pulsanti laterali
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 120,
            child: FadeTransition(
              opacity: _sideButtonsFade,
              child: Column(
                children: [
                  Semantics(
                    button: true,
                    label: 'Centra la mappa sulla tua posizione',
                    child: _buildTopButton(
                      icon: Icons.my_location_rounded,
                      active: _followUser,
                      onTap: () async {
                        setState(() => _followUser = true);
                        final ls = context.read<LocationService>();
                        await ls.forceRefreshPosition();
                        final cur = ls.currentPosition;
                        final target = cur != null
                            ? LatLng(cur.latitude, cur.longitude)
                            : _cassinoCenter;
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: target, zoom: 18, bearing: 0, tilt: 45)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Zoom avanti',
                    child: _buildTopButton(
                      icon: Icons.add,
                      onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Zoom indietro',
                    child: _buildTopButton(
                      icon: Icons.remove,
                      onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<TtsService>(
                    builder: (_, tts, __) => Semantics(
                      button: true,
                      label: tts.enabled
                          ? 'Disattiva indicazioni vocali'
                          : 'Attiva indicazioni vocali',
                      child: _buildTopButton(
                        icon: tts.enabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        active: tts.enabled,
                        onTap: () => tts.toggle(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 48, height: 1,
                    decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(1)),
                  ),
                  const SizedBox(height: 20),
                  Semantics(
                    button: true,
                    label: 'Scansiona QR code',
                    child: _buildQrButton(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: FadeTransition(
              opacity: _bottomCardFade,
              child: SlideTransition(
                position: _bottomCardSlide,
                child: RepaintBoundary(
                  child: Consumer<NavigationService>(
                    builder: (_, nav, __) => Semantics(
                      label: nav.hasArrived
                          ? 'Destinazione raggiunta: ${widget.destination.name}'
                          : 'Navigazione verso ${widget.destination.name}. '
                            'Manovra ${nav.currentStepIndex + 1} di ${nav.steps.length}. '
                            'Progresso: ${(nav.progress * 100).round()} percento.',
                      child: ExcludeSemantics(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 24, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ]),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.route_rounded, color: Colors.white),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nav.hasArrived
                                            ? 'Destinazione raggiunta'
                                            : 'Verso ${widget.destination.name}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        nav.steps.isEmpty
                                            ? 'Calcolo in corso...'
                                            : 'Manovra ${nav.currentStepIndex + 1}/${nav.steps.length}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  value: nav.progress,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation(
                                      theme.colorScheme.primary),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatChip(theme, Icons.straighten_rounded,
                                      nav.getFormattedDistance()),
                                  _buildStatChip(theme, Icons.schedule_rounded,
                                      nav.getFormattedETA()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(icon,
                color: active
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildQrButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF34D399)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.35),
              blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openQrScanner,
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    context.read<LocationService>().removeListener(_handleLocationUpdate);
    context.read<NavigationService>().stopNavigation();
    _mapController?.dispose();
    super.dispose();
  }
}

// ─── Wrapper bottom sheet info luogo (riusa _PlaceInfoSheet via export) ───────
// Mostra le info del punto QR sbloccato senza necessità di ri-scansionare.

class _QrInfoSheetWrapper extends StatelessWidget {
  final QrPoint point;
  const _QrInfoSheetWrapper({required this.point});

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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  // Badge sbloccato
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
                          Icon(Icons.check_circle_rounded,
                              color: Colors.green.shade600, size: 18),
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
                  // Immagine o placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasImage
                        ? Image.asset(point.placeImageAsset,
                            height: 200, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(theme))
                        : _placeholder(theme),
                  ),
                  const SizedBox(height: 20),
                  Text(name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (point.placeAddress.isNotEmpty) ...[
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(point.placeAddress,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600)),
                      ),
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
            // Pulsante chiudi
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
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Chiudi'),
                  style: OutlinedButton.styleFrom(
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

  Widget _placeholder(ThemeData theme) {
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
            size: 56,
            color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 10),
        Text('Immagine in arrivo',
            style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ]),
    );
  }
}
