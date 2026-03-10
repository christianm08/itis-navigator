import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import 'destination_picker_screen.dart';

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
      // Annuncio iniziale per screen reader
      SemanticsService.announce(
        'Navigazione avviata verso ${widget.destination.name}. '
        'Attendi il calcolo del percorso.',
        TextDirection.ltr,
      );
    });
  }

  void _setupAnimations() {
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _topBarFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _topBarSlide = Tween<Offset>(
      begin: const Offset(0, -1), end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));
    _sideButtonsFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.33, 0.85, curve: Curves.easeOut),
    );
    _bottomCardFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.25, 0.9, curve: Curves.easeOut),
    );
    _bottomCardSlide = Tween<Offset>(
      begin: const Offset(0, 1), end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
    ));
    _bannerFade = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
    );
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -0.6), end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
    ));
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
        accuracy: 50,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      _usingFallbackPosition = true;
      if (mounted) setState(() {});
    }

    await navService.startNavigation(
        start: startPosition, destination: _destLatLng);
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
          newTarget.latitude, newTarget.longitude,
        );
        if (moved < _cameraUpdateThreshold) return;
      }
      _lastCameraTarget = newTarget;
      double bearing = 0;
      try { bearing = locationService.heading ?? 0; } catch (_) {}
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: newTarget, zoom: 18, bearing: bearing, tilt: 45,
        )),
      );
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

    final currentStep = navService.currentStep;
    if (currentStep != null) {
      _markers.add(Marker(
        markerId: const MarkerId('current_step'),
        position: currentStep.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: 'Prossima manovra',
          snippet: currentStep.instruction,
        ),
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
            initialCameraPosition:
                CameraPosition(target: cameraTarget, zoom: 15),
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
          ),

          // Banner GPS fallback
          if (_usingFallbackPosition)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              left: 16,
              right: 16,
              child: FadeTransition(
                opacity: _bannerFade,
                child: SlideTransition(
                  position: _bannerSlide,
                  child: Semantics(
                    liveRegion: true,
                    label: 'GPS non disponibile. Percorso calcolato dal centro di Cassino.',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(14),
                      ),
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
            left: 16,
            right: 16,
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
                            context
                                .read<LocationService>()
                                .removeListener(_handleLocationUpdate);
                            context.read<NavigationService>().stopNavigation();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Consumer<NavigationService>(
                            builder: (_, nav, __) {
                              // Annuncio vocale cambio istruzione
                              if (!nav.isCalculatingRoute &&
                                  nav.currentInstruction.isNotEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  SemanticsService.announce(
                                    nav.currentInstruction,
                                    TextDirection.ltr,
                                  );
                                });
                              }
                              return nav.isCalculatingRoute
                                  ? Semantics(
                                      liveRegion: true,
                                      label: 'Calcolo percorso in corso, attendere',
                                      child: Row(children: [
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.2),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ExcludeSemantics(
                                            child: Text('Calcolo percorso...',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nav.currentInstruction.isEmpty
                                                  ? 'Preparazione percorso...'
                                                  : nav.currentInstruction,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
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
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
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
                              target: target,
                              zoom: 18,
                              bearing: 0,
                              tilt: 45)),
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
                      onTap: () => _mapController
                          ?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: 'Zoom indietro',
                    child: _buildTopButton(
                      icon: Icons.remove,
                      onTap: () => _mapController
                          ?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
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
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
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
                                  child: const Icon(Icons.route_rounded,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nav.hasArrived
                                            ? 'Destinazione raggiunta'
                                            : 'Verso ${widget.destination.name}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatChip(
                                      theme,
                                      Icons.straighten_rounded,
                                      nav.getFormattedDistance()),
                                  _buildStatChip(
                                      theme,
                                      Icons.schedule_rounded,
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
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              icon,
              color: active
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
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
