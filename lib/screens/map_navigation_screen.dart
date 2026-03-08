import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
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
  
  // Coordinate ITIS E. Majorana Cassino (destinazione finale)
  static const LatLng _itisLocation = LatLng(41.4688333, 13.8341111);
  // Stazione Cassino (partenza)
  static const LatLng _stationLocation = LatLng(41.4847222, 13.83225);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    final locationService = context.read<LocationService>();
    await locationService.initialize();
    
    _setupMapElements();
    setState(() => _isInitialized = true);
  }

  void _setupMapElements() {
    final navService = context.read<NavigationService>();
    navService.initializeRoute(Landmark.routeCsvPoints());
    
    _setupMarkers();
    _setupRoute();
  }

  void _setupMarkers() {
    _markers.clear();
    
    // Marker stazione (partenza)
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
  }

  void _setupRoute() {
    final navService = context.read<NavigationService>();
    _polylines.clear();
    
    // Crea polyline con tutti i waypoint
    List<LatLng> routePoints = navService.waypoints
        .map((w) => LatLng(w.latitude, w.longitude))
        .toList();
    
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('main_route'),
        points: routePoints,
        color: const Color(0xFFFF6B6B),
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  Future<void> _startGoogleMapsNavigation() async {
    // Usa Google Maps per la navigazione turn-by-turn reale
    final origin = '${_stationLocation.latitude},${_stationLocation.longitude}';
    final destination = '${_itisLocation.latitude},${_itisLocation.longitude}';
    
    // Crea waypoints intermedi per il percorso
    final navService = context.read<NavigationService>();
    final waypoints = navService.waypoints
        .where((w) => w.order % 5 == 0) // Usa solo alcuni waypoint per non sovraccaricare
        .take(8) // Max 8 waypoint per Google Maps
        .map((w) => '${w.latitude},${w.longitude}')
        .join('|');
    
    // URL per Google Maps con navigazione
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=$waypoints&travelmode=walking',
    );
    
    // URL alternativo per app Google Maps
    final googleMapsAppUrl = Uri.parse(
      'google.navigation:q=$destination&waypoints=$waypoints&mode=w',
    );

    try {
      // Prova prima ad aprire l'app Google Maps
      if (await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        // Altrimenti usa il browser
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossibile aprire Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationService = context.watch<LocationService>();
    
    return Scaffold(
      body: Stack(
        children: [
          // Mappa
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (_stationLocation.latitude + _itisLocation.latitude) / 2,
                (_stationLocation.longitude + _itisLocation.longitude) / 2,
              ),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              _fitBoundsToRoute();
            },
          ),
          
          // Header con gradiente
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _buildBackButton(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anteprima Percorso',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottone posizione
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 20,
            child: _buildLocationButton(theme, locationService),
          ),
          
          // Card info percorso
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRouteInfoCard(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationButton(ThemeData theme, LocationService locationService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (locationService.currentPosition != null && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(
                    locationService.currentPosition!.latitude,
                    locationService.currentPosition!.longitude,
                  ),
                  16,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.my_location_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard(ThemeData theme) {
    final navService = context.watch<NavigationService>();
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.directions_walk,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stazione → ITIS E. Majorana',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(navService.totalDistance / 1000).toStringAsFixed(1)} km • ~${((navService.totalDistance / 1.4) / 60).round()} min a piedi',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _startGoogleMapsNavigation,
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Avvia Navigazione',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Si aprirà Google Maps con navigazione turn-by-turn',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
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
            _itisLocation.latitude < _stationLocation.latitude
                ? _itisLocation.latitude
                : _stationLocation.latitude,
            _itisLocation.longitude < _stationLocation.longitude
                ? _itisLocation.longitude
                : _stationLocation.longitude,
          ),
          northeast: LatLng(
            _itisLocation.latitude > _stationLocation.latitude
                ? _itisLocation.latitude
                : _stationLocation.latitude,
            _itisLocation.longitude > _stationLocation.longitude
                ? _itisLocation.longitude
                : _stationLocation.longitude,
          ),
        ),
        100,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
