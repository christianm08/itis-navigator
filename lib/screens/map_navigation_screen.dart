import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../models/landmark.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  GoogleMapController? _mapController;
  bool _followUser = true;

  static const LatLng _stationLocation = LatLng(41.4847222, 13.83225);
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

    navService.initializeRoute(Landmark.routeCsvPoints());
    await locationService.initialize();
    navService.startNavigation();
    _rebuildMapData();

    locationService.addListener(_handleLocationUpdate);
    if (mounted) setState(() {});
  }

  void _handleLocationUpdate() {
    if (!mounted) return;

    final locationService = context.read<LocationService>();
    final navService = context.read<NavigationService>();
    final position = locationService.currentPosition;

    if (position == null) return;

    navService.updatePosition(position);
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

    final routePoints = navService.waypoints
        .map((w) => LatLng(w.latitude, w.longitude))
        .toList();

    if (routePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('full_route'),
          points: routePoints,
          color: const Color(0xFFFFB703),
          width: 8,
          patterns: const [],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    if (navService.currentWaypointIndex < navService.waypoints.length) {
      final remainingPoints = navService.waypoints
          .skip(navService.currentWaypointIndex)
          .map((w) => LatLng(w.latitude, w.longitude))
          .toList();

      if (position != null) {
        remainingPoints.insert(0, LatLng(position.latitude, position.longitude));
      }

      if (remainingPoints.length >= 2) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('remaining_route'),
            points: remainingPoints,
            color: const Color(0xFFFF6B6B),
            width: 9,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('station'),
        position: _stationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Stazione Cassino'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _itisLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'ITIS E. Majorana'),
      ),
    );

    final currentWaypoint = navService.currentWaypoint;
    if (currentWaypoint != null) {
      final waypointLatLng = LatLng(currentWaypoint.latitude, currentWaypoint.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('current_waypoint'),
          position: waypointLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: currentWaypoint.name,
            snippet: currentWaypoint.description,
          ),
        ),
      );

      _circles.add(
        Circle(
          circleId: const CircleId('waypoint_zone'),
          center: waypointLatLng,
          radius: 15,
          fillColor: const Color(0x33FF6B6B),
          strokeColor: const Color(0xFFFF6B6B),
          strokeWidth: 2,
        ),
      );
    }

    if (position != null) {
      final userLatLng = LatLng(position.latitude, position.longitude);
      _circles.add(
        Circle(
          circleId: const CircleId('accuracy'),
          center: userLatLng,
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
              } else {
                _fitBoundsToRoute();
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
            child: Column(
              children: [
                Row(
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
                        child: Column(
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
                              'Navigazione interna attiva',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Waypoint ${navService.currentWaypointIndex + 1}/${navService.waypoints.isEmpty ? 0 : navService.waypoints.length}',
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
                      value: navService.progress.clamp(0.0, 1.0),
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

  void _fitBoundsToRoute() {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _itisLocation.latitude < _stationLocation.latitude ? _itisLocation.latitude : _stationLocation.latitude,
            _itisLocation.longitude < _stationLocation.longitude ? _itisLocation.longitude : _stationLocation.longitude,
          ),
          northeast: LatLng(
            _itisLocation.latitude > _stationLocation.latitude ? _itisLocation.latitude : _stationLocation.latitude,
            _itisLocation.longitude > _stationLocation.longitude ? _itisLocation.longitude : _stationLocation.longitude,
          ),
        ),
        90,
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
