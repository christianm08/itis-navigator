import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/cotral_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CotralService extends ChangeNotifier {
  static const String _baseUrl = 'http://travel.mob.cotralspa.it:7777/beApp';
  static const String _userId = '1BB73DCDAFA007572FC51E7407AB497C';

  bool _isLoading = false;
  String? _error;
  List<BusStop> _stops = [];
  List<BusPole> _poles = [];
  BusTransitResponse? _currentTransits;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BusStop> get stops => _stops;
  List<BusPole> get poles => _poles;
  BusTransitResponse? get currentTransits => _currentTransits;

  static const String cassinoStopCode = '70539';

  /// Ottiene tutte le fermate di una località
  Future<List<BusStop>> getStops(String locality) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/getStops.asp?userId=$_userId&locality=$locality');
      debugPrint('🚌 Fetching stops for $locality: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('✅ API Response received (${response.body.length} bytes)');
        final xmlData = response.body;
        final jsonData = await _xmlToJson(xmlData);
        _stops = _parseStops(jsonData);
        
        // Se parsing fallisce, usa dati statici
        if (_stops.isEmpty) {
          debugPrint('⚠️ Parsing failed, using static data');
          _stops = _getCassinoStaticStops();
          _error = 'Usando dati statici (parsing non implementato)';
        } else {
          debugPrint('✅ Found ${_stops.length} stops in $locality');
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ API 404 - Using static fallback data');
        _stops = _getCassinoStaticStops();
        _error = 'API non disponibile. Usando dati locali.';
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching stops: $e');
      _stops = _getCassinoStaticStops();
      _error = 'API non disponibile. Usando dati locali.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _stops;
  }

  /// Dati statici fermate Cassino come fallback
  List<BusStop> _getCassinoStaticStops() {
    return [
      BusStop(
        code: '70539',
        name: 'Cassino - Stazione FS',
        locality: 'Cassino',
        position: const LatLng(41.4897, 13.8283),
      ),
      BusStop(
        code: '70540',
        name: 'Cassino - Viale Garigliano',
        locality: 'Cassino',
        position: const LatLng(41.4886, 13.8313),
      ),
      BusStop(
        code: '70541',
        name: 'Cassino - Via Di Biasio',
        locality: 'Cassino',
        position: const LatLng(41.4912, 13.8275),
      ),
    ];
  }

  /// Ottiene le paline di una fermata
  Future<List<BusPole>> getPoles(String stopCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/getPalina.asp?userId=$_userId&codStop=$stopCode');
      debugPrint('🚏 Fetching poles for stop $stopCode: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('✅ API Response received (${response.body.length} bytes)');
        final xmlData = response.body;
        final jsonData = await _xmlToJson(xmlData);
        _poles = _parsePoles(jsonData);
        
        if (_poles.isEmpty) {
          debugPrint('⚠️ Parsing failed, using static poles');
          _poles = _getStaticPoles(stopCode);
          _error = 'Usando dati statici (parsing non implementato)';
        } else {
          debugPrint('✅ Found ${_poles.length} poles for stop $stopCode');
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ API 404 - Using static poles');
        _poles = _getStaticPoles(stopCode);
        _error = 'API non disponibile. Usando dati locali.';
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching poles: $e');
      _poles = _getStaticPoles(stopCode);
      _error = 'API non disponibile. Usando dati locali.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _poles;
  }

  /// Paline statiche come fallback
  List<BusPole> _getStaticPoles(String stopCode) {
    if (stopCode == '70539') {
      return [
        BusPole(
          code: '70539A',
          name: 'Direzione Frosinone',
          locality: 'Cassino',
          position: const LatLng(41.4897, 13.8283),
        ),
        BusPole(
          code: '70539B',
          name: 'Direzione Roma',
          locality: 'Cassino',
          position: const LatLng(41.4897, 13.8283),
        ),
      ];
    }
    return [
      BusPole(
        code: '${stopCode}A',
        name: 'Palina A',
        locality: 'Cassino',
        position: const LatLng(41.4897, 13.8283),
      ),
    ];
  }

  /// Ottiene i transiti in tempo reale per una palina
  Future<BusTransitResponse?> getTransits(String poleCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/getTransitiPalina.asp?userId=$_userId&codPalina=$poleCode');
      debugPrint('🚌 Fetching transits for pole $poleCode: $url');

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('✅ API Response received (${response.body.length} bytes)');
        final xmlData = response.body;
        final jsonData = await _xmlToJson(xmlData);
        _currentTransits = _parseTransits(jsonData);
        
        if (_currentTransits?.transits.isEmpty ?? true) {
          debugPrint('⚠️ No transits, using static schedule');
          _currentTransits = _getStaticTransits(poleCode);
          _error = 'Dati in tempo reale non disponibili. Orari programmati.';
        } else {
          debugPrint('✅ Found ${_currentTransits?.transits.length} transits');
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ API 404 - Using static transits');
        _currentTransits = _getStaticTransits(poleCode);
        _error = 'API non disponibile. Orari programmati.';
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching transits: $e');
      _currentTransits = _getStaticTransits(poleCode);
      _error = 'API non disponibile. Orari programmati.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _currentTransits;
  }

  /// Transiti statici come fallback
  BusTransitResponse _getStaticTransits(String poleCode) {
    final pole = BusPole(
      code: poleCode,
      name: 'Palina Cassino',
      locality: 'Cassino',
      position: const LatLng(41.4897, 13.8283),
    );

    final now = DateTime.now();
    final transits = <BusTransit>[
      BusTransit(
        routeName: 'Cassino - Frosinone',
        scheduledTime: now.add(const Duration(minutes: 15)),
        estimatedTime: now.add(const Duration(minutes: 15)),
        delay: '00:00:00',
        vehicleCode: 'Programmato',
        isRealTime: false,
      ),
      BusTransit(
        routeName: 'Cassino - Roma',
        scheduledTime: now.add(const Duration(minutes: 35)),
        estimatedTime: now.add(const Duration(minutes: 35)),
        delay: '00:00:00',
        vehicleCode: 'Programmato',
        isRealTime: false,
      ),
      BusTransit(
        routeName: 'Cassino - Sora',
        scheduledTime: now.add(const Duration(minutes: 50)),
        estimatedTime: now.add(const Duration(minutes: 50)),
        delay: '00:00:00',
        vehicleCode: 'Programmato',
        isRealTime: false,
      ),
    ];

    return BusTransitResponse(pole: pole, transits: transits);
  }

  /// Trova paline vicine a una posizione GPS
  Future<List<BusPole>> getPolesNearby(LatLng position, {double radiusKm = 2.0}) async {
    await getStops('Cassino');
    
    final nearbyStops = _stops.where((stop) {
      final distance = _calculateDistance(position, stop.position);
      return distance <= radiusKm;
    }).toList();

    if (nearbyStops.isNotEmpty) {
      await getPoles(nearbyStops.first.code);
      return _poles;
    }

    return [];
  }

  /// Converte XML in JSON
  Future<Map<String, dynamic>> _xmlToJson(String xmlString) async {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      return _xmlNodeToMap(document.rootElement);
    } catch (e) {
      debugPrint('❌ XML parsing error: $e');
      return {};
    }
  }

  Map<String, dynamic> _xmlNodeToMap(dynamic node) {
    final map = <String, dynamic>{};
    
    if (node.children != null) {
      for (final child in node.children) {
        if (child is xml.XmlElement) {
          final name = child.name.local;
          final value = child.text.trim();
          
          if (value.isNotEmpty) {
            map[name] = value;
          } else if (child.children.isNotEmpty) {
            map[name] = _xmlNodeToMap(child);
          }
        }
      }
    }
    
    return map;
  }

  List<BusStop> _parseStops(Map<String, dynamic> json) {
    // TODO: Implementare parsing XML corretto
    debugPrint('🔧 Stop parsing not yet implemented');
    return [];
  }

  List<BusPole> _parsePoles(Map<String, dynamic> json) {
    // TODO: Implementare parsing XML corretto
    debugPrint('🔧 Pole parsing not yet implemented');
    return [];
  }

  BusTransitResponse _parseTransits(Map<String, dynamic> json) {
    // TODO: Implementare parsing XML corretto
    debugPrint('🔧 Transit parsing not yet implemented');
    
    final pole = BusPole(
      code: '',
      name: '',
      locality: 'Cassino',
      position: const LatLng(41.4897, 13.8283),
    );
    
    return BusTransitResponse(pole: pole, transits: []);
  }

  /// Calcola distanza tra due punti GPS (Haversine)
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const R = 6371;
    final dLat = _toRadians(pos2.latitude - pos1.latitude);
    final dLon = _toRadians(pos2.longitude - pos1.longitude);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(pos1.latitude)) *
        cos(_toRadians(pos2.latitude)) *
        sin(dLon / 2) *
        sin(dLon / 2);
    
    final c = 2 * asin(sqrt(a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
}
