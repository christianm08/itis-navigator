import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  GoogleMapController? _mapController;
  bool _followUser = true;
  static const LatLng _itisLocation = LatLng(41.4688333, 13.8341111);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNavigation();
    });
  }

  Future<void> _initializeNavigation() async {
    final navService = context.read<NavigationService>();
    final locationService = context.read<LocationService>();
    await locationService.initialize();
    final pos = locationService.currentPosition;
    if (pos != null) {
      await navService.startNavigation(start: pos, destination: _itisLocation);
      _rebuildMapData();
      locationService.addListener(_handleLocationUpdate);
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleLocationUpdate() async {
    if (!mounted) return;
    final locationService = context.read<LocationService>();
    final navService = context.read<NavigationService>();
    final position = locationService.currentPosition;
    if (position == null) return;

    await navService.updatePosition(position);
    _rebuildMapData();

    if (_followUser && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
            bearing: locationService.heading ?? 0,
            tilt: 50,
          ),
        ),
      );
    }
  }

  void _rebuildMapData() {
    final navService = context.read<NavigationService>();
    final locationService = context.read<LocationService>();
    final position = locationService.currentPosition;

    _markers.clear();
    _polylines.clear();
    _circles.clear();

    if (navService.routePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('active_route'),
          points: navService.routePoints,
          color: const Color(0xFFFF6B6B),
          width: 9,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _itisLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'ITIS E. Majorana'),
      ),
    );

    final currentStep = navService.currentStep;
    if (currentStep != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_step'),
          position: currentStep.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Prossima manovra',
            snippet: currentStep.instruction,
          ),
        ),
      );
    }

    if (position != null) {
      final user = LatLng(position.latitude, position.longitude);
      _circles.add(
        Circle(
          circleId: const CircleId('accuracy'),
          center: user,
          radius: position.accuracy,
          fillColor: const Color(0x221D4ED8),
          strokeColor: const Color(0x661D4ED8),
          strokeWidth: 1,
        ),
      );
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navService = context.watch<NavigationService>();
    final locationService = context.watch<LocationService>();
    final position = locationService.currentPosition;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(41.4766, 13.8310),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              if (position != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(position.latitude, position.longitude),
                    17,
                  ),
                );
              }
            },
            onCameraMoveStarted: () {
              if (_followUser) {
                setState(() {
                  _followUser = false;
                });
              }
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: navService.isCalculatingRoute
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Calcolo percorso...',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                navService.currentInstruction.isEmpty
                                    ? 'Preparazione percorso...'
                                    : navService.currentInstruction,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${navService.getFormattedDistance()} • ETA ${navService.getFormattedETA()}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 120,
            child: Column(
              children: [
                _buildTopButton(
                  icon: Icons.my_location_rounded,
                  active: _followUser,
                  onTap: () {
                    setState(() {
                      _followUser = true;
                    });
                    if (position != null && _mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(position.latitude, position.longitude),
                            zoom: 18,
                            bearing: locationService.heading ?? 0,
                            tilt: 50,
                          ),
                        ),
                      );
                    }
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
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
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
                              navService.hasArrived
                                  ? 'Destinazione raggiunta'
                                  : 'Navigazione stradale attiva',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              navService.steps.isEmpty
                                  ? 'In attesa del percorso'
                                  : 'Manovra ${navService.currentStepIndex + 1}/${navService.steps.length}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: navService.progress,
                      backgroundColor: const Color(0xFFFFE5E5),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B6B)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatChip(Icons.straighten_rounded, navService.getFormattedDistance()),
                      _buildStatChip(Icons.schedule_rounded, navService.getFormattedETA()),
                    ],
                  ),
                ],
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
        color: active ? const Color(0xFFFF6B6B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
              color: active ? Colors.white : const Color(0xFFFF6B6B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF8E53)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    context.read<LocationService>().removeListener(_handleLocationUpdate);
    context.read<NavigationService>().stopNavigation();
    _mapController?.dispose();
    super.dispose();
  }
}
