import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/navigation_service.dart';
import '../widgets/navigation_bottom_sheet.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  GoogleMapController? _mapController;
  
  // Coordinate ITIS E. Majorana Cassino
  static const LatLng _itisLocation = LatLng(41.4897, 13.8283);
  // Stazione Cassino
  static const LatLng _stationLocation = LatLng(41.4917, 13.8311);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    _setupRoute();
  }

  void _setupMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('station'),
        position: _stationLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: '🚉 Stazione Cassino',
          snippet: 'Punto di partenza',
        ),
      ),
      Marker(
        markerId: const MarkerId('itis'),
        position: _itisLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: '🏫 ITIS E. Majorana',
          snippet: 'Destinazione',
        ),
      ),
    ]);
  }

  void _setupRoute() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          _stationLocation,
          const LatLng(41.4905, 13.8295),
          const LatLng(41.4900, 13.8288),
          _itisLocation,
        ],
        color: const Color(0xFF6366F1),
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navService = context.watch<NavigationService>();
    
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(41.4907, 13.8297),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _fitBounds();
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildBackButton(theme),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _buildZoomButtons(theme),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
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

  Widget _buildBackButton(ThemeData theme) {
    return Material(
      color: theme.cardColor,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.primary,
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

  void _fitBounds() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: _itisLocation,
            northeast: _stationLocation,
          ),
          100,
        ),
      );
    }
  }

  void _recenterMap() {
    _fitBounds();
  }
}
