import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../services/theme_provider.dart';
import '../services/tts_service.dart';
import 'destination_picker_screen.dart';
import 'qr_scanner_screen.dart' show QrCameraPage, QrPoint, kQrPoints;

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

/// Raggio in metri entro cui scatta il banner di prossimità POI.
const double _kPoiNotifyRadius = 40.0;

/// Distanza massima in metri tra il POI e la polyline del percorso
/// perché il banner scatti. Aumentata per non bloccare il popup
/// quando il percorso non è ancora calcolato.
const double _kPoiRouteProximity = 300.0;

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

  int _lastRoutePointsHash = 0;
  LatLng? _lastCameraTarget;
  static const double _cameraUpdateThreshold = 2.0;

  // ── Prossimità POI ──────────────────────────────────────────────────────────
  final Set<String> _notifiedPoi = {};
  QrPoint? _nearbyPoi;
  late final AnimationController _poiBannerCtrl;
  late final Animation<Offset> _poiBannerSlide;
  late final Animation<double> _poiBannerFade;

  late final AnimationController _enterCtrl;
  late final Animation<double> _topBarFade;
  late final Animation<Offset> _topBarSlide;
  late final Animation<double> _sideButtonsFade;
  late final Animation<double> _bottomCardFade;
  late final Animation<Offset> _bottomCardSlide;
  late final Animation<double> _bannerFade;
  late final Animation<Offset> _bannerSlide;

  LatLng get _destLatLng =>
      LatLng(widget.destination.latitude, widget.destination.longitude);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

    _poiBannerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _poiBannerSlide =
        Tween<Offset>(begin: const Offset(0, 1.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _poiBannerCtrl, curve: Curves.easeOutCubic));
    _poiBannerFade =
        CurvedAnimation(parent: _poiBannerCtrl, curve: Curves.easeOut);
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
    _checkPoiProximity(position, navService.routePoints);
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

  // ── Logica prossimità POI ────────────────────────────────────────────────────
  /// Controlla se l'utente è vicino a un POI.
  /// Se il percorso è disponibile, verifica anche la vicinanza alla polyline.
  /// Se il percorso NON è ancora disponibile, mostra comunque il banner.
  void _checkPoiProximity(Position position, List<LatLng> routePoints) {
    for (final poi in kQrPoints) {
      if (_notifiedPoi.contains(poi.label)) continue;

      // 1. Utente entro _kPoiNotifyRadius dal POI
      final distUser = Geolocator.distanceBetween(
          position.latitude, position.longitude, poi.lat, poi.lng);
      if (distUser > _kPoiNotifyRadius) continue;

      // 2. Se il percorso è calcolato, verifica vicinanza alla polyline
      //    Se il percorso non è ancora disponibile, mostra il banner comunque
      if (routePoints.isNotEmpty && !_isPoiNearRoute(poi, routePoints)) continue;

      _notifiedPoi.add(poi.label);
      _showPoiBanner(poi);
      break;
    }
  }

  /// Restituisce true se il POI è entro [_kPoiRouteProximity] da almeno
  /// un segmento della polyline del percorso.
  bool _isPoiNearRoute(QrPoint poi, List<LatLng> routePoints) {
    for (int i = 0; i < routePoints.length - 1; i++) {
      final d = _distanceToSegment(
        LatLng(poi.lat, poi.lng),
        routePoints[i],
        routePoints[i + 1],
      );
      if (d <= _kPoiRouteProximity) return true;
    }
    return false;
  }

  /// Distanza approssimativa in metri da un punto a un segmento lat/lng.
  double _distanceToSegment(LatLng p, LatLng a, LatLng b) {
    final double dx = b.longitude - a.longitude;
    final double dy = b.latitude - a.latitude;
    if (dx == 0 && dy == 0) {
      return Geolocator.distanceBetween(p.latitude, p.longitude, a.latitude, a.longitude);
    }
    double t = ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) /
        (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);
    final closest = LatLng(a.latitude + t * dy, a.longitude + t * dx);
    return Geolocator.distanceBetween(
        p.latitude, p.longitude, closest.latitude, closest.longitude);
  }

  void _showPoiBanner(QrPoint poi) {
    if (!mounted) return;
    setState(() => _nearbyPoi = poi);
    _poiBannerCtrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _nearbyPoi?.label == poi.label) _dismissPoiBanner();
    });
  }

  void _dismissPoiBanner() {
    _poiBannerCtrl.reverse().then((_) {
      if (mounted) setState(() => _nearbyPoi = null);
    });
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

    // POI — tutti cliccabili, nessuna dipendenza dal QR
    for (final qp in kQrPoints) {
      _markers.add(Marker(
        markerId: MarkerId('poi_${qp.label}'),
        position: qp.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: qp.placeName.isNotEmpty ? qp.placeName : qp.label,
          snippet: 'Tocca per i dettagli',
        ),
        onTap: () => _showPlaceSheet(qp),
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
  }

  void _showPlaceSheet(QrPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PoiInfoSheet(point: point),
    );
  }

  void _applyMapStyle(GoogleMapController controller) {
    final isDark = context.read<ThemeProvider>().isDark;
    controller.setMapStyle(isDark ? _darkMapStyle : null);
  }

  /// Apre il QR scanner dalla schermata mappa
  Future<void> _openQrScanner() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => QrCameraPage(
          points: kQrPoints,
          unlockedLabels: const {},
          onUnlock: (_) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final position = context.watch<LocationService>().currentPosition;
    final cameraTarget = position != null
        ? LatLng(position.latitude, position.longitude)
        : _cassinoCenter;

    if (_mapController != null) _applyMapStyle(_mapController!);

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
              _applyMapStyle(c);
              c.animateCamera(CameraUpdate.newLatLngZoom(cameraTarget, 15));
            },
            onCameraMoveStarted: () {
              if (_followUser) setState(() => _followUser = false);
            },
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Row(children: [
                      Icon(Icons.location_off, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'GPS non disponibile — percorso da centro Cassino',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ]),
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
                child: Row(
                  children: [
                    _buildTopButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () {
                        context.read<LocationService>().removeListener(_handleLocationUpdate);
                        context.read<NavigationService>().stopNavigation();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Consumer<NavigationService>(
                          builder: (_, nav, __) => nav.isCalculatingRoute
                              ? Row(children: [
                                  const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2.2)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Calcolo percorso...',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                ])
                              : Column(
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
                                        color: nav.error != null ? Colors.red : cs.onSurface,
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
                                            : cs.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
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
                  _buildTopButton(
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
                  const SizedBox(height: 12),
                  _buildTopButton(
                    icon: Icons.add,
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  ),
                  const SizedBox(height: 12),
                  _buildTopButton(
                    icon: Icons.remove,
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  ),
                  const SizedBox(height: 12),
                  Consumer<TtsService>(
                    builder: (_, tts, __) => _buildTopButton(
                      icon: tts.enabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      active: tts.enabled,
                      onTap: () => tts.toggle(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ── Pulsante QR Scanner ───────────────────────────────────
                  _buildTopButton(
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: _openQrScanner,
                    tooltip: 'Scansiona QR',
                  ),
                ],
              ),
            ),
          ),

          // ── Banner prossimità POI ──────────────────────────────────────────
          if (_nearbyPoi != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 170,
              child: SlideTransition(
                position: _poiBannerSlide,
                child: FadeTransition(
                  opacity: _poiBannerFade,
                  child: _PoiProximityBanner(
                    poi: _nearbyPoi!,
                    onTap: () {
                      _dismissPoiBanner();
                      _showPlaceSheet(_nearbyPoi!);
                    },
                    onDismiss: _dismissPoiBanner,
                  ),
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
                child: Consumer<NavigationService>(
                  builder: (_, nav, __) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surface,
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
                              gradient: LinearGradient(
                                  colors: [cs.primary, cs.secondary]),
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
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurface.withValues(alpha: 0.6)),
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
                            backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(cs.primary),
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
        ],
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
    String? tooltip,
  }) {
    final cs = Theme.of(context).colorScheme;
    final btn = Container(
      decoration: BoxDecoration(
        color: active ? cs.primary : cs.surface,
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
            child: Icon(icon, color: active ? Colors.white : cs.primary),
          ),
        ),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip, child: btn);
    return btn;
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String label) {
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _poiBannerCtrl.dispose();
    context.read<LocationService>().removeListener(_handleLocationUpdate);
    context.read<NavigationService>().stopNavigation();
    _mapController?.dispose();
    super.dispose();
  }
}

// ── Banner prossimità POI ──────────────────────────────────────────────────────

class _PoiProximityBanner extends StatelessWidget {
  final QrPoint poi;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _PoiProximityBanner({
    required this.poi,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.place_rounded,
                    color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punto di interesse vicino',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      poi.placeName.isNotEmpty ? poi.placeName : poi.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tocca per scoprire di più →',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded,
                    size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet info POI ──────────────────────────────────────────────────────

class _PoiInfoSheet extends StatelessWidget {
  final QrPoint point;
  const _PoiInfoSheet({required this.point});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasImage = point.placeImageUrl.isNotEmpty;
    final name = point.placeName.isNotEmpty ? point.placeName : point.label;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasImage
                        ? Image.network(
                            point.placeImageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null
                                ? child
                                : _buildImageSkeleton(theme),
                            errorBuilder: (_, __, ___) => _placeholder(theme),
                          )
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
                          size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
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
                  Text(
                    point.placeDescription.isNotEmpty
                        ? point.placeDescription
                        : 'Descrizione non ancora disponibile.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.8), height: 1.6),
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
                color: cs.surface,
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

  Widget _buildImageSkeleton(ThemeData theme) {
    return Container(
      height: 180,
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

  Widget _placeholder(ThemeData theme) {
    return Container(
      height: 180, width: double.infinity,
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
        Text('Immagine in arrivo',
            style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}

// ── Classe _QrInfoSheetWrapper mantenuta per retrocompatibilità con qr_scanner_screen ──
class _QrInfoSheetWrapper extends StatelessWidget {
  final QrPoint point;
  const _QrInfoSheetWrapper({required this.point});
  @override
  Widget build(BuildContext context) => _PoiInfoSheet(point: point);
}
