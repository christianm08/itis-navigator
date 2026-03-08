import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../models/landmark.dart';
import '../widgets/navigation_bottom_sheet.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  GoogleMapController? _mapController;
  
  // Coordinate ITIS E. Majorana Cassino
  static const LatLng _itisLocation = LatLng(41.4688333, 13.8341111);
  // Stazione Cassino
  static const LatLng _stationLocation = LatLng(41.4847222, 13.83225);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};
  StreamSubscription? _locationSubscription;
  bool _followUser = true;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    final navService = context.read<NavigationService>();
    final locationService = context.read<LocationService>();
    
    // Inizializza il percorso con i waypoint
    navService.initializeRoute(Landmark.routeCsvPoints());
    
    // Avvia il tracciamento della posizione
    locationService.initialize().then((_) {
      navService.startNavigation();
      _setupLocationListener();
      _setupMapElements();
    });
  }

  void _setupLocationListener() {
    final locationService = context.read<LocationService>();
    final navService = context.read<NavigationService>();
    
    locationService.addListener(() {
      final position = locationService.currentPosition;
      if (position != null) {
        navService.updatePosition(position);
        
        if (_followUser && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 17.5,
                bearing: locationService.heading ?? 0,
                tilt: 45,
              ),
            ),
          );
        }
        
        _updateMarkers();
      }
    });
  }

  void _setupMapElements() {
    _setupWaypointMarkers();
    _setupRoute();
    setState(() {});
  }

  void _setupWaypointMarkers() {
    final navService = context.read<NavigationService>();
    _markers.clear();
    
    // Marker stazione (inizio)
    _markers.add(
      Marker(
        markerId: const MarkerId('station'),
        position: _stationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: '🚀 Stazione Cassino',
          snippet: 'Punto di partenza',
        ),
      ),
    );
    
    // Marker ITIS (destinazione)
    _markers.add(
      Marker(
        markerId: const MarkerId('itis'),
        position: _itisLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: '🎯 ITIS E. Majorana',
          snippet: 'Destinazione',
        ),
      ),
    );

    // Aggiungi marker per ogni waypoint importante
    int markerCount = 0;
    for (var waypoint in navService.waypoints) {
      // Mostra solo waypoint ogni 3 per non sovraffollare la mappa
      if (waypoint.order % 3 == 0 || waypoint.name.contains('INIZIO') || waypoint.name.contains('ARRIVO')) {
        _markers.add(
          Marker(
            markerId: MarkerId('waypoint_${waypoint.order}'),
            position: LatLng(waypoint.latitude, waypoint.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            alpha: 0.7,
            infoWindow: InfoWindow(
              title: waypoint.name,
              snippet: waypoint.description,
            ),
          ),
        );
        markerCount++;
      }
    }
  }

  void _updateMarkers() {
    final navService = context.read<NavigationService>();
    final locationService = context.read<LocationService>();
    
    if (locationService.currentPosition == null) return;
    
    // Aggiorna il marker della posizione corrente con heading
    final currentPos = locationService.currentPosition!;
    
    // Cerchio di accuratezza
    _circles.clear();
    _circles.add(
      Circle(
        circleId: const CircleId('accuracy'),
        center: LatLng(currentPos.latitude, currentPos.longitude),
        radius: currentPos.accuracy,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
    
    // Cerchio per il prossimo waypoint
    final nextWaypoint = navService.currentWaypoint;
    if (nextWaypoint != null) {
      _circles.add(
        Circle(
          circleId: const CircleId('nextWaypoint'),
          center: LatLng(nextWaypoint.latitude, nextWaypoint.longitude),
          radius: 15,
          fillColor: Colors.green.withOpacity(0.3),
          strokeColor: Colors.green,
          strokeWidth: 2,
        ),
      );
    }
    
    setState(() {});
  }

  void _setupRoute() {
    final navService = context.read<NavigationService>();
    _polylines.clear();
    
    // Crea una polyline che connette tutti i waypoint
    List<LatLng> routePoints = navService.waypoints
        .map((w) => LatLng(w.latitude, w.longitude))
        .toList();
    
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('main_route'),
        points: routePoints,
        color: const Color(0xFF6366F1),
        width: 6,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
    
    // Polyline per il percorso completato (colore diverso)
    if (navService.currentWaypointIndex > 0) {
      List<LatLng> completedPoints = navService.waypoints
          .take(navService.currentWaypointIndex + 1)
          .map((w) => LatLng(w.latitude, w.longitude))
          .toList();
      
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('completed_route'),
          points: completedPoints,
          color: Colors.green,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navService = context.watch<NavigationService>();
    final locationService = context.watch<LocationService>();
    
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
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              if (locationService.currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      locationService.currentPosition!.latitude,
                      locationService.currentPosition!.longitude,
                    ),
                    17.5,
                  ),
                );
              }
            },
            onCameraMove: (_) {
              // Disabilita il follow quando l'utente muove la mappa
              if (_followUser) {
                setState(() => _followUser = false);
              }
            },
          ),
          
          // Top bar con informazioni
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildBackButton(theme),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoCard(theme, navService)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionCard(theme, navService),
              ],
            ),
          ),
          
          // Bottoni di controllo mappa
          Positioned(
            top: MediaQuery.of(context).padding.top + 200,
            right: 16,
            child: Column(
              children: [
                _buildRecenterButton(theme),
                const SizedBox(height: 12),
                _buildZoomButtons(theme),
              ],
            ),
          ),
          
          // Bottom sheet navigazione
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return NavigationBottomSheet(
                scrollController: scrollController,
                transportMode: navService.transportMode,
                onRecenter: _recenterMap,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, NavigationService navService) {
    return Material(
      color: theme.cardColor,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              theme,
              Icons.access_time,
              navService.getFormattedETA(),
              'ETA',
            ),
            Container(
              width: 1,
              height: 30,
              color: theme.dividerColor,
            ),
            _buildInfoItem(
              theme,
              Icons.location_on,
              navService.getFormattedDistance(),
              'Distanza',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard(ThemeData theme, NavigationService navService) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.navigation,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                navService.currentInstruction.isNotEmpty
                    ? navService.currentInstruction
                    : 'Inizializzazione navigazione...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Material(
      color: theme.cardColor,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.read<NavigationService>().stopNavigation();
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.close_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildRecenterButton(ThemeData theme) {
    return Material(
      color: _followUser ? theme.colorScheme.primary : theme.cardColor,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          setState(() => _followUser = true);
          _recenterMap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.my_location_rounded,
            color: _followUser ? Colors.white : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButtons(ThemeData theme) {
    return Material(
      color: theme.cardColor,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _mapController?.animateCamera(
              CameraUpdate.zoomIn(),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.add_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          InkWell(
            onTap: () => _mapController?.animateCamera(
              CameraUpdate.zoomOut(),
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.remove_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _recenterMap() {
    final locationService = context.read<LocationService>();
    if (locationService.currentPosition != null && _mapController != null) {
      setState(() => _followUser = true);
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              locationService.currentPosition!.latitude,
              locationService.currentPosition!.longitude,
            ),
            zoom: 17.5,
            bearing: locationService.heading ?? 0,
            tilt: 45,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
