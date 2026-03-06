import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/landmark.dart';

enum RoutePoint { station, itisBiennio, itisTriennio }

class MapScreen extends StatefulWidget {
  final RoutePoint from;
  final RoutePoint to;

  const MapScreen({super.key, required this.from, required this.to});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  late final List<Landmark> _all = Landmark.routeCsvPoints();
  late final List<Landmark> _route = _buildRoute(widget.from, widget.to);

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createPolyline();
  }

  int _indexOf(RoutePoint p) {
    switch (p) {
      case RoutePoint.station:
        return 0; // order 1
      case RoutePoint.itisBiennio:
        return 33; // order 34
      case RoutePoint.itisTriennio:
        return 34; // order 35
    }
  }

  List<Landmark> _buildRoute(RoutePoint from, RoutePoint to) {
    final a = _indexOf(from);
    final b = _indexOf(to);

    if (a == b) return [_all[a]];

    if (a < b) {
      return _all.sublist(a, b + 1);
    } else {
      return _all.sublist(b, a + 1).reversed.toList();
    }
  }

  String _titleFor(RoutePoint p) {
    switch (p) {
      case RoutePoint.station:
        return 'Stazione';
      case RoutePoint.itisBiennio:
        return 'ITIS (Biennio)';
      case RoutePoint.itisTriennio:
        return 'ITIS (Triennio)';
    }
  }

  void _createMarkers() {
    _markers = _route.map((lm) {
      final upper = lm.name.toUpperCase();
      final isStart = lm == _route.first;
      final isEnd = lm == _route.last;
      final isArrival = upper.startsWith('ARRIVO');
      final isStation = upper.startsWith('INIZIO');

      final hue = isStart
          ? BitmapDescriptor.hueGreen
          : (isEnd || isArrival ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure);

      // Se il punto è la stazione (INIZIO) ma non è start/end, lo lascio azzurro.
      final finalHue = (isStation && !isStart && !isEnd) ? BitmapDescriptor.hueAzure : hue;

      return Marker(
        markerId: MarkerId('${lm.order}-${lm.name}'),
        position: LatLng(lm.latitude, lm.longitude),
        infoWindow: InfoWindow(title: lm.name, snippet: lm.description),
        icon: BitmapDescriptor.defaultMarkerWithHue(finalHue),
      );
    }).toSet();
  }

  void _createPolyline() {
    final points = _route.map((lm) => LatLng(lm.latitude, lm.longitude)).toList();

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        width: 6,
        color: Colors.blue,
      ),
    };
  }

  LatLng _center() {
    final lats = _route.map((e) => e.latitude).toList();
    final lons = _route.map((e) => e.longitude).toList();
    final lat = (lats.reduce((a, b) => a + b)) / lats.length;
    final lon = (lons.reduce((a, b) => a + b)) / lons.length;
    return LatLng(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    final title = '${_titleFor(widget.from)} → ${_titleFor(widget.to)}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GoogleMap(
        onMapCreated: (c) => _controller = c,
        initialCameraPosition: CameraPosition(target: _center(), zoom: 14.5),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final c = _controller;
          if (c == null) return;
          c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _center(), zoom: 14.5)));
        },
        icon: const Icon(Icons.center_focus_strong),
        label: const Text('Centra'),
      ),
    );
  }
}
